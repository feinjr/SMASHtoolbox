%% StrengthGUI is a GUI interface for analyzing the strength in release experiments

function StrengthGUI()

%% Initialize Variables

%% Use signal group to store information about the Lagrangian analysis
%% >>(time, [u cl density stress])
sig = {};
fit = {};
sig_tot = 0; pathname = [];
sig_num = [];
view = 'Cl-u';
viewlist = {'Cl-u','Stress-Strain','Stress-Density','Cl-Strain','Strain-Time','StrainRate-Time','Custom'};



%% Set system defaults
%set(0,'DefaultAxesFontSize',14);
%set(0,'DefaultUIControlFontSize',14);

% create figure if not already running
check=findobj('Name','SMASH Strength Analysis');
if ishandle(check) % program is already running
    disp('GUI already running!');
    figure(check);
    return;
end

fig = SMASH.MUI.Figure; fig.Hidden = true;
fig.Name = 'SMASH Strength Analysis';
set(fig.Handle,'Tag','StrengthGUI');
set(fig.Handle,'Units','normalized');
set(fig.Handle,'Position',[0.1 0.1 .7 .75]);
set(fig.Handle,'Toolbar','figure');
set(fig.Handle,'Color',[.95 .95 .95]);
ha=axes('Parent',fig.Handle,'Units','normalized','OuterPosition',[0 0 1 1]);


%Create active signal toolbar button using Matlab icon
[X map] = imread(fullfile(...
    matlabroot,'toolbox','matlab','icons','HDF_VData.gif'));
    % Convert indexed image and colormap to truecolor
    icon = ind2rgb(X,map);
ht=uipushtool('Parent',fig.ToolBar,'Separator','on',...
    'Tag','Clear','ToolTipString','Select Signals',...
    'CData',icon,'ClickedCallback',@ActiveSignal);


%Create clear toolbar button using Matlab icon
[X map] = imread(fullfile(...
    matlabroot,'toolbox','matlab','icons','HDF_filenew.gif'));
    % Convert indexed image and colormap to truecolor
    icon = ind2rgb(X,map);
ht=uipushtool('Parent',fig.ToolBar,'Separator','off',...
    'Tag','Clear','ToolTipString','Clear all signals',...
    'CData',icon,'ClickedCallback',@ClearCallback); 


%% create Signal menu
hm=uimenu(fig.Handle,'Label','Signal');
uimenu(hm,'Label','Load','Callback',@LoadSignal);
uimenu(hm,'Label','Labels','Callback',@Label);
uimenu(hm,'Label','Comment','Callback',@Comment);
uimenu(hm,'Label','Save','Callback',@SaveSignal);


%% Define bulk wavespeed
hm=uimenu(fig.Handle,'Label','Bulk Wavespeed Definition');
uimenu(hm,'Label','Plot Current Fit','Callback',@PlotFit);
uimenu(hm,'Label','MieGruneisen','Callback',@MGFit);
uimenu(hm,'Label','Tabular EOS','Callback',@TabularFit);
uimenu(hm,'Label','Fit Data','Callback',@BulkFit);
uimenu(hm,'Label','Save Fit','Callback',@SaveFit);

%% Signal Manipulation
hm=uimenu(fig.Handle,'Label','Edit Signals');
uimenu(hm,'Label','Wavespeed Shift','Callback',@WavespeedShift);
uimenu(hm,'Label','Limit','Callback',@Clip);
uimenu(hm,'Label','Average Cl-u','Callback',@Average);


%% Strength Calculation Menu
hm=uimenu(fig.Handle,'Label','Strength Analyses');
uimenu(hm,'Label','Hyrdrost offset','Callback',@HydroOffset);
uimenu(hm,'Label','Shear stress integration','Callback',@StrengthIntegration);




%% create Plotting menu
hm=uimenu(fig.Handle,'Label','Plot');
uimenu(hm,'Label','Update Line Properties','Callback',@UpdateLineProp);
uimenu(hm,'Label','Edit Signal Order','Callback',@EditOrder);
uimenu(hm,'Label','Large AIP Figure','Callback',@BigPlot);
uimenu(hm,'Label','Single column AIP Figure','Callback',@AIPFigure1);
uimenu(hm,'Label','Double column AIP Figure','Callback',@AIPFigure2);

fig.Hidden = false;


%% Clear callack
function ClearCallback(varargin)
        sig = {};
        fit = {};
        sig_tot = 0;
        figure(fig.Handle); cla; legend('off');

        fighandles = findobj('type','figure');
        fignames = get(fighandles,'name');
        if ~iscell(fignames); fignames = {fignames}; end;
        for i = 1:numel(fignames)
            if strcmp(fignames{i}, 'Active Signal')
                delete(fighandles(i));
            end
        end
end

%% Active signal callback
function ActiveSignal(src,varargin)     

% see if dialog already exists
dlg=FindOrCreateDlg(src,'ActiveDialog');
if ishandle(dlg)
    %location = get(dlg,'OuterPosition');
    return;
end


dlg.Hidden = true;
dlg.Name = 'Active Signal';

h=addblock(dlg,'listbox','Select View',viewlist);

slist={};
for i =1:sig_tot; slist{i}=sig{i}.Name; end
h=addblock(dlg,'listbox','Select Signal(s)',slist);

%Set multiple selection option (for all in dlg)
dlg_hc = get(dlg.Handle,'Children');
set(dlg_hc,'Max',2);
h=addblock(dlg,'button',{ 'Apply', 'Delete','Cancel'});

