% simulate Perform diffusion simulation
%
% The method simulates thermal diffusion using the numerical method of
% lines.
%    >> object=simulate(object,time);
% The second input "time" controls the simulation's time range.  Passing a
% two element array (e.g., [0 stop]) runs the simulation from the
% initial state to the "stop" time; intermediate time steps are generated
% as needed by MATLAB's ode1s function.  Output can also restricted to
% specific time values.
%    >> object=simuate(object,[t1 t2 ...]);
%
%
% See also ThermalDiffusion
%

%
% created July 24, 2014 by Daniel Dolan (Sandia National Laboratories)
%
%function object=simulate(object,time)
function result=simulate(object,time)

% handle input
assert(nargin>=2,'ERROR: insufficient number of inputs');

assert(isnumeric(time),'ERROR: invalid time input');
time=sort(time(:));
if time(1)~=0   
    time(2:end+1)=time;
    time(1)=0;
end

% create full node arrays
ready=verify(object);
if ~ready
    verify(object);
    result=[];
    return;
end

numpoints=sum(object.Nodes);
[position,Tinitial,spacing,conductivity,diffusivity]=...
    deal(nan(numpoints,1));
[left,right]=deal(nan(1,object.Layers));
for layer=1:object.Layers
    if layer==1
        left(layer)=1;
        right(layer)=object.Nodes(layer);
        x0=0;
    else
        left(layer)=right(layer-1)+1;
        right(layer)=left(layer)+object.Nodes(layer)-1;
        x0=x0+object.Thickness(layer-1);
    end    
    x=linspace(x0,x0+object.Thickness(layer),object.Nodes(layer));
    index=left(layer):right(layer);
    position(index)=x;
    spacing(index)=(x(end)-x(1))/(numel(x)-1);
    if isnumeric(object.InitialTemperature)
        Tinitial(index)=object.InitialTemperature(layer);
    end
    conductivity(index)=object.Conductivity(layer);
    diffusivity(index)=object.Diffusivity(layer);
end
if isa(object.InitialTemperature,'function_handle')
    Tinitial=object.InitialTemperature(position);
end

% create interior arrays
keep=true(numpoints,1);
keep(left)=false;
keep(right)=false;
interiorIndex=transpose(1:numpoints);
interiorIndex=interiorIndex(keep);
x=position(interiorIndex);

interfaceRight=right(1:end-1)-1;
correction=cumsum(0:2:2*(object.Interfaces-1));
interfaceRight=interfaceRight-correction;
interfaceLeft=interfaceRight+1;

% ODE problem
% y contains interior node temperatures
[T]=deal(nan(numpoints,1)); 
M=numel(interiorIndex);
msparse=[1:M 1:(M-1) 2:M];
msparse=msparse(:);
nsparse=[1:M 2:M 1:(M-1)];
nsparse=nsparse(:);
jacobian=sparse(msparse,nsparse,nan,M,M,numel(msparse));
diagonalC=(M+1)*(1:M)-M; % absolute index of center diagonal
diagonalU=(M+1)*(1:M-1);
diagonalL=(M+1)*(2:M)-2*M;
    function result=calculate(quantity,t,y)                      
        % calculate full temperature array
        T(interiorIndex)=y;
        T(1)=(18*T(2)-9*T(3)+2*T(4))/11; % left outer boundary
        T(end)=(2*T(end-3)-9*T(end-2)+18*T(end-1))/11; % right outer boundary
        for interface=1:object.Interfaces % interior interfaces
            A=right(interface);
            B=A+1;
            zA=-2*T(A-3)+9*T(A-2)-18*T(A-1);
            zB=+18*T(B+1)-9*T(B+2)+2*T(B+3);
            eta=conductivity(A)/conductivity(B)*spacing(B)/spacing(A);
            gamma=1/object.InterfaceConductance(interface); 
            gamma=gamma*conductivity(A)/(6*spacing(A));
            T(A)=(zB-(11*gamma+eta)*zA)/(eta+1+11*gamma)/11;
            T(B)=T(A)+gamma*(zA+11*T(A));
        end
        if strcmpi(quantity,'temperature')
            result=T;
            return
        end   
        kappa_D2=diffusivity(interiorIndex)./spacing(interiorIndex).^2;
        % calculate Jacobian            
        if strcmpi(quantity,'jacobian')
            jacobian(diagonalC)=-2*kappa_D2;
            jacobian(diagonalU)=+1*kappa_D2(1:end-1);
            jacobian(diagonalL)=+1*kappa_D2(2:end);
            for interface=1:object.Interfaces
                index=interfaceRight(interface);
                jacobian(index,index+1)=0;
                index=interfaceLeft(interface);
                jacobian(index,index-1)=0;
            end           
            result=jacobian;
            return
        end        
        % calculte interior derivatives
         if strcmpi(quantity,'derivative')
             result=nan(numpoints,1);             
             index=2:(numpoints-1);
             result(index)=T(index+1)-2*T(index)+T(index-1);
             result=result(interiorIndex).*kappa_D2;
             result=result+object.InternalHeating(x,t);
             return
         end
         error('ERROR: invalid calculation requested');
    end
options=odeset('RelTol',object.RelTol,'AbsTol',object.AbsTol,...
    'InitialStep',object.InitialStep,'MaxStep',object.MaxStep);
if strcmp(object.OutputMode,'verbose')
    options.Stats='on';
end
options.Jacobian=@(t,y) calculate('jacobian',t,y);
Tinitial=Tinitial(interiorIndex);
dydt=@(t,y) calculate('derivative',t,y);
if strcmp(object.OutputMode,'verbose')
    tic;
end
[time,solution]=ode15s(dydt,time,Tinitial,options);
if strcmp(object.OutputMode,'verbose')
    toc;
end

% store results
%object.SimulationResult=nan(numel(time)+1,numpoints+1);
%object.SimulationResult(2:end,1)=time;
%object.SimulationResult(1,2:end)=position;
%for iteration=1:numel(time)
%    temp=solution(iteration,:);
%    temp=calculate('temperature',time(iteration),temp(:));
%    object.SimulationResult(iteration+1,2:end)=transpose(temp);
%end

table=nan(numel(time),numpoints);
for iteration=1:numel(time)
    temp=solution(iteration,:);
    temp=calculate('temperature',time(iteration),temp);
    table(iteration,:)=transpose(temp);
end
result=SMASH.PDE.mesh1(time,transpose(position),table);


end