function [object,varargout] = Dispersion(object,varargin)

%% dispersion formula lambda(x) = 2d*sin((x-xo)/Rc)
Rc = 1e3*object.Rc; %radius of curvature in microns
xtal = object.Crystal;

%% get crystal type from object
switch xtal
    case 'Quartz 1011'
        twod = 6.687; %Angstroms
    otherwise
        disp('Please choose a crystal that is available for use in CRITR')
        return
end

%% Setup list of common lines with wavelength
hc = 12398;
Lines = {   'None',[];...
            'Al K-alpha1',hc/1486.7;...
            'Al K-alpha2',hc/1486.27;...
            'Al K-beta1',hc/1557.45;...
            'Al He-alpha',hc/1598;...
            'Al He-beta',hc/1867;...
            'Al Ly-alpha',hc/1729;...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            'Ti K-alpha1',hc/4510.84;...
            'Ti K-alpha2',hc/4504.86;...
            'Ti K-beta1',hc/4931.81;...
            'Ti He-alpha',hc/4750;...
            'Ti He-beta',hc/5580;...
            'Ti Ly-alpha',hc/4977;...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            'Ar K-alpha1',hc/2957.7;...
            'Ar K-alpha2',hc/2955.63;...
            'Ar K-beta1',hc/3190.65;...
            'Ar He-alpha',hc/3140;...
            'Ar He-beta',hc/3682;...
            'Ar Ly-alpha',hc/3323;...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            'Mn He-alpha',hc/6181;...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            'Fe K-alpha1',hc/6403.84;...
            'Fe K-alpha2',hc/6390.84;...
            'Fe K-beta1',hc/7057.98;...
            'Fe He-alpha',hc/6701;...
            'Fe He-beta',hc/7880;...
            'Fe Ly-alpha',hc/6973;...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            'Cu K-alpha1',hc/8047.78;...
            'Cu K-alpha2',hc/8027.83;...
            'Cu K-beta1',hc/8905.29;...
            'Cu He-alpha',hc/8392;...
            'Cu He-beta',hc/9872;...
            'Cu Ly-alpha',hc/8699;...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            'Br K-alpha1',hc/11924.2;...
            'Br K-alpha2',hc/11877.6;...
            'Br K-beta1',hc/13291.4;...
            'Br He-alpha',hc/12372;...
            'Br He-beta',hc/14559;...
            'Br Ly-alpha',hc/12753;...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            'Kr K-alpha1',hc/12649;...
            'Kr K-alpha2',hc/12598;...
            'Kr K-beta1',hc/14112;...
            'Kr He-alpha',hc/13114;...
            'Kr He-beta',hc/15433;...
            'Kr Ly-alpha',hc/13509;...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            'Mo K-alpha1',hc/17479.34;...
            'Mo K-alpha2',hc/17374.3;...
            'Mo K-beta1',hc/19608.3;...
            'Mo He-alpha',hc/18062;...
            'Mo He-beta',hc/21249;...
            'Mo Ly-alpha',hc/18537;...
            };

%% load (X,Y) pairs for wavelength calibration points
if ~isempty(varargin)
    % user supplied calibration points [(x,lambda) pairs]
    Xi = varargin{1};   Yi = varargin{2};