%Define callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       view = probe(dlg); view = view{1}; 
       sig_num=get(dlg_hc(1),'Value');
       sig = plotdata(fig.Handle,sig,sig_num,view);
       
       %Update if new signal has been added
       if (numel(sig) > numel(get(dlg_hc(1),'String')))
        delete(dlg); ActiveSignal(src,'ActiveDialog');
       end
    end
    
    set(h(2),'Callback',@DeleteCallback);
    function DeleteCallback(varargin)
        sig_del=get(dlg_hc(1),'Value');
        delete(dlg);
        
        %Renumber signals
        new_num = 1; new_sig={};
        check = ~ismember([1:sig_tot],sig_del);
        for i=1:sig_tot;
            if check(i)
                new_sig{new_num}=sig{i}; 
                new_num=new_num+1;
            end
        end
        
        %Clear old signals then update
        clear sig; sig = new_sig; clear new_sig;
        sig_tot = numel(sig);
        sig_num = [1:sig_tot];
        
        %If all signals were deleted, reset
        if new_num == 1
            sig = {};
            sig_tot = 0;
            figure(fig.Handle); cla; legend('off');
            return;
        end
            
        plotdata(fig.Handle,sig,sig_num,view);      
        ActiveSignal(0);
    end
    
    set(h(3),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
    

locate(dlg,'east');
dlg.Hidden = false;

end %Choose Active Signals

%% Load callback
function LoadSignal(src,varargin)     

%Pick file
[filename, pathname, filterindex] = uigetfile({'*.*',  'All Files (*.*)'}, ...
    'Pick Signal(s)', 'MultiSelect', 'on');

if (~filterindex); return; end  %Pressed cancel

%Determine how many files selected
if ~iscellstr(filename); filename={filename}; end
numfiles = length(filename);

%Create waitbar
wb=SMASH.MUI.Waitbar('Loading Signals');


%Loop through and load
for i=1:numfiles
    
    %Load .sda record
    [~,~,ext]=fileparts(filename{i});
    if strcmp(ext,'.sda')
        %Probe file
        SDAobj =  SMASH.FileAccess.SDAfile(fullfile(pathname,filename{i}));
        [label,type,description,status] = probe(SDAobj);
        
        for ii = 1:length(label)
             %Advance to next record
             update(wb,(ii*i)/(numfiles*length(label)));
             sig_tot = sig_tot+1;
             sig{sig_tot} = SMASH.SignalAnalysis.SignalGroup(fullfile(pathname,filename{i}),'sda', label{ii});
        end
        
    %Load ascii file    
    else
        %Advance to next signal
        sig_tot = sig_tot+1;
        
        %Hardcode "ImportFile"
        source=SMASH.FileAccess.ColumnFile(fullfile(pathname,filename{i}));
        data=read(source);
        p = probe(source); 

        [~,iu] = unique(data.Data(:,1));
        
        % [u,cl] -- At minimum require u, cl, and rho0
        if p.NumberColumns == 2
            u = data.Data(iu,1);
            t = (1:numel(u))';
            cl = data.Data(iu,2);
            ans = inputdlg('Enter initial density','Wavespeed Integration',1);
            rho0 = str2num(ans{1});
            [dens stress] = integrateClu(rho0,u,cl);
        % [c, cl, dens, stress] -- CHARICE Output
        elseif p.NumberColumns == 4
            u = data.Data(iu,1);
            t = 1:numel(u);
            cl = data.Data(iu,2);
            dens = data.Data(iu,3);
            stress = data.Data(iu,4);
            
        % [t, c, cl, dens, stress] -- Current Default
        elseif p.NumberColumns == 5
            t = data.Data(iu,1);
            u = data.Data(iu,2);
            cl = data.Data(iu,3);
            dens = data.Data(iu,4);
            stress = data.Data(iu,5);
        
        % [t, c, cl, dens, stress] -- Reduces output
        elseif p.NumberColumns == 6
            ans = inputdlg('Enter initial density','Wavespeed Integration',1);
            rho0 = str2num(ans{1});
            t = data.Data(iu,1);
            u = data.Data(iu,5);
            cl = data.Data(iu,2);
            dens = rho0./(1-data.Data(iu,4)); dens(1)=rho0;
            stress = data.Data(iu,3);
            
        
        % [t, uw,up,cl, ce, stress,volume,strain,strainrate] -- Old Default
        elseif p.NumberColumns >= 9 
            t = data.Data(iu,1);
            u = data.Data(iu,3);
            cl = data.Data(iu,4);
            dens = 1./data.Data(iu,7);
            stress = data.Data(iu,6);          
        end
        
        
        sig{sig_tot} = SMASH.SignalAnalysis.SignalGroup(t,[u,cl,dens,stress]);
        %Set some object properties
        [~,name,ext]=fileparts(filename{i});
        if length(ext) > 4; name = [name ext]; end
        sig{sig_tot}.Name = name;
        sig{sig_tot}.GraphicOptions.LineWidth=3;
        sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);

        fit{sig_tot} = SMASH.SignalAnalysis.SignalGroup(0,[0 0 0 0]);
        
        %update waitbar and exit if it doesn't exist
        if ~ishandle(wb.Handle); return; end;
        update(wb,i/numfiles);
    end
end
delete(wb);

