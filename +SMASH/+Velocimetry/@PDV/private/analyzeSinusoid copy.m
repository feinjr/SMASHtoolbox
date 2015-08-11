% under construction


%   analyzeSinusoid('-setup',name,value,...);
%
% result=analyzeSinusoid(t,s);

%function history=analyzeSinusoid(object,varargin)
function varargout=analyzeSinusoid(varargin)

%% setup mode
persistent boundary Mtotal Pm Qm bref OptimizationOptions
if strcmp(varargin{1},'-setup')
    % extract boundary object
    boundary=varargin{2};
    Mtotal=numel(boundary);
    varargin=varargin(3:end); % remove setup and boundary inputs
    % default settings
    Pm=1; % electrical harmonics
    Qm=1; % optical harmonics
    bref=0; % reference frequency
    OptimizationOptions=optimset;
    % manage optional inputs
    NumArg=numel(varargin);
    assert(rem(NumArg,2)==0,'ERROR: unmatched name/value pair');
    for arg=1:2:NumArg
        name=varargin{arg};
        assert(ischar(name),'ERROR: invalid option name');
        value=varargin{arg+1};
        switch lower(name)
            case 'electricalharmonics'
                assert(isnumeric(value) && all(value==round(value) && all(value>0)),...
                    'ERROR: invalid ElectricalHarmonics value')
                if isscalar(value)
                    value=repmat(value,[1 Mtotal]);
                end
                assert(numel(value)==Mtotal,...
                    'ERROR: invalid ElectricalHarmonics value');
                Pm=value;
            case 'opticalharmonics'
                assert(isnumeric(value) && all(value==round(value) && all(value>0)),...
                    'ERROR: invalid OpticalHarmonics value')
                if isscalar(value)
                    value=repmat(value,[1 Mtotal]);
                end
                assert(numel(value)==Mtotal,...
                    'ERROR: invalid OpticalHarmonics value');
                Qm=value;
            case 'refrencefrequency'
                assert(isnumeric(value),...
                    'ERROR: invalid ReferenceFrequency value');
                if isscalar(value)
                    value=repmat(value,[1 Mtotal]);
                end
                assert(numel(value)==Mtotal,...
                    'ERROR: invalid ReferenceFrequency value');
                bref=value;
            case 'optimizationoptions'
                try
                    OptimizationOptions=optimset(value);
                catch
                    error('ERROR: invalid optimization options');
                end
            otherwise
                error('ERROR: invalid option name');
        end
    end
    return
end

%% analysis mode
time=varargin{1}(:);
tc=(time(end)+time(1))/2;
t=time-tc;
tau=time(end)-time(1);

signal=varargin{2}(:);
signal=signal-mean(signal);
L=numel(signal); % number of signal points

% identify active components and associated subregions
Nm=ones(Mtotal,1); % subregions
active=true(Mtotal,1);
InteriorSelection=repmat(struct('X',[],'Y',[]),[1 Mtotal]);
for m=1:Mtotal
    [bminL,~]=probe(boundary{m},time(1)); % left side
    [bminR,~]=probe(boundary{m},time(end)); % right side
    if isnan(bminL) || isnan(bminR)
        active(m)=false;
        continue;
    end
    active(m)=true;
    xselect=boundary{m}.Data(2:end-1,1);
    yselect=boundary{m}.Data(2:end-1,2);
    index=(xselect>time(1)) & (xselect<time(end));
    Nm(m)=sum(index)+1;
    InteriorSelection(m).X=xselect(index);
    InteriorSelection(m).Y=yselect(index);
end
active=find(active);

% setup column table
NumCol=2*sum(Nm(active).*Pm(active).*Qm(active));
ColumnTable=nan(NumCol,5); % [m n p q basis]
column=1;
for m=active
    for n=1:Nm(m)
        for p=1:Pm(m)
            for q=1:Qm(m)
                ColumnTable(column,:)=[m n p q 1]; % sine
                column=column+1;
                ColumnTable(column,:)=[m n p q 2]; % cosine
                column=column+1;
            end
        end
    end
end

% setup nonlinear parameters
NumParam=2*sum(Nm(active));
%NumParam=1+sum(Nm(active));
guess=nan(NumParam,1);
ConstraintTable=nan(NumParam,2);
index=1;
[left,right]=deal(nan(Mtotal,max(Nm)));
for m=active
    % average frequencies
    [bmin,bmax]=probe(boundary{m},tc);
    ConstraintTable(index,1)=(bmin+bmax)/2; % center
    ConstraintTable(index,2)=(bmax-bmin)/2; % amplitude
    guess(index)=0;
    index=index+1;
    % chirp values and subregion transitions
    for n=1:Nm(m)
        if n==1
            left(m,n)=time(1);
        else
            left(m,n)=right(m,n-1);
        end
        if (Nm(m)==1) || (n==Nm(m))
            right(m,n)=time(end);
        else%if n<Nm(m)
            right(m,n)=InteriorSelection(m).X(n);
        end
        [bminL,bmaxL]=probe(boundary{m},left(m,n));
        [bminR,bmaxR]=probe(boundary{m},right(m,n));
        cmax=(bmaxR-bminL)/(right(m,n)-left(m,n));
        cmin=(bminR-bmaxL)/(right(m,n)-left(m,n));
        ConstraintTable(index,1)=(cmin+cmax)/2; % center
        ConstraintTable(index,2)=(cmax-cmin)/2; % amplitude
        guess(index)=0;
        index=index+1;
        if (Nm(m)>1) && (n<Nm(m))
            delta=(right(m,n)-left(m,n))/tau;
            guess(index)=1;
            guess(index)=sqrt(delta);
            ConstraintTable(index,1)=0; % minimum value
            %ConstraintTable(index,2)=+1; % direction
            index=index+1;
        end
    end
