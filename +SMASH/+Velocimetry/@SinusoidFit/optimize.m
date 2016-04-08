function object=optimize(object)

% manage input

%% extract boundary
% m : component index
% n : domain index

bound=object.FrequencyBound;
if isempty(bound)
    temp=SMASH.SignalAnalysis.Signal(object.Time,object.Signal);
    [f,P]=fft(temp,'Window','Hann',...
        'RemoveDC',true,'NumberFrequencies',10e3);
    P(P < 0.10*max(P))=0;
    weight=P/trapz(f,P);
    f0=trapz(f,f.*weight);
    width=sqrt(trapz(f,(f-f0).^2.*weight));
    data=nan(2,3);
    data(1,1)=min(object.Time);
    data(2,1)=max(object.Time);
    data(:,2)=f0;
    data(:,3)=width;
    bound=SMASH.ROI.BoundingCurve('horizontal');
    bound=define(bound,data);
    bound={bound};
end
Ncomponent=numel(bound);

%% extend bound over the entire signal (as needed)
for n=1:Ncomponent
    table=bound{n}.Data;
    if table(1,1) > object.Time(1)
        table(2:end+1,:)=table;
        table(1,1)=object.Time(1);
        table(1,2)=interp1(table(2:end,1),table(2:end,2),object.Time(1),...
            'linear','extrap');
        table(1,3)=interp1(table(2:end,1),table(2:end,3),object.Time(1),...
            'linear','extrap');
    end
    if table(end,1) < object.Time(end)
        table(end+1,:)=nan; %#ok<AGROW>
        table(end,1)=object.Time(end);
        table(end,2)=interp1(table(1:end-1,1),table(1:end-1,2),object.Time(end),...
            'linear','extrap');
        table(end,3)=interp1(table(1:end-1,1),table(1:end-1,3),object.Time(end),...
            'linear','extrap');
    end
    bound{n}=define(bound{n},table);
end

%%
Nduration=nan(1,Ncomponent);
guess=[];
for m=1:Ncomponent
    [duration,slope]=...
        setupDomain(bound{m},object.Time,object.BreakTolerance);    
    Nduration(m)=numel(duration);    
    temp=sqrt(duration(1:end-1));
    guess=[guess; temp(:)]; %#ok<AGROW>
    temp=zeros(Nduration(m),1);
    guess=[guess; temp(:)]; %#ok<AGROW>
    %temp=zeros(Nduration(m),1);
    guess=[guess; slope(:)]; %#ok<AGROW>
end

% perform optimization
% mm : component index (subfunction)
% nn : domain index (subfunction)

Npoints=numel(object.Time);

tmin=min(object.Time);
tmax=max(object.Time);
TotalDuration=tmax-tmin;
[duration,beat,chirp]=deal(cell(1,Ncomponent));
for m=1:Ncomponent
    temp=nan(Nduration(m),1);
    duration{m}=temp;
    beat{m}=temp;
    chirp{m}=temp;
end
basis=nan(numel(object.Time),2*sum(Nduration));
amplitude=[];
    function chi2=residual(slack)
        column=1;
        start=1;
        for mm=1:Ncomponent % process each component
            % extract durations
            stop=start+Nduration(mm)-2;
            Delta=slack(start:stop);          
            temp=Delta.^2;
            duration{mm}(1:end-1)=temp; 
            duration{mm}(end)=TotalDuration-sum(temp);                     
            % process durations
            start=stop+1;
            left=tmin;                                   
            for nn=1:Nduration(mm)               
                right=left+duration{mm}(nn);
                center=(left+right)/2;
                % finish converting slack variables
                [low,high]=probe(bound{mm},[left center right]);               
                beta=slack(start);
                beat{mm}(nn)=slack2variable(beta,[low(2) high(2)]);
                slope=(high+low)/duration{mm}(nn);
                slope=slope(3)-slope(1);
                %chirp{mm}(nn)=slope+slack(start+1);
                chirp{mm}(nn)=0; % trial
                %gamma=slack(start+1);                
                %chirp{mm}(nn)=slack2variable(gamma,...
                %    [high(3)-low(1) low(3)-high(1)]/duration{mm}(nn));
                %fprintf('%g ',(high(3)-low(1))/duration{mm}(nn),(low(3)-high(1))/duration{mm}(nn),chirp{mm}(nn)); fprintf('\n');
                start=start+2;
                % fill in basis matrix
                index=(object.Time >= left) & (object.Time <= right);
                t=object.Time(index)-center;
                phase=2*pi*(beat{mm}(nn)*t + chirp{mm}(nn)/2*t.^2);
                basis(index,column)=cos(phase);
                basis(index,column+1)=sin(phase);
                basis(~index,column:column+1)=0;
                column=column+2;
                left=right;
            end                                               
        end
        %[amplitude,~]=linsolve(basis,object.Signal);
        amplitude=basis\object.Signal;
        fit=basis*amplitude;
        chi2=sum((object.Signal-fit).^2)/Npoints;
    end
options=optimset();
fminsearch(@residual,guess,options);

object.Curve=fit;
object.Frequency=beat;
object.Chirp=chirp;
object.Amplitude=amplitude;

end

function variable=slack2variable(slack,range)

range=sort(range);

center=(range(2)+range(1))/2;
amplitude=(range(2)-range(1))/2;
variable=center+amplitude*sin(slack);

end