elseif isempty(varargin)
    % launch GUI to choose points
    mean(object,'Grid2')
    fig = gcf;
    Xi = [];
    Yi = [];
    %% Create Dialog box to manipulate image
    diaCalibrate=SMASH.MUI.Dialog;
    diaCalibrate.Hidden=true;
    diaCalibrate.Name='Choose Wavelength Calibration Points';
    set(diaCalibrate.Handle,'Tag','guiCalibrate');
    setappdata(diaCalibrate.Handle,'out',[]);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%   Lambda, position pair 1    %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h1 = addblock(diaCalibrate,'edit','Wavelength [A], Loc.',10); 
    Wavelength1Edit=h1(2);
    set(Wavelength1Edit,'String','');

    addblock(diaCalibrate,'popup','Make a choice:',Lines(:,1)'); % popup menu block

    hOK1=addblock(diaCalibrate,'button',' OK '); % button block
    set(hOK1,'Callback',@OK1Callback); % button probes dialog state and closes it

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%   Lambda, position pair 2    %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h2 = addblock(diaCalibrate,'edit','Wavelength [A], Loc.',10); 
    Wavelength2Edit=h2(2);
    set(Wavelength2Edit,'String','');
    
    addblock(diaCalibrate,'popup','Make a choice:',Lines(:,1)'); % popup menu block
    hOK2=addblock(diaCalibrate,'button',' OK '); % button block
    set(hOK2,'Callback',@OK2Callback); % button probes dialog state and closes it
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%   Lambda, position pair 3    %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h3 = addblock(diaCalibrate,'edit','Wavelength [A], Loc.',10); 
    Wavelength3Edit=h3(2);
    set(Wavelength3Edit,'String','');
    
    addblock(diaCalibrate,'popup','Make a choice:',Lines(:,1)'); % popup menu block
    hOK3=addblock(diaCalibrate,'button',' OK '); % button block
    set(hOK3,'Callback',@OK3Callback); % button probes dialog state and closes it

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%   Lambda, position pair 4    %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h4 = addblock(diaCalibrate,'edit','Wavelength [A], Loc.',10); 
    Wavelength4Edit=h4(2);
    set(Wavelength4Edit,'String','');
    
    addblock(diaCalibrate,'popup','Make a choice:',Lines(:,1)'); % popup menu block
    hOK4=addblock(diaCalibrate,'button',' OK '); % button block
    set(hOK4,'Callback',@OK4Callback); % button probes dialog state and closes it

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%   Finish up    %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hDone=addblock(diaCalibrate,'button',' Done '); % button block
    set(hDone,'Callback',@DoneCallback); % button probes dialog state and closes it
    
    locate(diaCalibrate,'WestOutside',fig)
    diaCalibrate.Hidden=false;
    
    uiwait;
end

%% Determine parameters to fit wavelength scale
if length(Xi) == 1
    % only calibration feature is Br K-edge
    xo = Xi - Rc*asin(Yi/twod);
    NLparams = [xo Rc];
else
    % multiple points supplied, optimize Rc and xo for best fit
    % perform nonlinear optimization
    guess=[10 Rc];
    options=optimset('TolX',1e-6,'TolFun',1e-6);
    fitness=@(NLparams) residual(NLparams,Xi,Yi,twod);
    [NLparams,~,~]=fminsearch(fitness,guess,options);
    
    Rc = NLparams(2);
end

%% convert to energy and update object
object=map(object,'Grid1','custom',@(x) (twod*sin((x-NLparams(1))/NLparams(2))));

object = regrid(object);
object.Rc = Rc/1e3;
object.Grid1Label = 'Photon Energy [eV]';

nout = max(nargout,1)-1;
if nout == 3
    varargout(1) = {Xi};
    varargout(2) = {Yi};
end
    %%%% Callback to finish up and grab all values
    function DoneCallback(varargin)
        value=probe(diaCalibrate);
        cnt = 1;
        for i = 1:length(value)
            d = sscanf(value{i},'%g %*s %g');
            if isempty(d)
                %do nothing
            elseif size(d,1) == 2
                Yi(cnt) = d(1);
                Xi(cnt) = d(2);
                cnt = cnt+1;
            elseif numel(d)==1
                disp('You must provide a wavelength and location for each calibration point')
                return
            end
        end
        
        delete(diaCalibrate)
        delete(fig)
    end
    %%%% Callbacks to grab wavelength values from lookup for each field
    function OK1Callback(varargin)
        value=probe(diaCalibrate);
        Wavelength1Edit=h1(2);
        idx = strcmp(Lines(:,1),value{2});
        set(Wavelength1Edit,'String',strcat(num2str(Lines{idx,2}),','));        
    end

    function OK2Callback(varargin)
        value=probe(diaCalibrate);
        Wavelength2Edit=h2(2);
        idx = strcmp(Lines(:,1),value{4});
        set(Wavelength2Edit,'String',strcat(num2str(Lines{idx,2}),','));        
    end
    function OK3Callback(varargin)
        value=probe(diaCalibrate);
        Wavelength3Edit=h3(2);
        idx = strcmp(Lines(:,1),value{6});
        set(Wavelength3Edit,'String',strcat(num2str(Lines{idx,2}),','));        
    end
    function OK4Callback(varargin)
        value=probe(diaCalibrate);
        Wavelength4Edit=h4(2);
        idx = strcmp(Lines(:,1),value{8});
        set(Wavelength4Edit,'String',strcat(num2str(Lines{idx,2}),','));        
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nonlinear least squares residual function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [chi2,yfit]=residual(NLparams,x,y,twod)
x0 = NLparams(1);
rC = NLparams(2);

yfit = twod*sin((x(:)-x0)/rC);

% calculate residual error
chi2=sum((y(:)-yfit).^2);

end