%Set active signals to all and plot
sig_num = [1:sig_tot];
plotdata(fig.Handle,sig,sig_num,view);

    
end %Load Signal
%%%%%%%%%%% Signal menu %%%%%%%%%%%%%
%% Label signal callback
function Label(src,varagin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'LabelDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Label Signal';

%Create edit box for each signal
for i=1:numel(sig_num)
    h=addblock(dlg,'edit',sig{sig_num(i)}.Name);
end
h=addblock(dlg,'button',{ 'Apply Label Change', 'Cancel'});
dlg.Hidden = false

%Define button callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       newnames = probe(dlg);
       for i=1:numel(sig_num)
        if ~isempty(newnames{i})
            sig{sig_num(i)}.Name = newnames{i};
        end
       end
    plotdata(fig.Handle,sig,sig_num,view);
    delete(dlg);
    end
    
    set(h(2),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
end %Label 

%% Comment signal callback
function Comment(src,varagin)

    for i=1:numel(sig_num)
        sig{sig_num(i)}=comment(sig{sig_num(i)});
    end

end %comment

%% Save signal callback
function SaveSignal(src,varargin)     
   Save(sig,sig_num);
end %Save




%%%%%%%%%%% Bulk wavespeed menu %%%%%%%%%%%%%
%% Plot the current fit
function PlotFit(src,varargin)
    
    sig = plotdata(fig.Handle,sig,sig_num,view);
    fit = plotdata(fig.Handle,fit,sig_num,view,'overlay');

end

%% Mie-Gruneisen Bulk Fit
function MGFit(src,varargin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'MGFit');
if ishandle(dlg)
    return
end 
dlg.Name = 'Mie-Gruneisen Bulk Wavespeed Definition';
dlg.Hidden = true;   

%sampleoptions = {'Aluminum','Copper','Tantalum','Molybdenum','Beryllium','LiF','Stainless Steel','Gold'};
[~,~,~,~,~,~,sampleoptions] = getHugProp('DefinedSamples');
h=addblock(dlg,'listbox','Select Sample',sampleoptions);

h=addblock(dlg,'button',{'Apply','Cancel'});
%Define callbacks
set(h(1),'Callback',@ApplyCallback);
function ApplyCallback(varargin)
     value = probe(dlg);
    [rho0 c0 s g0 Iu Ic] = getHugProp(value{1});
    [dens, stress] = integrateClu(rho0,Iu,Ic);
 
    for i = 1:numel(sig_num)
        [time, data] = limit(sig{sig_num(i)});
        range = find(Iu < max(data(:,1))*1.1);
        fit{sig_num(i)} = SMASH.SignalAnalysis.SignalGroup(1:numel(Iu(range)),[Iu(range),Ic(range),dens(range),stress(range)]);
        fit{sig_num(i)} .Name = [sig{sig_num(i)}.Name '_MGfit'];
    end
    
    plotdata(fig.Handle,sig,sig_num,view);
    plotdata(fig.Handle,fit,sig_num,view,'overlay');

end


set(h(2),'Callback',@CancelCallback);
function CancelCallback(varargin)
    delete(dlg);  
end
   

locate(dlg,'east');
dlg.Hidden=false;
    
end

%% Load Tabular EOS into fit
function TabularFit(src,varargin)

    cdir = pwd;
    [filename pathnameEOS] = uigetfile('*','All Files','Select Tabular File');
    cd(cdir);
    source=SMASH.FileAccess.ColumnFile(fullfile(pathnameEOS,filename));
    data=read(source);
    p = probe(source); 
    [header]=strread(data.Header{1},'%s');

    if strcmp(header{1},'!'); 
        for i = 1:length(header)-1
            temp{i}= header{i+1};
        end
        header = temp;
    end
    
    assert(length(header) == p.NumberColumns,'header not consistent with number of columns');
    u = []; c =[]; dens =[]; stress = []; ce = [];
    for i = 1:numel(header)
        if strncmp(lower(header{i}),'rho',3) | strncmp(lower(header{i}),'dens',3) 
            dens = data.Data(:,i);
        elseif strncmp(lower(header{i}),'p(',1) |strncmp(lower(header{i}),'pressure',8)
            stress = data.Data(:,i);
        elseif strncmp(lower(header{i}),'cs',2)
            ce = data.Data(:,i);
        elseif strncmp(lower(header{i}),'up',2) | strncmp(lower(header{i}),'particle',8)
            u = data.Data(:,i);
        elseif strncmp(lower(header{i}),'cl',2) | strncmp(lower(header{i}),'wave',4)
            c = data.Data(:,i);
        end
    end
    
    % Cl-up file - must enter density
    if isempty(dens)
            ans = inputdlg('Enter initial density','Wavespeed Integration',1);
            rho0 = str2num(ans{1});
            [dens stress] = integrateClu(rho0,u,cl);
    end
    
    % Tabular adiabats often only have Eulerian wavespeed
    if isempty(c) & ~isempty(ce)
        c = ce.*dens./dens(1);
    end
    
    % Some tabular adiabats do not have particle velocity
    if isempty(u)
        u = cumtrapz(stress,1./(dens(1).*c));
    end

    
    for i = 1:numel(sig_num)
        [time data] = limit(sig{sig_num(i)});
        range = find(u < max(data(:,1))*1.1);
        fit{sig_num(i)} = SMASH.SignalAnalysis.SignalGroup(1:numel(u(range)),[u(range),c(range),dens(range),stress(range)]);
        fit{sig_num(i)}.Name = [sig{sig_num(i)}.Name '_MGfit'];
    end
    
    plotdata(fig.Handle,sig,sig_num,view);
    plotdata(fig.Handle,fit,sig_num,view,'overlay');

end

%% Polynomial fit to data
function BulkFit(src,varargin)

view = 'Cl-u'; PlotFit([]);
    
% see if dialog already exists
dlg=FindOrCreateDlg(src,'BulkFit');
if ishandle(dlg)
    return
end 
dlg.Name = 'Polynomial Bulk Wavespeed Fitting';
dlg.Hidden = true;   

h=addblock(dlg,'edit_check',{'Polynomial Order','Unload Fit'}); set(h(2),'String', 1);
h=addblock(dlg,'edit','x min       '); set(h(2),'String', 0);
h=addblock(dlg,'edit','x max       '); set(h(2),'String', 0);
h=addblock(dlg,'button','SelectPoints');
set(h(1),'Callback',@selectpoints);
dlg_hc = get(dlg.Handle,'Children');
function [varargout] = selectpoints(varargin)
    figure(fig.Handle); 
    [xpick ypick] = ginput(2);
    figure(dlg.Handle);
    set(dlg_hc(4),'String',num2str(min(xpick)));
    set(dlg_hc(2),'String',num2str(max(xpick)));
end

hpoly='notahandle';
h=addblock(dlg,'check','Enter Poly Coefficients');
set(h(1),'Callback',@editpoly);
function [varargout] = editpoly(varargin)
    value = probe(dlg);
    if ~ishandle(hpoly)
        
        %Calculate coefficients for current fit
        value = probe(dlg);
        porder = str2double(value{1});
        [time,data] = limit(fit{sig_num(1)});
        pfit = polyfit(data(:,1), data(:,2), porder);
        
        for i = 1:str2num(value{1})+1
            hpoly = addblock(dlg,'edit',sprintf('p%i     ',i));
            set(hpoly(2),'String', num2str(pfit(i)));
        end
        
    end
end


h=addblock(dlg,'button',{'Apply','Cancel'});
%Define callbacks
set(h(1),'Callback',@ApplyCallback);
function ApplyCallback(varargin)
     value = probe(dlg);
     porder = str2double(value{1});
     umin = str2double(value{3});
     umax = str2double(value{4});
     get(dlg_hc,'String');
 
    for i = 1:numel(sig_num)
        [time data] = limit(sig{sig_num(i)});
        [datamax, im] = max(data(:,1));
        if ~value{2}
            fitrange = find(data(1:im,1) >=umin & data(1:im,1) <=umax);
        else
            fitrange = find(data(im:end,1) >=umin & data(im:end,1) <=umax);
            fitrange = fitrange+im-1;
        end
        if ~value{5}
            pfit = polyfit(data(fitrange,1), data(fitrange,2), porder)
        else
            pfit = [];
            for j = 1:porder+1
                pfit = [pfit str2double(value{5+j})];
            end
            pfit
        end
        
        u = linspace(0,datamax*1.1,2e3)';
        c = polyval(pfit,u);
        [dens stress] = integrateClu(data(1,3),u,c);
        fit{sig_num(i)} = SMASH.SignalAnalysis.SignalGroup(1:numel(u),[u,c,dens,stress]);
        fit{sig_num(i)} .Name = [sig{sig_num(i)}.Name '_Polyfit'];       
    end
    
    plotdata(fig.Handle,sig,sig_num,view);
    plotdata(fig.Handle,fit,sig_num,view,'overlay');

end


set(h(2),'Callback',@CancelCallback);
function CancelCallback(varargin)
    delete(dlg);  
end
   

locate(dlg,'east');
dlg.Hidden=false;
    
end

%% Save fit callback
function SaveFit(src,varargin)     
   Save(fit,sig_num);
end %Save


%%%%%%%%%%% Signal Editing %%%%%%%%%%%%%

%% Average Signals
function Average(src,varagin)
    
    view = 'Cl-u'; sig = plotdata(fig.Handle,sig,sig_num,view);  
    
    %Global max/min
    for i=1:numel(sig_num)
        [time, data] = limit(sig{sig_num(i)});
        maxu = max(data(:,1));
        minu = min(data(:,1));
        maxu_tot(i) = maxu;
        minu_tot(i) = minu;
    end
        minu = min(minu_tot);
        maxu = max(maxu_tot);
        u = linspace(minu,maxu,2e3)';
        
    %Average using available signal (0 if out of range)
    for i=1:numel(sig_num)
        [time, data] = limit(sig{sig_num(i)});
        cl{i} = interp1(data(:,1),data(:,2),u,'linear',0);
        rho0(i) = data(1,3);
    end

    %Average each point, ignoring zeros
    for n = 1:length(u)
        count = 0; cl_tot = 0; 
        for i = 1:length(sig_num);
            if cl{i}(n) > 0
                count = count+1;
                cl_tot(count) =cl{i}(n);
            end
        end
        cl_avg(n)=mean(cl_tot); cl_avg = cl_avg';
        cl_std(n)=std(cl_tot); cl_std = cl_std';
    end
    
    %Plot standard deviation of fit
    figure; plot(u,cl_std./cl_avg*100); xlabel('u'); ylabel('Standard Deviation (%)');
   
    rho0 = mean(rho0);
    options.Resize='on';
    ans = inputdlg({'Ambient Density','Starting Strain','Starting Stress'},'Wavespeed Integration',1,{num2str(rho0),num2str(rho0),'0'},options);
    rho0 = str2num(ans{1});
    strain0 = str2num(ans{2});
    stress0 = str2num(ans{3});
    
    %If starting stress is > 0 then unloading
    if stress0 > 1e-3
        u=flipud(u);
        cl_avg = flipud(cl_avg);
        t=(1+numel(u):2*numel(u))';
    else
        t = (1:numel(u))';
    end
    
    [dens stress] = integrateClu(rho0,u,cl_avg,strain0,stress0); 
    
    
    %Create new averaged signal
    sig_tot = sig_tot+1;
    sig{sig_tot} = SMASH.SignalAnalysis.SignalGroup(t,[u,cl_avg,dens,stress]);
    %Set some object properties
    sig{sig_tot}.Name = 'Averaged Wavespeed';
    sig{sig_tot}.GraphicOptions.LineWidth=3;
    sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);
    fit{sig_tot} = SMASH.SignalAnalysis.SignalGroup(0,[0 0 0 0]);
    
    %Set active signals to all and plot
    sig_num = [1:sig_tot];
    plotdata(fig.Handle,sig,sig_num,view);
    
    
    
end %comment

%% Wavespeed Shift
function WavespeedShift(src,varagin)
    
view = 'Cl-u'; PlotFit([]);    

% see if dialog already exists
dlg=FindOrCreateDlg(src,'WavespeedShift');
if ishandle(dlg)
    return
end 
dlg.Name = 'WavespeedShift';
dlg.Hidden = true;   

h=addblock(dlg,'edit','Shift       '); set(h(2),'String', 0);
OkApplyCancel(dlg,@applyshift,'overlay');

    
function newsig = applyshift(n)    
        value = probe(dlg);
        shift = str2double(value{1});
             
        [time data] = limit(sig{n});

        data(:,2) = data(:,2)+shift;
        
        rho0 = data(:,3);
        [data(:,3) data(:,4)] = integrateClu(rho0,data(:,1),data(:,2));
        

        newsig = SMASH.SignalAnalysis.SignalGroup(time,data);
        %Set some object properties
        newsig.Name = sig{n}.Name;
        newsig.GraphicOptions = sig{n}.GraphicOptions;
       
end

dlg.Hidden = false;   

end %comment

%% Clip signals
function Clip(src,varagin)
    
view = 'Cl-u'; PlotFit([]);

% see if dialog already exists
dlg=FindOrCreateDlg(src,'Limit');
if ishandle(dlg)
    return
end 
dlg.Name = 'Limit';
dlg.Hidden = true;   

h=addblock(dlg,'edit','x min       '); set(h(2),'String', 0);
h=addblock(dlg,'edit','x max       '); set(h(2),'String', 0);
h=addblock(dlg,'button','SelectPoints');
set(h(1),'Callback',@selectpoints);
dlg_hc = get(dlg.Handle,'Children');


h=addblock(dlg,'check','Unloading'); 
OkApplyCancel(dlg,@applylimit,'overlay');

function [varargout] = selectpoints(varargin)
    figure(fig.Handle); 
    [xpick ypick] = ginput(2);
    figure(dlg.Handle);
    set(dlg_hc(4),'String',num2str(min(xpick)));
    set(dlg_hc(2),'String',num2str(max(xpick)));
end
    
function newsig = applylimit(n)    
        value = probe(dlg);
        minval = str2double(value{1});
        maxval = str2double(value{2});
             
        newsig = sig{n};
        [time data] = limit(newsig);
        [~,im] = max(data(:,1));
        
        %Find time values corresponding to selection
        if ~value{3}
            if minval < min(data(1:im,1)); minval = min(data(1:im,1)); end
            if maxval > max(data(1:im,1)); maxval = max(data(1:im,1)); end
            t1 = interp1(data(1:im,1),time(1:im),minval);
            t2 = interp1(data(1:im,1),time(1:im),maxval);
        else
            if minval < min(data(im:end,1)); minval = min(data(im:end,1)); end
            if maxval > max(data(im:end,1)); maxval = max(data(im:end,1)); end
            t1 = interp1(data(im:end,1),time(im:end),minval);
            t2 = interp1(data(im:end,1),time(im:end),maxval);
        end
            

        %Apply limit
        newsig = limit(newsig,sort([t1 t2]));
       
end


dlg.Hidden = false;   

end %comment




%%%%%%%%%%% Strength Calculations %%%%%%%%%%%%%

%% Strength from hydrostat offset
function HydroOffset(src,varargin)
    
% see if dialog already exists
    dlg=FindOrCreateDlg(src,'HydroOffset');
    if ishandle(dlg)
        return
    end 
    dlg.Name = 'HydroOffset';
    dlg.Hidden = true;   

    h=addblock(dlg,'check','Load/Unload offset');
    h=addblock(dlg,'button',{'Apply','Save','Cancel'});
    
    save = [];
    %Define callbacks
    set(h(1),'Callback',@ApplyCallback);
    set(h(2),'Callback',@SaveCallback);
    set(h(3),'Callback',@CancelCallback);
    
    function ApplyCallback(varargin)
        value = probe(dlg);
        
        figure(fig.Handle);cla; Y = [];
        
        
        for i = 1:length(sig_num)
            
            [time data] = limit(sig{sig_num(i)});
            
            %Use path and fit offsets
            if ~value{1}
                [time bfit] = limit(fit{sig_num(i)});
                assert(numel(bfit) > 5,sprintf('Fit does not exist for signal %i',sig_num(i)));
                
                strain = 1-data(1,3)./data(:,3);
                strainfit = 1-bfit(1,3)./bfit(:,3);
                pressure = interp1(strainfit,bfit(:,4),strain);
                Y= (data(:,4)-pressure)*3/2;
                lc = sig{sig_num(i)}.GraphicOptions.LineColor;
                line(strain,Y,'LineWidth',3,'Color',lc);
                
                
                errorup = (data(:,4).*1.02-pressure.*.99)*3/2;
                errordown = (data(:,4).*0.99-pressure.*1.02)*3/2;
                %Y=errordown;
                
                save{i} = [strain pressure Y];
                
                line(strain,errorup,'LineWidth',2,'LineStyle','--','Color',lc);
                line(strain,errordown,'LineWidth',2,'LineStyle','--','Color',lc);

                
            % Difference between loading and unloading
            else
                strain = 1-data(1,3)./data(:,3);
                [maxe,im] = max(strain);
                Y = 3/4*(interp1(strain(1:im),data(1:im,4),strain(im:end))-data(im:end,4));    
                lc = sig{sig_num(i)}.GraphicOptions.LineColor;
                line(strain(im:end),Y,'LineWidth',3,'Color',lc);
                save{i} = [strain(im:end) Y];
            end
        end
        xlabel('strain');ylabel('Y');
        figure(dlg.Handle);
    end
    
    function SaveCallback(varargin)
      
       for i = 1:length(save)
        [savename, savepath] = uiputfile({'*.dat;*.txt;*.out','All ASCII Files'; '*.sda','SandiaDataArchive'; ...
        '*.*','All Files'}, sprintf('Save Signal #%i',sig_num(i)),sig{sig_num(i)}.Name);          
         saveloc = fullfile(savepath,savename);
            fid=fopen(saveloc,'w');       
            fprintf(fid,'strain\tP\tY\n'); 
            dlmwrite(saveloc, [save{i}(:,1) save{i}(:,2) save{i}(:,3)],'-append','delimiter','\t','precision','%10.6f');
            fclose(fid);
           
       end 
    end

    function CancelCallback(varargin)
        delete(dlg);  
    end
    dlg.Hidden = false;  

end

%% Local change in shear stress integration
function StrengthIntegration(src,varargin)
    
    view = 'Cl-u'; PlotFit([]);

    % see if dialog already exists
    dlg=FindOrCreateDlg(src,'ShearStressInegration');
    if ishandle(dlg)
        return
    end 
    dlg.Name = 'ShearStressInegration';
    dlg.Hidden = true;   
    
    h=addblock(dlg,'check','strain space'); 
    set(h(1),'Callback',@switchspace);
    function [varargout] = switchspace(varargin)
        value = probe(dlg);
        if value{1}
            figure(fig.Handle); view = 'Cl-Strain'; PlotFit([]);
            figure(dlg.Handle);
        else
            figure(fig.Handle); view = 'Cl-u'; PlotFit([]);
            figure(dlg.Handle);
        end
    end
    
    [time data] = limit(sig{sig_num(1)});
    h=addblock(dlg,'edit','initial density'); set(h(2),'String', num2str(data(1,3)));
    h=addblock(dlg,'edit','integration min'); set(h(2),'String', 0);
    h=addblock(dlg,'edit','integration max'); set(h(2),'String', num2str(max(data(:,1))));
    h=addblock(dlg,'button','Select Points');
    set(h(1),'Callback',@selectpoints);
    dlg_hc = get(dlg.Handle,'Children');
    function [varargout] = selectpoints(varargin)
        figure(fig.Handle); 
        [xpick ypick] = ginput(2);
        figure(dlg.Handle);
        set(dlg_hc(4),'String',num2str(min(xpick)));
        set(dlg_hc(2),'String',num2str(max(xpick)));
    end

    h=addblock(dlg,'button',{'Integrate','Cancel'});
    set(h(1),'Callback',@PerformIntegration);
    function PerformIntegration(varargin)
        value = probe(dlg);
        rho0 = str2num(value{2});
        
        if value{1}
            figure(fig.Handle); view = 'Cl-Strain'; PlotFit([]);
            
            for i = 1:length(sig_num)
                emin = str2double(value{3}); 
                emax = str2double(value{4});
                [time data] = limit(sig{sig_num(i)});
                [time bfit] = limit(fit{sig_num(i)});
                assert(numel(bfit) > 5,sprintf('Fit does not exist for signal %i',sig_num(i)));
                strain = 1-data(1,3)./data(:,3);
                strainfit = 1-bfit(1,3)./bfit(:,3);
                [emaxd im] = max(strain);
                
                if emax > emaxd; emax = emaxd; end;
                e=linspace(emin,emax,5e3)';
                strainunload = strain(im:end); clunload = data(im:end,2);
                [~,iu] = unique(strainunload);
                cl = interp1(strainunload(iu),clunload(iu),e);
                cb = interp1(strainfit,bfit(:,2),e);

                line(e,cl,'Color','r','LineStyle','--','LineWidth',2);
                line(e,cb,'Color','g','LineStyle','--','LineWidth',2);

                Y=3/4.*rho0.*trapz(e,(cl.^2-cb.^2))

                str = sprintf('\\Delta\\tau=%f\n\n\\epsilon_{max}=%f\n\n\\sigma_{max}=%f\n\n\\epsilon_{trans}=%f',...
                   Y,max(strain),max(data(:,4)),emin);
                lc = sig{sig_num(i)}.GraphicOptions.LineColor;
                th=text((min(strain)+max(strain))/2,(max(cb)+max(cl))/2,str,'Color',lc,'FontSize',20);


            end
            
        else
        
            figure(fig.Handle); view = 'Cl-u'; PlotFit([]);
            for i = 1:length(sig_num)
                umin = str2double(value{3}); 
                umax = str2double(value{4});
                [time data] = limit(sig{sig_num(i)});
                [time bfit] = limit(fit{sig_num(i)});
                assert(numel(bfit) > 5,sprintf('Fit does not exist for signal %i',sig_num(i)));

                [umaxd im] = max(data(:,1));
                if im == length(data(:,1)); im = 1; end;
                if umax > umaxd; umax = umaxd; end;

                u=linspace(umin,umax,5e3)';
                uunload = data(im:end,1); clunload = data(im:end,2);
                
                %Loading fit
                if umin < min(uunload)
                    uunload = data(1:im,1); clunload=data(1:im,2);
                end
                
                [~,iu] = unique(uunload);
                cl = interp1(uunload(iu),clunload(iu),u);
                cb = interp1(bfit(:,1),bfit(:,2),u);

                line(u,cl,'Color','r','LineStyle','--','LineWidth',2);
                line(u,cb,'Color','g','LineStyle','--','LineWidth',2);

                Y=3/4.*rho0.*trapz(u,(cl.^2-cb.^2)./cl)

                strain = 1-data(1,3)./data(:,3);
                u1 = find(data(:,1)>=umax); u1 = u1(end);
                u2 = find(data(:,1)>=umin); u2 = u2(end);

                str = sprintf('\\Delta\\tau=%f\n\n\\epsilon_{max}=%f\n\n\\sigma_{max}=%f\n\n\\epsilon_{trans}=%f',...
                   Y,max(strain),max(data(:,4)),strain(u2));
                lc = sig{sig_num(i)}.GraphicOptions.LineColor;
                th=text((max(data(:,1))+min(data(:,1)))/2,(max(cb)+max(cl))/2,str,'Color',lc,'FontSize',20);


            end
        end
        figure(dlg.Handle);
    end
    
    set(h(2),'Callback',@CancelCallback);
    function CancelCallback(varargin)
    delete(dlg);  
    end
    
    dlg.Hidden = false; 

end




%%%%%%%%%%% Plotting %%%%%%%%%%%%%
%% Update Line Properties
function UpdateLineProp(src,varargin)

%% Save current line properties to signal
lh = findobj(gca,'Type','line');
if ~isempty(lh)
    color = get(lh,'Color');
    if ~iscell(color); color = {color}; end;
    style = get(lh,'LineStyle');
    if ~iscell(style); style = {style}; end;
    width = get(lh,'LineWidth');
    if ~iscell(width); width = {width}; end;
    mark = get(lh,'Marker');
    if ~iscell(mark); mark = {mark}; end;

    %Update as long as signal numbering is OK
    if (numel(color) == numel(sig_num))
        for i = 1:numel(sig_num);
            index = numel(color)+1-i;
            sig{sig_num(i)}.GraphicOptions.LineWidth=width{index,1};
            sig{sig_num(i)}.GraphicOptions.LineColor=color{index,1};
            sig{sig_num(i)}.GraphicOptions.LineStyle=style{index,1};
            sig{sig_num(i)}.GraphicOptions.Marker=mark{index,1};
        end
    end
end
end %Update line properties
%% Signal order callback
function EditOrder(src,varagin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'OrderDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Order Signal';
locate(dlg,'south');

%Create edit box for each signal
for i=1:numel(sig_num)
    h=addblock(dlg,'edit',sig{sig_num(i)}.Name); set(h(2),'String', num2str(i));
end
h=addblock(dlg,'button',{ 'Apply Order Change', 'Cancel'});
dlg.Hidden = false;

%Define button callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       values = probe(dlg); newindex =[];
       for i = 1:numel(values);
           newindex(i)=int32(str2num(values{i}));
       end

       if ~isequal(numel(unique(newindex)),numel(sig_num));
           h = addblock(dlg,'text',sprintf('Not a valid index selection. Require %i distinct integers',numel(sig_num)));
           return;
       end
       
       newsig = {};
       numel(sig_num)
       for i = 2:numel(sig_num)
           newsig{i} = SMASH.SignalAnalysis.SignalGroup(0,[0 0 0 0]);
       end
       
       for i=1:numel(sig_num)
            newsig{newindex(i)} = sig{sig_num(i)};
       end
       sig = newsig;
       clear newsig;

       plotdata(fig.Handle,sig,sig_num,view);
       delete(dlg);
    end
    
    set(h(2),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
end %Order 
%% Large plot 
function BigPlot(src,varargin)
    AIPFig = SMASH.Graphics.AIPfigure(4,'11in');
    set(AIPFig,'name','AIP Large Fig');
    
    plotdata(AIPFig,sig,sig_num,view);
    %plotdata(AIPFig,fit,sig_num,view,'overlay');

    set(gca,'FontName','times','FontAngle','normal','LineWidth',2.5,'FontSize',30);
    set(gcf,'Color','w');
    xlabel(sig{sig_num(1)}.GridLabel,'FontName','times','FontAngle','normal','FontSize',40);
    ylabel(sig{sig_num(1)}.DataLabel,'FontName','times','FontAngle','normal','FontSize',40);
end

%% Single column AIP
function AIPFigure1(src,varargin)
    AIPFig = SMASH.Graphics.AIPfigure(1);
    set(AIPFig,'name','AIP Single Column Fig');
    
    for i=1:length(sig_num); sig{sig_num(i)}.GraphicOptions.LineWidth=1; end;
    plotdata(AIPFig,sig,sig_num,view);
    plotdata(AIPFig,fit,sig_num,view,'overlay');
    for i=1:length(sig_num); sig{sig_num(i)}.GraphicOptions.LineWidth=3; end;
    
    set(gca,'FontName','times','FontAngle','normal','FontSize',10);
    set(gcf,'Color','w');
    xlabel(sig{sig_num(1)}.GridLabel,'FontName','times','FontAngle','normal','FontSize',12);
    ylabel(sig{sig_num(1)}.DataLabel,'FontName','times','FontAngle','normal','FontSize',12);

end

%% Double column AIP
function AIPFigure2(src,varargin)
    AIPFig = SMASH.Graphics.AIPfigure(2);
    set(AIPFig,'name','AIP Double Column Fig');
    
    for i=1:length(sig_num); sig{sig_num(i)}.GraphicOptions.LineWidth=1; end;
    plotdata(AIPFig,sig,sig_num,view);
    plotdata(AIPFig,fit,sig_num,view,'overlay');
    for i=1:length(sig_num); sig{sig_num(i)}.GraphicOptions.LineWidth=1; end;
    
    set(gca,'FontName','times','FontAngle','normal','FontSize',10);
    %box off; 
    set(gcf,'Color','w');
    xlabel(sig{sig_num(1)}.GridLabel,'FontName','times','FontAngle','normal','FontSize',12);
    ylabel(sig{sig_num(1)}.DataLabel,'FontName','times','FontAngle','normal','FontSize',12);
end





%Create OkApplyCancel button and execute the passed function handle
function OkApplyCancel(varargin)
    if (nargin < 2)
        error('Require (dialog handle, function handle)')
    else
        dlg = varargin{1};
        func = varargin{2};
        options = 'none';
        redo = 'none';
    end
    if (nargin == 3); options = varargin{3}; redo = 'none'; end;
    if (nargin == 4); options = varargin{3}; redo = varargin{4}; end;
    newsig = sig;
    
    
h=addblock(dlg,'button',{'Apply','OK','Cancel'});
%Define callbacks
set(h(1),'Callback',@ApplyCallback);
function ApplyCallback(varargin)
    
    for i = 1:length(sig_num)
    newsig{sig_num(i)} = func(sig_num(i)); 
    end 
    
    if strcmp(options,'overlay')
        plotdata(fig.Handle,sig,sig_num,view);
        plotdata(fig.Handle,newsig,sig_num,view,'overlay'); 
        plotdata(fig.Handle,fit,sig_num,view,'overlay2');
    else
        plotdata(fig.Handle,newsig,sig_num,view);
    end
    figure(dlg.Handle);
end

set(h(2),'Callback',@OKCallback);
function OKCallback(varargin)
    for i = 1:length(sig_num)
       sig{sig_num(i)} = func(sig_num(i)); 
    end
    plotdata(fig.Handle,sig,sig_num,view);
    clear newsig;
    if ~strcmp(options,'preserve'); delete(dlg); end
end

set(h(3),'Callback',@CancelCallback);
function CancelCallback(varargin)
    plotdata(fig.Handle,sig,sig_num,view);
    delete(dlg);  clear newsig;  
end
end



end %%% End StrengthGUI



%% Utilities
%Create SMASH dialog unless it already exists
function h=FindOrCreateDlg(src,name)
if isappdata(src,name)
    h=getappdata(src,name);
    if ishandle(h)
        figure(h)
        return
    end
end
h = SMASH.MUI.Dialog;
setappdata(src,name,h.Handle);
end

%% Signal plotting   
function varargout = plotdata(varargin)
    if (nargin < 4)
        error('Require (figure handle, signal object, signal numbers,view)')
    else
        fig = varargin{1};
        sig = varargin{2};
        sig_num = varargin{3};
        view = varargin{4};
        options = 'new plot';
    end
    if (nargin ==5); options = varargin{5}; end;
    
    figure(fig);
    ha=gca;

    x = []; y = [];
    for i = 1:numel(sig_num)
        [time, data] = limit(sig{sig_num(i)});
        switch view
            case('Cl-u')
                x = data(:,1);
                y = data(:,2);
                sig{sig_num(i)}.GridLabel = 'Particle Velocity (km/s)';
                sig{sig_num(i)}.DataLabel = 'Lagrangian Wavespeed (km/s)';
            case('Stress-Strain')
                x = 1-data(1,3)./data(:,3);
                y = data(:,4);
                sig{sig_num(i)}.GridLabel = 'Strain';
               sig{sig_num(i)}.DataLabel = 'Stress (GPa)';               
            case('Stress-Density')
                x = data(:,3);
                y = data(:,4);
                sig{sig_num(i)}.GridLabel = 'Density (g/cc)';
                sig{sig_num(i)}.DataLabel = 'Stress (GPa)';  
            case('Cl-Strain')
                x = 1-data(1,3)./data(:,3);
                y = data(:,2);
                sig{sig_num(i)}.GridLabel = 'Strain';
                sig{sig_num(i)}.DataLabel = 'Lagrangian Wavespeed (km/s)';   
            case('Strain-Time')
                x = time;
                y = 1-data(1,3)./data(:,3);
                sig{sig_num(i)}.GridLabel = 'Time';
                sig{sig_num(i)}.DataLabel = 'Strain'; 
            case('StrainRate-Time')
                x = time;
                y = 1-data(1,3)./data(:,3);
                
                if x == 0;
                    y = x;
                else
                    
                    obj = SMASH.SignalAnalysis.Signal(x,y);
                    %Strain rate
                    obj = regrid(obj); obj = differentiate(obj); 

%                     %Smooth
%                     xfilt = 200; Nsmooth=int32(length(x)./xfilt); %LowPassFilt
%                     kernel = ones(Nsmooth,1);kernel = kernel/sum(kernel);
%                     obj = smooth(obj,'kernel',kernel);
                    [x y] = limit(obj);
%                     sig{sig_num(i)}.GridLabel = 'Time';
%                     sig{sig_num(i)}.DataLabel = 'Strain Rate';
                    
                    %x = 1-data(1,3)./data(:,3);
                end
            case('Custom')
                x = data(:,1);
                y = data(:,2).*data(1,3)./data(:,3);
                sig{sig_num(i)}.GridLabel = 'Particle Velocity (km/s)';
                sig{sig_num(i)}.DataLabel = 'Eulerian Wavespeed (km/s)';
                  
            otherwise
                disp('View not supported');
            end
        
        
            switch lower(options)
                case 'new plot'
                    if i ==1; cla; end;
                    h(i)=line(x,y);
                    lc = sig{sig_num(i)}.GraphicOptions.LineColor;
                    ls = sig{sig_num(i)}.GraphicOptions.LineStyle;
                    lw = sig{sig_num(i)}.GraphicOptions.LineWidth;
                    %ma = sig{sig_num(i)}.GraphicOptions.Marker             
                    set(h(i),'Color',lc,'LineStyle',ls,'LineWidth',lw);
                    legendentry{i}=strrep(sig{sig_num(i)}.Name,'_','\_');
                    box on;
                case 'overlay'
                    h = line(x, y,'Color',[0 0 0],'LineStyle','--','LineWidth',2);
                case 'overlay2'
                    h = line(x, y,'Color',[0.7 0.7 0.7],'LineStyle','--','LineWidth',2);
                    %legend(ha,strrep(sig{sig_num(i)}.Name,'_','\_'));
            end
    end
    if strcmp(lower(options),'new plot');
        lh = legend(h,legendentry,'Color','none','Location','Best','EdgeColor','w','LineWidth',1);
    end
    h=h(~isnan(h));
    xlabel(sig{sig_num(1)}.GridLabel); ylabel(sig{sig_num(1)}.DataLabel);
    varargout{1} = sig;
end

%% Integrate conservation equations
function [dens stress] = integrateClu(rho0,u,cl,varargin)
    strain0 = 0;
    stress0 = 0;
    if nargin > 3
        strain0 = varargin{1}
    end
    if nargin > 4; 
        stress0 = varargin{2};
    end
    
    stress = rho0.*cumtrapz(u,cl)+stress0;
    strain = cumtrapz(u,1./cl)+strain0;
    dens = rho0./(1-strain);
end

%% Save
function varargout = Save(varargin)
    if (nargin < 2)
        error('Require (signal object, signal numbers)')
    else
        sig = varargin{1};
        savenum = varargin{2};
    end
    
   %Set save to all active signals
   for i = 1:numel(savenum)
       %[savename, savepath] = uiputfile({'*.dat;*.txt;*.out','All ASCII Files'; '*.sda','SandiaDataArchive'; ...
       %    '*.*','All Files'}, sprintf('Save Signal #%i',savenum(i)),sig{savenum(i)}.Name);
       sig{savenum(i)}.GridLabel = ''; 
       sig{savenum(i)}.DataLabel = '';
       
       %savename = inputdlg(sig{savenum(i)}.Name,'Select file to write',1,{horzcat(sig{savenum(i)}.Name,'.dat')});
       %savename = savename{1}; 
       
       [savename, pathname] = uiputfile({'*.dat;*.txt;*.out','All ASCII Files'; '*.sda','SandiaDataArchive'; ...
       '*.*','All Files'}, sprintf('Save Signal #%i',savenum(i)),sig{savenum(i)}.Name);

       
       %Export all objects to Sandia Data Archive if .sda extension, otherwise ASCII
       [~,~,ext]=fileparts(savename);
       if strcmp(ext,'.sda')
           %Create waitbar
           wb=SMASH.MUI.Waitbar('Saving Signals'); set(wb.Handle,'Visible','on');
           for i = 1:numel(savenum)
                %update waitbar and exit if it doesn't exist
                update(wb,i/numel(savenum));
                if ~ishandle(wb.Handle); return; end;
            %labelname = inputdlg('Enter label name for sda file','SDA Label',1,{sig{savenum(i)}.Name}); labelname = labelname{1};
            labelname = sig{savenum(i)}.Name;
            %export(sig{savenum(i)},fullfile(savepath,savename),labelname);
            store(sig{savenum(i)},fullfile(pathname,savename),labelname); 
           end
           
            delete(wb);
           
           return; %Only ask for sda name once
       else
        export(sig{savenum(i)},fullfile(pathname,savename));
       end  
       

   end

   
end







%% Line colors initilization (modified from PointVISAR)
function color=DistinguishedLines(number)

map=[];
% map(end+1,:)=[0.00 0.00 1.00]; % blue
% map(end+1,:)=[0.00 1.00 0.00]; % green
% map(end+1,:)=[1.00 0.00 0.00]; % red
% map(end+1,:)=[0.00 1.00 1.00]; % cyan
% map(end+1,:)=[1.00 0.00 1.00]; % magenta
% map(end+1,:)=[0.75 0.75 0.00]; % yellowish
% map(end+1,:)=[0.00 1.00 0.50];
% map(end+1,:)=[1.00 0.50 0.00];
% map(end+1,:)=[0.50 0.00 1.00];
% map(end+1,:)=[0.00 0.50 1.00];
% map(end+1,:)=[0.50 1.00 0.00];
% map(end+1,:)=[1.00 0.00 0.50];
map(end+1,:)=[0.00 0.00 1.00]; % blue
map(end+1,:)=[0.00 0.50 0.00]; % green
map(end+1,:)=[1.00 0.00 0.00]; % red
map(end+1,:)=[0.00 0.75 0.75]; % cyan
map(end+1,:)=[0.90 0.00 0.90]; % magenta
map(end+1,:)=[0.75 0.75 0.00]; % yellowish
map(end+1,:)=[0.75 0.50 0.00]; %brown
map(end+1,:)=[0.50 0.50 0.50]; %grey
map(end+1,:)=[0.50 0.00 1.00]; %purple
map(end+1,:)=[1.00 0.00 0.50]; %pink
map=[map; 0.75*map]; % some darker variations

Ncolor=size(map,1);
while number>Ncolor
    number=number-Ncolor;
end
color=map(number,:);
end


%% Hugoniot material properties
function [rho c0 s g0 varargout] = getHugProp(varargin)

material = varargin{1};


switch material
    case 'DefinedSamples'
        rho = 1;
        c0 = 1;
        s = 1;
        g0 = 1; 
        material = {'Aluminum','Beryllium','Copper','Gold', ...
            'LiF','Molybdenum','Stainless Steel','Tantalum'};
        
      case 'DefinedWindows'
        rho = 1;
        c0 = 1;
        s = 1;
        g0 = 1; 
        material = {'Diamond','LiF','PMMA','Quartz','Sapphire'}; 
        
      case 'DefinedAll'
        rho = 1;
        c0 = 1;
        s = 1;
        g0 = 1; 
        material = {'Aluminum','Beryllium','Copper','Gold', 'Diamond', ...
            'LiF','Molybdenum','PMMA','Quartz','Sapphire', ...
            'Stainless Steel','Tantalum'};
        
    
    %% Metals
    case 'Aluminum'
        rho = 2.703;
        c0 = 5.35;
        s = 1.34;
        g0 = 2.14; 
        
    case 'Beryllium'
        rho = 1.851;
        c0 = 7.998;
        s = 1.124;
        g0 = 1.16;   
        
    case 'Copper'
        rho = 8.93;
        c0 = 3.94;
        s = 1.489;
        g0 = 1.99;
    
    case 'Gold'
        rho = 19.24;
        c0 = 3.056;
        s = 1.572;
        g0 = 2.97;
   
    case 'Molybdenum'
        rho = 10.215;
        c0 = 5.122;
        s = 1.256;
        g0 = 1.4;   
         
    case 'Stainless Steel'
        rho = 7.83;
        c0 = 4.4773;
        s = 1.4654;
        g0 = 1.5;   
        
    case 'Tantalum'
        rho = 16.656;
        c0 = 3.43;
        s = 1.19;
        g0 = 1.82;
        
        
        
    %% Windows    
    case 'Diamond'
        rho = 3.52;
        c0 = 18022;
        s = 2*2.07;
        g0 = 1.5;
        
    case 'LiF'
        rho = 2.638;
        c0 = 5.148;
        s = 1.353;
        g0 = 1.63;
        
    case 'PMMA'
        rho = 1.1837;
        c0 = 2.598;
        s = 1.516;
        g0 = 1.5;
        
    case 'Quartz'
        rho = 2.65;
        c0 = 6.36;
        s = 2*1.36;
        g0 = 1.5;
        
    case 'Sapphire'
        rho = 3.985;
        c0 = 11.19;
        s = 2.0;
        g0 = 1.5; 
        

    otherwise
        disp('material not supported'); exit;
end
             uH=linspace(0,10,2000)';
             UsH=(c0)+(s).*uH;
             PH=(rho).*uH.*UsH;
             VH=(1-uH./UsH)./(rho);
 
             %Calculate gradient (P-V) of Hugoniot
             dpdvH = diff(PH)./diff(VH); dpdvH(end+1)=dpdvH(end);
%              PV = SMASH.SignalAnalysis.Signal(VH,PH);
%              dPV = differentiate(PV);
%              [V,dpdvH] = limit(dPV);
             %Relate to gradient of isentrope
             dpdvS = dpdvH.*(1-(rho).*(g0).*(1./(rho)-VH)./2)-PH.*(rho).*(g0)./2;
 
             %Calculate corresponding wavespeeds
             ce=sqrt(-VH.^2.*dpdvS);
             c = ce./((rho).*(VH));
             
             Iu = uH;
             Ic = c;
             
             varargout{1} = Iu;
             varargout{2} = Ic;
             varargout{3} = material;

end



