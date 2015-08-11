% under construction

% MAJOR CHANGE: BOUNDARY POINTS ARE NOW FIXED!!!

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
dt=tau/(numel(t)-1);

signal=varargin{2}(:);
signal=signal-mean(signal);
L=numel(signal); % number of signal points

% analyze components
Nm=ones(Mtotal,1); % subregions
active=true(Mtotal,1);
InteriorSelection=repmat(struct('X',[],'Y',[]),[1 Mtotal]);
for m=1:Mtotal
    % determine if comopnent is active
    [bminL,~]=probe(boundary{m},time(1)); % left side
    [bminR,~]=probe(boundary{m},time(end)); % right side
    if isnan(bminL) || isnan(bminR)
        active(m)=false;
        continue;
    end
    active(m)=true;
    % determine the number of subdomains    
    table=boundary{m}.Data(:,1:2);
    table=sortrows(table,1);
    table=table(2:end-1,:);
    index=(table(:,1)>time(1)) & (table(:,1)<time(end));
    table=table(index,:);
    if size(table,1)>0
        keep=[true; diff(table(:,1))>=dt];
        table=table(keep,:);
        InteriorSelection(m).X=table(:,1);
        InteriorSelection(m).Y=table(:,2);
    end    
    Nm(m)=size(table,1)+1;
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
%NumParam=2*sum(Nm(active));
NumParam=sum(Nm(active)+1);
guess=nan(NumParam,1);
ConstraintTable=nan(NumParam,2);
[left,right]=deal(nan(Mtotal,max(Nm)));
index=1;
for m=active   
    % identify boundaries
    for n=1:Nm(m)
        if n==1
            left(m,n)=time(1);
        else
            left(m,n)=right(m,n-1);
        end
        if (Nm(m)==1) || (n==Nm(m))
            right(m,n)=time(end);
        else
            right(m,n)=InteriorSelection(m).X(n);
        end                        
    end
    % characterize subdomain widths
    %for n=1:(Nm(m)-1)
    %    guess(index)=sqrt(right(m,n)-left(m,n));
    %    ConstraintTable(index,1)=dt;
    %    index=index+1;
    %end
    % characterize beat parameters   
    for n=1:(Nm(m)+1)
        if n<=Nm(m)
            [bmin,bmax]=probe(boundary{m},left(m,n));
        else
            [bmin,bmax]=probe(boundary{m},right(m,n-1));
        end
        ConstraintTable(index,1)=(bmin+bmax)/2; % center
        ConstraintTable(index,2)=(bmax-bmin)/2; % amplitude
        guess(index)=0;
        index=index+1;                    
    end
end

% perform nonlinear optimization
BasisMatrix=nan(L,NumCol);
beat=nan(Mtotal,max(Nm)+1);
%left(:)=nan;
%right(:)=nan;
g=[]; % linear parameters
    function [chi2,fit]=residual(param)
        % transform slack variables
        index=1;
        for mr=active
            % subdomain boundaries
            %             for nr=1:Nm(mr)
            %                 if (Nm(mr)==1) || (nr==1)
            %                     left(mr,nr)=time(1);
            %                 else
            %                     left(mr,nr)=right(mr,nr-1);
            %                 end
            %                 if (Nm(mr)==1) || (nr==Nm(mr))
            %                     right(mr,nr)=time(end);
            %                 else
            %                     right(mr,nr)=left(mr,nr)+...
            %                         ConstraintTable(index,1)+param(index)^2;
            %                     index=index+1;
            %                     if right(mr,nr)>time(end)
            %                         right(mr,nr)=time(end);
            %                     end
            %                 end
            %             end
            % beat parameters
            for nr=1:(Nm(mr)+1)
                beat(mr,nr)=ConstraintTable(index,1)+...
                    ConstraintTable(index,2)*sin(param(index));
                index=index+1;
            end
        end                               
        % update basis matrix
        for col=1:NumCol
            BasisMatrix(:,col)=0;
            mr=ColumnTable(col,1);
            nr=ColumnTable(col,2);
            if (left(mr,nr)==time(end))
                continue
            end
            pr=ColumnTable(col,3);
            qr=ColumnTable(col,4);
            br=ColumnTable(col,5);                       
            index=(time>=left(mr,nr)) & (time<=right(mr,nr));
            t=time(index)-left(mr,nr);
            phase=abs(bref(mr)+qr*(beat(mr,nr)-bref(mr)))*t;
            if sum(index)>2
                chirp=(beat(mr,nr+1)-beat(mr,nr))/(right(mr,nr)-left(mr,nr));
                phase=phase+(chirp/2)*t.^2;
            end
            phase=2*pi*pr*phase;
            switch br
                case 1
                    BasisMatrix(index,col)=cos(phase);
                case 2
                    BasisMatrix(index,col)=sin(phase);                    
            end
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
        if stop
            keyboard
        end
    end

stop=false;
result=fminsearch(@residual,guess,OptimizationOptions);
[~,fit]=residual(result);

f=nan(Mtotal,1);
for m=active
    finst=nan(L,1);
    for n=1:Nm(m)
        index=(time>=left(m,n)) & (time<=right(m,n));
        finst(index)=beat(m,n);
        if sum(index)>2
            chirp=(beat(m,n+1)-beat(m,n))/(right(m,n)-left(m,n));
            t=time(index)-left(m,n);
            finst(index)=finst(index)+chirp*t;
        end       
    end
    finst=finst(~isnan(finst));
    f(m)=mean(finst);
end

%out(:,1)=bave;
out(:,1)=f;
out(:,2:4)=nan;
varargout{1}=out(:);

if false
%if true
%if any(f)<0 || any(Nm>3)
%if any(Nm>1)
    ha(1)=subplot(2,1,1);
    view(boundary{1},gca);
    ha(2)=subplot(2,1,2);
    plot(time,signal,'r',time,fit,'k');
    linkaxes(ha,'x');
    xlim(ha(2),[time(1) time(end)]);
    set(ha(1),'YLimMode','auto');
    title(sprintf('Nm=%g ',Nm));
    for n=1:numel(right);line(repmat(right(1,n),[1 2]),ylim);end
    keyboard
    if stop
        result=fminsearch(@residual,guess,OptimizationOptions);
    end
end

end