end

% perform nonlinear optimization
%FrequencyMatrix=nan(sum(Nm));
%FrequencyVector=nan(sum(Nm),1);
BasisMatrix=nan(L,NumCol);
bave=nan(Mtotal,1);
[beat,chirp]=deal(nan(Mtotal,max(Nm)));
left(:)=nan;
right(:)=nan;
g=[]; % linear parameters
    function [chi2,fit]=residual(param)
        % transform slack variables
        index=1;
        for mr=active
            % average frequencies
            bave(mr)=ConstraintTable(index,1)+...
                ConstraintTable(index,2)*sin(param(index));
            index=index+1;
            % chirp values and subregion durations
            left(mr,1)=time(1);
            for nr=1:Nm(mr)
                chirp(mr,nr)=ConstraintTable(index,1)+...
                    ConstraintTable(index,2)*sin(param(index));
                index=index+1;
                if (Nm(mr)>1) && (nr<Nm(mr))
                    delta=ConstraintTable(index,1)+param(index)^2;
                    index=index+1;
                    right(mr,nr)=left(mr,nr)+delta*tau;
                    if right(mr,nr)>time(end)
                        right(mr,nr)=time(end);
                    end
                    left(mr,nr+1)=right(mr,nr);
                else
                    right(mr,nr)=time(end);
                end
            end
        end
        % calculate subdomain frequencies
        beat(:)=nan;
        for mr=active
            beat(mr,1)=bave(mr);
            if Nm(mr)==1
                continue
            end
            for nr=2:Nm(mr)
                beat(mr,nr)=beat(mr,nr-1)+...
                    (chirp(mr,nr-1)-chirp(mr,nr))*(left(mr,nr)-tc);
            end
        end
        %         index=1;
        %         for mr=active
        %             if Nm(mr)==1
        %                 FrequencyMatrix(index,:)=0;
        %                 FrequencyMatrix(index,index)=+1;
        %                 FrequencyVector(index)=bave(mr);
        %                 index=index+1;
        %             else
        %                 for nr=1:(Nm(mr)-1)
        %                     FrequencyMatrix(index,:)=0;
        %                     FrequencyMatrix(index,index)=+1;
        %                     FrequencyMatrix(index,index+1)=-1;
        %                     FrequencyVector(index)=(chirp(mr,nr+1)-chirp(mr,nr))*(right(mr,nr)-tc);
        %                     index=index+1;
        %                 end
        %                 FrequencyMatrix(index,:)=0;
        %                 for nr=1:Nm(mr)
        %                     FrequencyMatrix(index,nr)=(right(mr,nr)-left(mr,nr))/tau;
        %                 end
        %                 FrequencyVector(index)=bave(mr);
        %                 index=index+1;
        %             end
        %         end
        %         [FrequencyVector,~]=linsolve(FrequencyMatrix,FrequencyVector);
        %         start=1;
        %         for mr=active
        %             index=start:Nm(mr);
        %             beat(mr,1:Nm(mr))=FrequencyVector(index);
        %             start=index(end)+1;
        %         end
        % update basis matrix
        for col=1:NumCol
            mr=ColumnTable(col,1);
            nr=ColumnTable(col,2);
            pr=ColumnTable(col,3);
            qr=ColumnTable(col,4);
            br=ColumnTable(col,5);
            temp=zeros(L,1);
            index=(time>=left(mr,nr)) & (time<=right(mr,nr));
            phase=...
                pr*abs(bref(mr)+qr*(beat(mr,nr)-bref(mr)))*t(index)...
                +pr*qr/2*chirp(mr,nr)*t(index).^2;
            switch br
                case 1
                    temp(index)=cos(2*pi*phase);
                case 2
                    temp(index)=sin(2*pi*phase);
            end
            BasisMatrix(:,col)=temp;
        end
        %test=isnan(BasisMatrix);
        %if any(test(:))
        %    keyboard;
        %end
        % linear least squares analysis
        [g,~]=linsolve(BasisMatrix,signal);
        fit=BasisMatrix*g;
        % residual calculation
        chi2=mean((signal-fit).^2);
        %if stop
        %    keyboard
        %end
    end

stop=false;
result=fminsearch(@residual,guess,OptimizationOptions);
[~,fit]=residual(result);

f=nan(Mtotal,1);
for m=active
    temp=nan(L,1);
    for n=1:Nm(m)
        index=(time>=left(m,n)) & (time<=right(m,n));
        temp(index)=beat(m,n)+chirp(m,n)*t(index);
    end
    temp=temp(~isnan(temp));
    f(m)=mean(temp);
end

%out(:,1)=bave;
out(:,1)=f;
out(:,2:4)=nan;
varargout{1}=out(:);

%if false
if any(f)<0 || any(Nm>3)
%if any(Nm>1)
    ha(1)=subplot(2,1,1);
    view(boundary{1},gca);
    ha(2)=subplot(2,1,2);
    plot(time,signal,'r',time,fit,'k');
    linkaxes(ha,'x');
    xlim(ha(2),[time(1) time(end)]);
    set(ha(1),'YLimMode','auto');
    title(sprintf('%g ',Nm));
    keyboard
    if stop
        result=fminsearch(@residual,guess,OptimizationOptions);
    end
end

end