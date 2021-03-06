%% SignalGUI is a GUI interface for the SMASH.SignalAnalysis.Signal package
%
% The GUI is generated primarily with the MUI package. There are five
% menus: Signal, Edit, Analyze, Programs, and Plot.
%
% In addition to the menu bar, two toolbars are available. The one next to
% the help toolbar is 'Selected Signals' and is a shortcut to the 'Choose
% Active Signals' option in the edit menu bar. The next toolbar to the
% right, 'Clear all Signal0.s'5 deletes all signal objects for a fresh start.
%
%% Signal 
% Load : Load multiple ascii or *.sda files into signal objects. For
%   SignalGroup type data, the first column is taken as the grid and
%   subesequent columns are loaded as distinct signals.
% Load from multicolumn : Select a data/grid pair from a multi-column text
%   file.
% Labels : Change the labels of each signal object
% Comment : Change comments associated with object. Only *.sda files track
%   comments, ascii files do not.
% Save: Save to an ascii or *.sda file   
%
%
%% Edit
% Choose active signal : choose which signals to plot/edit/analyze
% Shift and scale : shift/scale grid and data arrays. An @(x) f(x) handle 
%   definition will apply the function scale mapping. eg. @(x) log10(x). 
% Limit : apply the limit method
% Regrid : Apply the regrid method. Also supplies an option for a "pchip"
%   interpolation regrid.
% ResetActiveSignals : Reloads the signal based on the object's source
%   record. This is not very robust to directory changes. 
%
%
%% Analyze
% Differentiate : apply differentiate method
% Integrate : apply integrate method
% Calculate power spectrum : apply fft method
% Locate feature : apply locate method
% Combine selected sigals : brings up cursor selection of n-1 the amount of
%   current signals. The signals are combined in sequential order based on
%   the selected cursor breakpoints to form a new signal.
% Average selected signals : Creates a new signal from the average of the 
%   signals over the common grid range.
% Polyfit between 2 points : polynomial fit over the specified grid range
%   for the input degree. Also an option to simply connect two points.
% Extrapolate : Extrapolate signal based on polynomial or exponential fit
%   over the specified grid range for the amount given by extension. Also
%   an option to create an exponential decay based on specifed time
%   constant.
% MHD scaling : Pulldown menu to select scaling bewteen pressue, B-field,
%   and current. Where required, a static scale factor or a file is used.
% Current loss : Apply Ray Lemke's algorithm to a current signal to
%   determine an empirical loss or gain. A cursor is brought up with dI/dt
%   to determine the time at which to apply the loss.
% LiF AV correction: Non-linear LiF apparent velocity correction based on
%   shock data (Rigg et al., LA-UR-13-29106)
% Window shock correction : Apply simple steady shock solution to a VISAR 
%   signal with a LiF "Shock-Up" effect. (Brown et al, JAP, 2014)
% Incremental Impedance Matching : Mie-Gruniesen EOS solution based on
%   specified Window and Sample. 'getHugProp' function contains the EOS
%   parameters. 
% Inverse Lagrangian Analysis : Port of Jean-Paul Davis' CHARICE routine
%   for a single sample. The sample (usually iterated upon) and 
%   window files are wavespeed-particle velocity responses extracted from
%   ascii defaults within this program. Sample is a Lagrangian Analysis
%   output while the window is a Sesame isentrope output. The starting
%   window velocity is in SI units and other inputs are scaled
%   appropriately internally.
% Lagrangian Analysis : Simple wave Lagrangian analysis for the current
%   signals. If 1 signal is used, a shock is generated at 0 time (and saved
%   as a new signal to generate the centered wave solution.
% Integrate cl-u to stress-strain: integrate conservation equations
% Create Sesame : create a limited range sesame table using the selected
%   signal as a reference curve
%
%% Programs
% This is simply an interface to launch various self-contained programs
%
%
%% Plot
% Creates plots of presentation/report quality. Uses many of the options in
% the Graphics package
% 
% Update Line Properties : Saves any changes to the line properties of the
%   signal
% Edit signal order : Provides an interface to change the order of the
%   signals
% Edit axis labels : Change the grid and data labels
% Calculate % difference : New plot showing the percent difference between
%   the first signal and all other signals
% Velocity residuals : Quantify difference between experiment and sim
% Large AIP figure : Creates a large figure - typically found to be useful
%   for presentation figures. 
% Single column AIP figure : Single column report figure
% Double column AIP figure : Double column report figure
% Dual axis : creates a dual axis figure with the last signal on the right
%   axis
% Axis inset : creates an axis inset on the selected figure. Warning: the
%   algorithm deletes figures not associated with this GUI.
% Axis limit : modifies the axis range for the selected figure. Warning:
%   the algorithm deletes figures not associated with this GUI.
%
%% created February,1 2014 by Justin Brown (Sandia National Laboraties)

%%
function SignalGUI()
clear all; clc;

% Initialize Variables
sig = {}; 
sig_tot = 0;
sig_num = [];

%Reset callback is limited to the latest pathname
pathname = [];


% Set system defaults
%set(0,'DefaultAxesFontSize',14);
%set(0,'DefaultUIControlFontSize',14);


% create figure if not already running
check=findobj('Name','SMASH Signal GUI');
if ishandle(check) % program is already running
    disp('GUI already running!');
    figure(check);
    return;
end

fig = SMASH.MUI.Figure; fig.Hidden = true;
fig.Name = 'SMASH Signal GUI';
set(fig.Handle,'Tag','SignalGUI');
set(fig.Handle,'Units','normalized');
set(fig.Handle,'Position',[0.05 0.05 .75 .8]);
set(fig.Handle,'Toolbar','figure');
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

function ClearCallback(varargin)
            sig = {};
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



%% create Signal menu
hm=uimenu(fig.Handle,'Label','Signal');
uimenu(hm,'Label','Load','Callback',@LoadSignal);
uimenu(hm,'Label','Load from Multicolumn','Callback',@LoadMultiSignal);
uimenu(hm,'Label','Labels','Callback',@Label);
uimenu(hm,'Label','Comment','Callback',@Comment);
uimenu(hm,'Label','Save','Callback',@SaveSignal);
%uimenu(hm,'Label','Close');


%% create Edit menu
hm=uimenu(fig.Handle,'Label','Edit');
uimenu(hm,'Label','Choose Active Signal(s)','Callback',@ActiveSignal);
uimenu(hm,'Label','Shift and Scale','Callback',@ShiftScale);
uimenu(hm,'Label','Limit','Callback',@LimitSignal);
uimenu(hm,'Label','Smooth','Callback',@SmoothSignal);
uimenu(hm,'Label','Regrid','Callback',@RegridSignal);
%uimenu(hm,'Label','Reset Active Signals','Callback',@ResetSignal);




%% create Analyze menu
hm=uimenu(fig.Handle,'Label','Analyze');
uimenu(hm,'Label','Differentiate','Callback',@Derivative);
uimenu(hm,'Label','Integrate','Callback',@Integral);
uimenu(hm,'Label','Calculate power spectrum','Callback',@PowerSpectrum);
uimenu(hm,'Label','Locate feature','Callback',@LocateFeature);
uimenu(hm,'Label','Combine selected signals','Callback',@CombineSignals);
uimenu(hm,'Label','Average Selected Signals','Callback',@AverageSignals);
uimenu(hm,'Label','Combine Data into new signal','Callback',@CombineData);
uimenu(hm,'Label','Polyfit between 2 points','Callback',@PolyPoints);
uimenu(hm,'Label','Extrapolate','Callback',@Extrapolate);
uimenu(hm,'Label','MHD Scaling','Callback',@MHDScaling);
uimenu(hm,'Label','CurrentLoss','Callback',@CurrentLoss);
uimenu(hm,'Label','LiF AV Correction','Callback',@LiFAV);
uimenu(hm,'Label','Window Shock Correction','Callback',@WindowShock);
uimenu(hm,'Label','Incremental Impedance Matching','Callback',@IMSignals);
uimenu(hm,'Label','Inverse Lagrangian Analysis','Callback',@ILA);
uimenu(hm,'Label','Lagrangian Analysis','Callback',@LA);
uimenu(hm,'Label','Integrate cl-u to stress-strain','Callback',@IntegrateWavespeed);
uimenu(hm,'Label','Create Sesame','Callback',@CreateSesame);




%% Create Programs menu / launcher
hm=uimenu(fig.Handle,'Label','Programs');
uimenu(hm,'Label','Point VISAR','Callback',@PointVISARLaunch);
uimenu(hm,'Label','SIRHEN','Callback',@SIRHENLaunch);
uimenu(hm,'Label','Dat Ninja','Callback',@datninjaLaunch);
uimenu(hm,'Label','Impedance Matching','Callback',@MGrunP_uLaunch);
uimenu(hm,'Label','Dakota Unfold Setup','Callback',@DakotaUnfoldSetup);
uimenu(hm,'Label','Transfer Function Analysis','Callback',@TransferFunction);
uimenu(hm,'Label','Lagrangian Analysis','Callback',@LagrangianAnalysis);
uimenu(hm,'Label','Strength Analysis','Callback',@StrengthLaunch);


%% create Plotting menu
hm=uimenu(fig.Handle,'Label','Plot');
uimenu(hm,'Label','Update Line Properties','Callback',@UpdateLineProp);
uimenu(hm,'Label','Edit Signal Order','Callback',@EditOrder);
uimenu(hm,'Label','Edit axis labels','Callback',@EditAxisLabel);
uimenu(hm,'Label','Calculate % Difference','Callback',@PercentDifference);
uimenu(hm,'Label','Velocity Residuals','Callback',@VelocityResiduals);
uimenu(hm,'Label','Large AIP Figure','Callback',@BigPlot);
uimenu(hm,'Label','Single column AIP Figure','Callback',@AIPFigure1);
uimenu(hm,'Label','Double column AIP Figure','Callback',@AIPFigure2);
uimenu(hm,'Label','Dual Axes','Callback',@DualAxes);
uimenu(hm,'Label','Axes Inset','Callback',@AIPAxesInset);
uimenu(hm,'Label','Axis Limits','Callback',@SetAxis);
uimenu(hm,'Label','Print Plot','Callback',@PrintPlot);

fig.Hidden = false;


%%%%%%%%%%% Signal Callbacks %%%%%%%%%%%%%

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
     
    try
    
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
             sig{sig_tot} = SMASH.SignalAnalysis.Signal(fullfile(pathname,filename{i}),'sda',label{ii});
        end
        
        
    %Load ascii file    
    else
        %Advance to next signal
        sig_tot = sig_tot+1;
        
        %Probe file to find number of columns
        source=SMASH.FileAccess.ColumnFile(fullfile(pathname,filename{i}));
        p=probe(source); ncol = p.NumberColumns;

        if ncol == 1
            data = read(source); data = data.Data;
            x=[1:length(data)];
            sig{sig_tot} = SMASH.SignalAnalysis.Signal(x,data);
        else
            %If grid is not monotonically increasing use unique
            try
                sig{sig_tot} = SMASH.SignalAnalysis.Signal(fullfile(pathname,filename{i}),'column');
            catch
                data = read(source); data = data.Data;
                [~,index] = unique(data(:,1));
                sig{sig_tot} = SMASH.SignalAnalysis.Signal(data(index,1),data(index,2));
            end

        end
        
        [~,name,ext]=fileparts(filename{i}); 
        if length(ext) > 4; name = [name ext]; end
        sig{sig_tot}.Name = name;

        %Set some object properties
        sig{sig_tot}.GraphicOptions.LineWidth=3;
        sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);
        sig{sig_tot}.GridLabel= 'x'; sig{sig_tot}.DataLabel= 'y';

    
        %Loop through column numbers 2 and higher and load if there is data
        if ncol > 2; data = read(source); end; 
        for cn=3:ncol
            if ~(all(data.Data(:,cn)==0)) %Make sure there is data in column
            %Increment total number signals, load and save to object
            sig_tot = sig_tot + 1;
            sig{sig_tot} = SMASH.SignalAnalysis.Signal(fullfile(pathname,filename{i}),'column',[1 cn]);  
            str=sprintf('%s col%i',name,cn);
            sig{sig_tot}.Name = str;

            %Set some object properties
            sig{sig_tot}.GraphicOptions.LineWidth=3;
            sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);
            sig{sig_tot}.GridLabel= 'x'; sig{sig_tot}.DataLabel= 'y';
            end
        end
    end
    
    %Reset if any errors during load process
    catch
        sig_tot = numel(sig);
        warning('Invalid file selected, try another one');
    end
        
    
    %update waitbar and exit if it doesn't exist
    if ~ishandle(wb.Handle); return; end;
    update(wb,i/numfiles);   
end
delete(wb);

%Set active signals to all and plot
sig_num = [1:sig_tot];
plotdata(fig.Handle,sig,sig_num);

    
end %Load Signal

%% Load 2 columns from a multicolumn ascii file
function LoadMultiSignal(src,varargin)     

% see if dialog already exists
dlg=FindOrCreateDlg(src,'LoadDialog');
if ishandle(dlg)
    return;
end

dlg.Hidden = true;
dlg.Name = 'LoadDialog';
locate(dlg,'center')

direct = dir('*.*');
for i = 3:length(direct);
    filelist{i-2} = direct(i).name;
end
h1=addblock(dlg,'popup','Select Signal(s)',filelist);
cols = {'Column 1', 'Column2','','','','',''}; 
h2=addblock(dlg,'listbox','Select Column',cols);
h=addblock(dlg,'check','Flip Column Order');   
h=addblock(dlg,'button',{'Load','Cancel'});    


%Set multiple selection option (for all in dlg)
dlg_hc = get(dlg.Handle,'Children');
set(dlg_hc,'Max',2);
set(h1(2),'Callback',@FileCallback);

%Define callbacks
function FileCallback(varargin)

    filename = probe(dlg);
    filename = filename{1};
    %filename=fullfile(pwd,probe(dlg));
    %Probe file to find number of columns
    source=SMASH.FileAccess.ColumnFile(filename);
    p=probe(source); ncol = p.NumberColumns;
    data = read(source);
   
    header =strread(data.Header{1},'%s');
    if length(header) == ncol
        str = header;
    else
        str = {};
        for i =1:ncol
            str{1,i}=num2str(i);
        end
    end
    set(h2(2),'String',str);
    
end

set(h(1),'Callback',@ApplyCallback);
function ApplyCallback(varargin)
    value = probe(dlg);
    filename = value{1};
    source=SMASH.FileAccess.ColumnFile(filename);
   
    cols=get(dlg_hc(4),'Value');
   
    try
        sig_tot = sig_tot+1;
        if ~value{3}
                      
            %If grid is not monotonically increasing use unique
            try
                sig{sig_tot} = SMASH.SignalAnalysis.Signal(fullfile(filename),'column',cols(1:2));
            catch
                data = read(source); data = data.Data;
                [~,index] = unique(data(:,cols(1)));
                sig{sig_tot} = SMASH.SignalAnalysis.Signal(data(index,cols(1)),data(index,cols(2)));
            end
            
        else
            %If grid is not monotonically increasing use unique
            try
                sig{sig_tot} = SMASH.SignalAnalysis.Signal(fullfile(filename),'column',fliplr(cols(1:2)));
            catch
                data = read(source); data = data.Data;
                [~,index] = unique(data(:,cols(2)));
                sig{sig_tot} = SMASH.SignalAnalysis.Signal(data(index,cols(2)),data(index,cols(1)));
            end
            
        end

        %Set some object properties
        [~,name,ext]=fileparts(filename); 
        if length(ext) > 4; name = [name ext]; end
        pathname = pwd;
        sig{sig_tot}.Name = name;
        sig{sig_tot}.GraphicOptions.LineWidth=3;
        sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);
        sig{sig_tot}.GridLabel= 'x'; sig{sig_tot}.DataLabel= 'y';

        %Set active signals to all and plot
        sig_num = [1:sig_tot];
        plotdata(fig.Handle,sig,sig_num);
    
    %Reset if any errors during the load process
    catch
        sig_tot = numel(sig);
        warning('Invalid load options, try selecting two valid columns');
    end

end
set(h(2),'Callback',@CancelCallback);
function CancelCallback(varargin)
   delete(dlg);
end

dlg.Hidden = false;
    

end %Load multi-column signal

%% Label signal callback
function Label(src,varagin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'LabelDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Label Signal';
locate(dlg,'center');

%Create edit box for each signal
for i=1:numel(sig_num)
    h=addblock(dlg,'edit',sig{sig_num(i)}.Name); set(h(2),'String', sig{sig_num(i)}.Name);
end
h=addblock(dlg,'button',{ 'Apply Label Change', 'Cancel'});
dlg.Hidden = false;

%Define button callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       newnames = probe(dlg);
       for i=1:numel(sig_num)
        if ~isempty(newnames{i})
            sig{sig_num(i)}.Name = newnames{i};
        end
       end
    plotdata(fig.Handle,sig,sig_num);
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

end %Comment

%% Save signal callback
function SaveSignal(src,varargin)     


   %Set save to all active signals
   savenum = sig_num;
   for i = 1:numel(savenum)
       [savename, savepath] = uiputfile({'*.dat;*.txt;*.out','All ASCII Files'; '*.sda','SandiaDataArchive'; ...
           '*.*','All Files'}, sprintf('Save Signal #%i',savenum(i)),sig{savenum(i)}.Name);

       %savename = inputdlg(sig{savenum(i)}.Name,'Select file to write',1,{horzcat(sig{savenum(i)}.Name,'.dat')});
       %savename = savename{1}; savepath = pathname;
       
       %Export all objects to Sandia Data Archive if .sda extension, otherwise ASCII
       [~,~,ext]=fileparts(savename);
       if strcmp(ext,'.sda')
          
           for i=1:numel(savenum)
               labelnames{i} = sig{i}.Name;
           end
           [~,ia] = unique(labelnames);
           %duplicates = labelnames;
           %duplicates(ia)=[];
           duplicate_ind = setxor(ia,1:numel(labelnames));
           for i=1:length(duplicate_ind)
               warning(sprintf('Duplicate label name detected : %s',labelnames{duplicate_ind(i)}));
               labelnames{duplicate_ind(i)} = sprintf('%s%i',labelnames{duplicate_ind(i)},i);
           end
           
           for i = 1:numel(savenum)
            %labelname = inputdlg('Enter label name for sda file','SDA Label',1,{sig{savenum(i)}.Name}); labelname = labelname{1};
            %labelname = sig{savenum(i)}.Name;
            %export(sig{savenum(i)},fullfile(savepath,savename),labelname);
            %store(sig{savenum(i)},fullfile(savepath,savename),labelnames{i});
            
            archive=SMASH.FileAccess.SDAfile(savename);
            description=sprintf('%s object',class(sig{savenum(i)}));
            deflate=1;
            insert(archive,labelnames{i},sig{savenum(i)},description,deflate);
            %h5writeatt(filename,['/' label],'Class',class(sig{savenum(i)}));
            %h5writeatt(filename,['/' label],'RecordType','object');
            
            
           end
           return; %Only ask for sda name once
       else
           
        % Modify nature of the default export
        [x y] = limit(sig{savenum(i)});
        table=[x(:) y(:)];        
        format='%#+.6e %#+.6e \n';
        header{1}=sprintf('# Signal export on %s',datestr(now));
        header{2}=sprintf('# column format: %s %s',sig{savenum(i)}.GridLabel,sig{savenum(i)}.DataLabel);
        SMASH.FileAccess.writeFile(fullfile(savepath,savename),table,format,header);         
           
        %export(sig{savenum(i)},fullfile(savepath,savename));
       end  
   end



end %Save




%%%%%%%%%%% Edit Callbacks %%%%%%%%%%%%%

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

for i =1:sig_tot; slist{i}=sig{i}.Name; end

h=addblock(dlg,'listbox','Select Signal(s)',slist);

%Set multiple selection option (for all in dlg)
dlg_hc = get(dlg.Handle,'Children');
set(dlg_hc,'Max',2);
h=addblock(dlg,'button',{ 'Apply', 'Delete','Cancel'});

%Define callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       sig_num=get(dlg_hc(1),'Value');
       plotdata(fig.Handle,sig,sig_num);
       
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
        
        %Reset colors
        %for i=1:sig_tot;
        %    sig{i}.GraphicOptions.LineColor=DistinguishedLines(i);
        %end
        
        %If all signals were deleted, reset
        if new_num == 1
            sig = {};
            sig_tot = 0;
            figure(fig.Handle); cla; legend('off');
            return;
        end
            
        plotdata(fig.Handle,sig,sig_num);      
        ActiveSignal(0);
    end
    
    set(h(3),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
    

locate(dlg,'east');
dlg.Hidden = false;

end %Choose Active Signals

%% Shift and Scale
function ShiftScale(src,varargin)     

% see if dialog already exists
dlg=FindOrCreateDlg(src,'ShiftScaleDialog');
if ishandle(dlg)
    return
end

init = [1 0 1 0];
dlg.Hidden = true;
dlg.Name='Shift and Scale Profile';
hb = addblock(dlg,'button',{'SI-km/s','km/s-SI','SI-ns'});
h=addblock(dlg,'edit','x scale'); set(h(2),'String', init(1));
h=addblock(dlg,'edit','x shift'); set(h(2),'String', init(2));
h=addblock(dlg,'edit','y scale'); set(h(2),'String', init(3));
h=addblock(dlg,'edit','y shift'); set(h(2),'String', init(4));

set(hb(1),'Callback',@fromSICallback);
function fromSICallback(varargin)
    %Hardcode "probe" to allow modification of values
    dlg_hc = get(dlg.Handle,'Children');
    hloc = [10 8 6 4];
    editdata = [1e6 0 1e-3 0];
    for i=1:4
        set(dlg_hc(hloc(i)),'String',num2str(editdata(i)));
    end
    
    for i=1:numel(sig_num)
        sig{i}.GridLabel = 'Time (\mus)';
        sig{i}.DataLabel = 'Velocity (km/s)';
    end
    
end

set(hb(2),'Callback',@toSICallback);
function toSICallback(varargin)
    dlg_hc = get(dlg.Handle,'Children');
    hloc = [10 8 6 4];
    editdata = [1e-6 0 1e3 0];
    for i=1:4
        set(dlg_hc(hloc(i)),'String',num2str(editdata(i)));
    end

    for i=1:numel(sig_num)
        sig{i}.GridLabel = 'Time (s)';
        sig{i}.DataLabel = 'Velocity (m/s)';
    end    
    
end

set(hb(3),'Callback',@toNSCallback);
function toNSCallback(varargin)
    dlg_hc = get(dlg.Handle,'Children');
    hloc = [10 8 6 4];
    editdata = [1e9 0 1e-3 0];
    for i=1:4
        set(dlg_hc(hloc(i)),'String',num2str(editdata(i)));
    end

    for i=1:numel(sig_num)
        sig{i}.GridLabel = 'Time (ns)';
        sig{i}.DataLabel = 'Velocity (km/s)';
    end    
    
end


OkApplyCancel(dlg,@applyedit,'overlay_all')
function newsig = applyedit(n)    
    dlg_hc = get(dlg.Handle,'Children');
    hloc = [10 8 6 4]; value = [];
    for i=1:4
        editdata(i) = str2double(get(dlg_hc(hloc(i)),'String'));
    end

  %Apply edit to signal number n
        
        if strncmpi(get(dlg_hc(hloc(1)),'String'),'@(x)',4);
            funchand = str2func(get(dlg_hc(hloc(1)),'String'));
            newsig = sig{n}.map('Grid','custom',funchand);
        else
            newsig = scale(sig{n},editdata(1));
        end
        
        newsig = shift(newsig,editdata(2));
        
        if strncmpi(get(dlg_hc(hloc(3)),'String'),'@(x)',4);
            funchand = str2func(get(dlg_hc(hloc(3)),'String'));
            newsig = newsig.map('Data','custom',funchand);
        else
            newsig = newsig*editdata(3);
        end
        
        newsig = newsig+editdata(4);       
 end     

    
locate(dlg,'east');
dlg.Hidden=false;

end %ShiftScale

%% Limit signal callback
function LimitSignal(src,varargin)     

% see if dialog already exists
dlg=FindOrCreateDlg(src,'LimitDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Limit Signal';


limits = [-inf inf];
h=addblock(dlg,'edit','Lower Bound'); set(h(2),'String', limits(1));
h=addblock(dlg,'edit','Upper Bound'); set(h(2),'String', limits(2));
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

OkApplyCancel(dlg,@applylimit,'overlay','redo');

function newsig = applylimit(n)    
        value = probe(dlg);
        clipbounds = str2double(value);
        newsig = limit(sig{n},clipbounds);
end     

locate(dlg,'east');
dlg.Hidden=false;

end %Limit (clip) signals

%% Smooth signal callback
function SmoothSignal(src,varargin)     

% see if dialog already exists
dlg=FindOrCreateDlg(src,'SmoothDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Smooth Signal';

h=addblock(dlg,'listbox','Smooth Method',{'mean','kernel','butterworth'}); 
h=addblock(dlg,'edit','Smooth Value');

OkApplyCancel(dlg,@applysmooth,'overlay')

function newsig = applysmooth(n)
    
    %Add defaults if smooth options are empty
    value = probe(dlg);
    dlg_hc = get(dlg.Handle,'Children');
    if strcmp(value(2),'')
        if strcmp(value(1),'kernel')
            set(dlg_hc(4),'String','fft kernel');
        else 
            set(dlg_hc(4),'String','3');
        end
    end
    
    %Apply smoothing choice
    choice = value{1};
        switch choice
            case 'mean'
                newsig = smooth(sig{n},'mean',str2double(value(2)));
            case 'kernel'
                kernel = definekernal;
                newsig = smooth(sig{n},'kernel',kernel);
            case 'butterworth'
                [b,a]=butter(1,str2double(value(2)));
                [x y] = limit(sig{n});
                y = filtfilt(b,a,y);
                newsig = SMASH.SignalAnalysis.Signal(x,y);
        end
        
    function  [kernel] = definekernal
        [tempsigx tempsigy] = limit(sig{n}); 
        xfilt = str2double(value(2));
        Nsmooth=int32(length(tempsigx)./xfilt); %LowPassFilt
        kernel = ones(Nsmooth,1);
        kernel = kernel/sum(kernel);
    end        
        
end
locate(dlg,'east')
dlg.Hidden=false;


end %Smooth signals

%% Regrid signal callback
function RegridSignal(src,varargin)
    
    % see if dialog already exists
    dlg=FindOrCreateDlg(src,'RegridDialog');
    if ishandle(dlg)
        return
    end

    dlg.Hidden = true;
    dlg.Name = 'Regrid Signal';

    h=addblock(dlg,'edit_check',{'Number Points to Regrid','pchip'});

    OkApplyCancel(dlg,@applyregrid,'overlay')

    function newsig = applyregrid(n)
        value = probe(dlg);
        N = str2double(value(1));
        [xcurr ycurr] = limit(sig{n}); 
        x1=min(xcurr);
        x2=max(xcurr);
        spacing=(x2-x1)/(N-1);
        x=x1:spacing:x2;
        x=x(:);
        if ~value{2}
            newsig = regrid(sig{n},x);
        else
            y = interp1(xcurr, ycurr, x, 'pchip', 0);
            newsig = SMASH.SignalAnalysis.Signal(x,y);
        end
        clear xcurr ycurr;
    end
    
    dlg.Hidden = false;
end %Regrid

%% Reset signal callback
function ResetSignal(src,varagin)
for i = 1:numel(sig_num)
    previous = sig{sig_num(i)}
    previous = SMASH.SignalAnalysis.Signal('import',fullfile(pathname,previous.Source),'column',previous.SourceRecord);
    
    %Reset properties
    sig{sig_num(i)} = reset(sig{sig_num(i)},previous); 
    clear previous; 
    
    plotdata(fig.Handle,sig,sig_num);
end

end  %Reset





%%%%%%%%%%% Analyze Callbacks%%%%%%%%%%%%%
%% Derivative
function Derivative(src,varargin)
    for i=1:numel(sig_num)
    sig{sig_num(i)}=differentiate(sig{sig_num(i)});
    end
    plotdata(fig.Handle,sig,sig_num);
end %Derivative

%% Integral
function Integral(src,varargin)
    for i=1:numel(sig_num)
    sig{sig_num(i)}=integrate(sig{sig_num(i)});
    end
    plotdata(fig.Handle,sig,sig_num);
end %Integral

%% Power spectrum
function PowerSpectrum(src,varargin)
    for i=1:numel(sig_num)
    [frequency{i}, power{i}] = fft(sig{sig_num(i)},'NumberFrequencies',[1 inf]);
    end
    
    figure; 
    hold on; hold all;
    for i=1:numel(sig_num)
        output{i}=10*log10(power{i});
        plot(frequency{i},output{i});
    end
    xlabel('Frequency')
    ylabel('Power (dB scale)');
end %Power spectrum

%% Locate feature (peak fitting)
function LocateFeature(src,varargin)
    for i=1:numel(sig_num)
    report =locate(sig{sig_num(i)});
    x = report.Location; 
    y = lookup(sig{sig_num(i)},x);
    line([x x],[0 y],'Color','k','LineStyle','--','LineWidth',3);
    end
end %Locate peak

%% Combine to form new signal
function CombineSignals(src,varargin)
    if (numel(sig_num)<2)
        error('Require at least 2 signals');
    end
    plotdata(fig.Handle,sig,sig_num)
    [xpoint ypoint] = ginput(numel(sig_num)-1);
    xpoint = [-inf; xpoint; inf];
    xkeep = []; ykeep =[]; 
    for i=1:numel(xpoint)-1
        [x,y] = limit(sig{sig_num(i)});
        keep = (x >= xpoint(i)) & (x <= xpoint(i+1)) ;
        xkeep = [xkeep;x(keep)]; 
        ykeep = [ykeep;y(keep)];
    end
    [xkeep ia] = unique(xkeep);
    ykeep = ykeep(ia);
    %Add Signal
    newsig = SMASH.SignalAnalysis.Signal(xkeep,ykeep);
    sig_tot = sig_tot + 1;
    sig{sig_tot} = reset(sig{sig_num(1)},newsig);
    makeGridUniform(sig{sig_tot});
    %Set some object properties
    sig{sig_tot}.Name = 'Combined Signal'; 
    sig{sig_tot}.GraphicOptions.LineWidth=3;
    sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);
    clear newsig;
    %Set active to all and plot
    sig_num = [1:sig_tot];
    plotdata(fig.Handle,sig,sig_num);
end %Combine

%% Average to form new signal
function AverageSignals(src,varargin)
    if (numel(sig_num)<2)
        error('Require at least 2 signals');
    end
    plotdata(fig.Handle,sig,sig_num)
    
    %Find absolute min and max
    xmin=[]; xmax=[];
    for i=1:numel(sig_num)
    xmin = [xmin;min(sig{sig_num(i)}.Grid)];
    xmax = [xmax;max(sig{sig_num(i)}.Grid)];
    end
    xmin = min(xmin);
    xmax = max(xmax);
    
    %New x grid
    tempsig = limit(sig{sig_num(1)},[xmin xmax]);
    tempsig = verifyGrid(tempsig);
    [xgrid ygrid] = limit(tempsig);
    ytot = [];
   	for i=1:numel(sig_num)
    ytot= [ytot,lookup(sig{sig_num(i)},xgrid)];
    end

    yaverage = mean(ytot')';
    
    %Custom averaging
        %weights = [2/4 2/4];
        %weights = [4/3 -1/3];
        %yaverage = weights(1).*ytot(:,1)+weights(2).*ytot(:,2);
    
        %ysub = yaverage - ytot(:,2);
        %yaverage = ytot(:,1)-4*ysub;
    
    %Add Signal
    newsig = SMASH.SignalAnalysis.Signal(xgrid,yaverage);
    sig_tot = sig_tot + 1;
    sig{sig_tot} = reset(sig{sig_num(1)},newsig);
    makeGridUniform(sig{sig_tot});
    %Set some object properties
    sig{sig_tot}.Name = 'Signal Average';
    sig{sig_tot}.GraphicOptions.LineWidth=3;
    sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);
    clear newsig;
    %Set active to all and plot
    sig_num = [sig_num sig_tot];
    plotdata(fig.Handle,sig,sig_num);
end %Average


%% Combine data to form new signal
function CombineData(src,varargin)
    if (numel(sig_num)~=2)
        error('Requires 2 signals');
    end
    [x1 y1] = limit(sig{sig_num(1)});
    [x2 y2] = limit(sig{sig_num(2)});
    %Add Signal
    %Interpolate sig 2 to same time base
    y2 = interp1(x2,y2,x1,'pchip',0);
    [~,ia]=unique(y1);
    sig_tot = sig_tot + 1;
    sig{sig_tot} = SMASH.SignalAnalysis.Signal(y1(ia),y2(ia));
    makeGridUniform(sig{sig_tot});
    %Set some object properties
    sig{sig_tot}.Name = 'Combined Signal'; 
    sig{sig_tot}.GraphicOptions.LineWidth=3;
    sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);
    clear newsig;
    %Set active to all and plot
    sig_num = [1:sig_tot];
    plotdata(fig.Handle,sig,sig_num);
end %Combine


%% Polynomial fit between 2 points
function PolyPoints(src,varargin)
    
% see if dialog already exists
dlg=FindOrCreateDlg(src,'PolyPointsDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Polynomial Between 2 Points';
h=addblock(dlg,'edit_check',{'Polynomial Order','Connect'}); set(h(2),'String', 6);
h=addblock(dlg,'edit','x min       '); set(h(2),'String', 0);
h=addblock(dlg,'edit','x max       '); set(h(2),'String', 0);
h=addblock(dlg,'button','SelectPoints');
set(h(1),'Callback',@selectpoints);

OkApplyCancel(dlg,@connect,'overlay');

locate(dlg,'east');
dlg.Hidden=false;
   
dlg_hc = get(dlg.Handle,'Children');
function [varargout] = selectpoints(varargin)
    figure(fig.Handle); 
    [xpick ypick] = ginput(2);
    figure(dlg.Handle);
    set(dlg_hc(7),'String',num2str(min(xpick)));
    set(dlg_hc(5),'String',num2str(max(xpick)));
end

function newsig = connect(n)
        value = probe(dlg);
        [x y] = limit(sig{n});
        porder = str2double(get(dlg_hc(10),'String'));
        %Range of data for fitting
        x1 = str2double(get(dlg_hc(7),'String'));
        x2 = str2double(get(dlg_hc(5),'String'));
        range=(x > x1) & (x < x2);

        if value{2}
            px = x(range); p1x=px(1); p2x=px(end);
            py = y(range); p1y=py(1); p2y=py(end);
            pfit = px.*((p2y-p1y)./(p2x-p1x)); pfit = pfit+(p1y-pfit(1));
            y(range) = pfit; 
        else          
        %Fit polynomial between points
        pfit = polyfit(x(range), y(range), porder);
        
        %Only fit between crossing points
            pdiff = polyval(pfit,x(range)) - y(range);
            crossneg = find(pdiff.*pdiff(1) < 0);
            crosspos = find(pdiff.*pdiff(1) > 0); 
            cross0 = find(range > 0); 
            crossneg = crossneg+cross0(1); crosspos = crosspos+cross0(1); 
            cross1 = crossneg(1); cross2 = min([crossneg(end),crosspos(end)]);
            range2=(x > x(cross1) & (x < x(cross2)));

        y(range2) = polyval(pfit,x(range2)); 
        end
        
        newsig = SMASH.SignalAnalysis.Signal(x,y);
    
end

end %Polynomial fit

%% Extrapolate 
function Extrapolate(src,varargin)
    
% see if dialog already exists
dlg=FindOrCreateDlg(src,'ExtrapolationDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Extrapolate';
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

h=addblock(dlg,'edit','x extension       '); set(h(2),'String', 0);
h=addblock(dlg,'popup','Type',{'Polynomial','Exponential','Exponential Decay'});
h=addblock(dlg,'edit','value'); set(h(2),'String', 1);
OkApplyCancel(dlg,@extrap,'overlay');

locate(dlg,'east');
dlg.Hidden = false;

function newsig = extrap(n)
    value = probe(dlg);
    [x y] = limit(sig{n});
    xext = str2double(value{3});
    
    %Range of data for fitting
    x1 = str2double(value{1});
    x2 = str2double(value{2});
    
    temp = (x < x2);
    x = x(temp); y = y(temp);
    range=(x > x1) & (x < x2);
    %xspace = mean(diff(x));
    %xadd = x(end)+xspace:xspace:x(end)+xext
    xadd = linspace(x(end), x(end)+xext,2e3)';
    
    
    switch value{4}
        case 'Polynomial'
            porder = str2double(value{5});
            p_fit = polyfit(x(range),y(range),porder);
            yadd = polyval(p_fit,xadd);
        case 'Exponential'   
            p_log_fit = polyfit(x(range),log(y(range)),1);
            yadd = exp(polyval(p_log_fit,xadd));
        case 'Exponential Decay'
            tau = str2double(value{5});
            yadd = y(end).*exp((-xadd+x(end))./tau);
            
    end
    x = vertcat(xadd,x); y = vertcat(yadd,y);
    [x i] = unique(x); y = y(i); 
    newsig = SMASH.SignalAnalysis.Signal(x,y);
end

end %Extrapolation

%% MHD Scaling
function MHDScaling(src,varargin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'MHDScaleDialog');
if ishandle(dlg)
    return
end 
dlg.Name = 'MHD Scaling';
dlg.Hidden = true;   

h=addblock(dlg,'edit_check',{'S(0)','Select S(t)'}); 
choices = {'P to I','P to B','I to P','I to B', 'B to I','B to P','Direct Scale sig*s','Direct Scale sig/s','I to V (S is L)'};
h=addblock(dlg,'popup','Scaling Type',choices);


OkApplyCancel(dlg,@MHDScale,'overlay')

function newsig = MHDScale(n)
    value = probe(dlg);
    newsig = sig{n};
    
    if ~value{2}
        [grid,data]=limit(newsig);
        data(:)=str2double(value{1});
        s = SMASH.SignalAnalysis.Signal(grid,data);
    else
        %Pick file
        [filename, pathname, filterindex] = uigetfile({'*.*',  'All Files (*.*)'}, ...
            'Pick Signal(s)', 'MultiSelect', 'on');
        s = SMASH.SignalAnalysis.Signal(fullfile(pathname,filename),'column');
    end
   
    %[newsig,s] = registeaxr(newsig,s);
    %Regrid to common time base
    tmin = max([min(s.Grid),min(newsig.Grid)]);
    tmax = min([max(s.Grid),max(newsig.Grid)]);
    dt = mean(diff(newsig.Grid))
    t = tmin:dt:tmax; t=t';
    s = regrid(s,t);
    newsig = regrid(newsig,t);
    
    
    switch value{3}
        case choices{1}
            newsig=(2.*newsig./(4e-7*pi)).^0.5.*s;
        case choices{2}
            newsig=(2.*newsig.*(4e-7.*pi)).^0.5;
        case choices{3}
            newsig=(4e-7.*pi./2).*(newsig./s).^2;
        case choices{4}
            newsig=4e-7.*pi.*newsig./s;
        case choices{5}
            newsig=newsig.*s./(4e-7*pi);
        case choices{6}
            newsig= (newsig.^2)./(8e-7*pi);        
        case choices{7}
            newsig = newsig.*s;
        case choices{8}
            newsig = newsig./s;
        case choices{9}
            didt = differentiate(newsig);
            dldt = differentiate(s);
            newsig = didt.*s+dldt.*newsig;           
    end
    
    
end     


locate(dlg,'east');
dlg.Hidden=false;
    
end %MHD Scaling

%% CurrentLoss
function CurrentLoss(src,varargin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'CurrentLossDialog');
if ishandle(dlg)
    return
end 
dlg.Name = 'CurrentLoss';
dlg.Hidden = true;   

h=addblock(dlg,'edit_check',{'Loss','Calculate MITL Current'}); 

OkApplyCancel(dlg,@CalcLoss,'overlay_all')

function newsig = CalcLoss(n)
    value = probe(dlg)
    closs = str2double(value{1});
    newsig = sig{n};
    
    scrsz = get(0,'ScreenSize');
    tempfig=figure('Position',[scrsz(1)*.9 scrsz(2)*.9 scrsz(3)*.9 scrsz(4)*.9])
    
    %Pick point to apply
    [t,c] = limit(newsig);
    dcdt = diff(c)./diff(t); dcdt(end+1)=dcdt(end);
    plotyy(t,c,t,dcdt);
    [tpick cpick] = ginput(1);
    tpick_i = find(t > tpick);
    tpick_i = tpick_i(1);
    c0 = c(tpick_i);
    delete(tempfig);
    
    if value{2} 
        clmax = max(c);
        cmmax = clmax + closs;

        %Apply scaling, generate new waveform
        alpha = log(clmax./cmmax)./log(c0./cmmax);
        cnew = c;
        cnew (tpick_i:end) = (cnew(tpick_i:end)./(c0.^alpha)).^(1/(1-alpha));
        lossig = SMASH.SignalAnalysis.Signal(t,cnew);
        newsig = reset(newsig,lossig);
    else
        cmmax = max(c);
        clmax = cmmax - closs;
            
        %Apply scaling, generate new waveform
        alpha = log(clmax./cmmax)./log(c0./cmmax);
        cnew = c;
        cnew (tpick_i:end) = cnew(tpick_i:end).*(c0./cnew(tpick_i:end)).^alpha;
        lossig = SMASH.SignalAnalysis.Signal(t,cnew);
        newsig = reset(newsig,lossig);
    end
    
end     


locate(dlg,'east');
dlg.Hidden=false;
    
end %CurrentLoss

%% LiF window correction (Rigg et al., LA-UR-13-29106)
function LiFAV(src,varargin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'LiFAVDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;

h=addblock(dlg,'text','u=b1u*^b2');
h=addblock(dlg,'text','532  nm: b1 = 0.7827, b2 = 0.9902 (km/s)');
h=addblock(dlg,'text','1550 nm: b1 = 0.7895, b2 = 0.9918 (km/s)');
h=addblock(dlg,'check','Do not remove linear correction (1.2769)');
h=addblock(dlg,'edit','b1    '); set(h(2),'String', 0.7895);
h=addblock(dlg,'edit','b2    '); set(h(2),'String', 0.9918);



OkApplyCancel(dlg,@LiFCorr,'overlay');

locate(dlg,'east');
dlg.Hidden = false;

function newsig = LiFCorr(n)
    value = probe(dlg);
    b1 = str2double(value{2});
    b2 = str2double(value{3});
    [x y] = limit(sig{n});
    
    if ~value{1}
        y = y.*1.2769;
    end
    %0.7821 -> .8283 for km/s -> m/s
    %y = 1e3.*(b1.*(y*1e-3).^b2);
    y = real(b1.*y.^b2); 
    
    newsig = SMASH.SignalAnalysis.Signal(x,y);
end
end %LiF window correction

%% Window Shock 
function WindowShock(src,varargin)
    
% see if dialog already exists
dlg=FindOrCreateDlg(src,'WindowShockDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Window Shock Correction';
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

OkApplyCancel(dlg,@extrap,'overlay');

locate(dlg,'east');
dlg.Hidden = false;

function newsig = extrap(n)
    value = probe(dlg)
    [x y] = limit(sig{n});
    x1 = str2double(value{1});
    x2 = str2double(value{2});
    
    time_ext = 10e-9; 
    range=(x >= x1 & x <= x2);

    %Early time slope
    limit1 = (x >= x1 - time_ext & x <= x1);
    fit1 = polyfit(x(limit1),y(limit1),1);

    vlimit = (x >= x2);
    vshift = y(range)-polyval(fit1,x2); vshift = -vshift(end);

    %%%Shock solution correction
    n0 = 1.2769; c0 = 5150; s = 1.35;
    ulimit = y(range);
    u1 = ulimit(1);
    u2 = ulimit(end);
    Ib = (n0*(u2-polyval(fit1,x2)))/(c0+polyval(fit1,x2).*(1+s))
    
    y(vlimit) = (y(vlimit).*n0 - Ib.*(c0+s.*(polyval(fit1,x2))))./(n0+Ib);
    y(range) = polyval(fit1,x(range)); 
    
    newsig = SMASH.SignalAnalysis.Signal(x,y);
end
end %Window shock correction

%% Incremental Impedance Matching
function IMSignals(src,varargin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'IMDialog');
if ishandle(dlg)
    return
end 
dlg.Name = 'Impedance Matching (SI Units)';
dlg.Hidden = true;   
[~,~,~,~,~,~,windowoptions] = getHugProp('DefinedWindows');
[~,~,~,~,~,~,sampleoptions] = getHugProp('DefinedSamples');
h=addblock(dlg,'listbox','Select Window',windowoptions);
h=addblock(dlg,'listbox','Select Sample',sampleoptions);
h=addblock(dlg,'edit_check',{'Shock Time','Shock?'});

OkApplyCancel(dlg,@IM,'overlay');

function newsig = IM(n)
    value = probe(dlg);
    [rhow c0w sw g0w, Iuw, Icw] = getHugProp(value{1});
    [rhot c0t st g0t, Iut, Ict] = getHugProp(value{2});
    [t v] = limit(sig{n}.*1e-3); %ASSUME: Start SI );
    
        %Solve for shocked state is checked
        if value{3}
            %Only use t> tH
            tH = str2double(value{3});
            temp = find(t >= tH);
            tpost = t(temp);
            vpost = v(temp); 

            %NOTE: Units need to be km/s
            %Solve for shocked state in window
            uHw = vpost(1)
            Pw = @(u) rhow.*u.*(c0w+sw.*u);
            PHw = Pw(uHw)

            %Solve for shocked state in target
            u_init = 0;
            P_init = 0;

            PHt = @(u) rhot.*(u-u_init).*(c0t+st.*(u-u_init))+P_init;
            PHt_ref = @(x) PHt(x-u);

            urefl= fzero( @(x) PHt(x-uHw)-PHw,2*uHw)
            uHt = fzero( @(x) PHt(x) - PHt(urefl-x),uHw)
            PHt(uHt)
            shockvel = PHt(uHt)./(rhot*uHt)
            
            t = tpost; v = vpost;
        else
            uHt = 0;
        end
    
        uw = v;

        csamp = interp1(Iut, Ict, uw,'pchip','extrap');
        cwin = interp1(Iuw, Icw, uw,'pchip', 'extrap');
        
        %Initial conditions
        us(1) = uHt;
        %Uss(1) = c0t+st.*us(1);
        %Ps(1) = rhot.*us(1).*Uss(1);
        %es(1) = us(1)./Uss(1);

        %Incremental matching
        for n=2:length(uw)
            Zs = rhot.*mean([csamp(n), csamp(n-1)]);
            Zw = rhow.*mean([cwin(n), cwin(n-1)]); 
            us(n) = us(n-1)+(Zw+Zs)./(2.*Zs).*(uw(n)-uw(n-1));
            %Ps(n) = Ps(n-1)+Zs.*(us(n)-us(n-1));
            %es(n)= es(n-1)+(us(n)-us(n-1))./mean([csamp(n), csamp(n-1)]);
        end
        newsig = SMASH.SignalAnalysis.Signal(t, us*1e3);
end
            

locate(dlg,'east');
dlg.Hidden=false;
    
end %Incremental impedance matching

%% Inverse Lagrangian Analysis
function ILA(src,varargin)
    
% see if dialog already exists
dlg=FindOrCreateDlg(src,'ILADialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Inverse Lagrangian Analysis (SI units)';
h=addblock(dlg,'edit','Sample Thickness (mm)'); set(h(2),'String', '1');
h=addblock(dlg,'edit','Sample Density (g/cc)'); set(h(2),'String', '6.505');
h=addblock(dlg,'edit','Velocity Spacing (m/s)'); set(h(2),'String', '10');
h=addblock(dlg,'edit','Sample Response Path           '); set(h(2),'String', 'clu.dat');
h=addblock(dlg,'edit','Window Response Path           '); set(h(2),'String', '/remote/jlbrown/EOS/lif7271v3_Isentrope.dat');
%h=addblock(dlg,'edit','Window Response Path           '); set(h(2),'String', '/remote/jlbrown/EOS/FreeSurface.dat');

OkApplyCancel(dlg,@IL,'overlay');

function newsig = IL(n)
    value = probe(dlg);
    
    rho0 = str2double(value{2});
    XR = str2double(value{1});
    
    %Get window velocity data
    [up_time up_data] = limit(sig{n});

    %Make monotonic in up
    [~, ia]=unique(up_data);
    up_data = up_data(ia);
    up_time=up_time(ia);
   
   
    %Define up characterisitics and correspoding times
    up_array = 0:str2double(value{3}):up_data(end);
    N_char=length(up_array)
    time_array = interp1(up_data,up_time,up_array,'pchip','extrap');
    
    %Material response functions  
    %Window cl_up response, solve for window pressure
    windowdata = importdata(value{5});
    windowdata = windowdata.data;
    %cle_w = windowdata(:,6);
    %vol_w = windowdata(:,8);
    %cl_w = cle_w.*vol_w(1)./vol_w.*1e3;
    %ustar_w = windowdata(:,7).*1e3;
    %P_w = windowdata(:,3).*1e9;
    
    %cl_w = windowdata(:,7).*1e3;
    ustar_w = windowdata(:,6).*1e3;
    P_w = windowdata(:,3).*1e9;

    P_w_array = interp1(ustar_w,P_w,up_array,'pchip','extrap');
    
    %Material cl_up response
    sampledata=importdata(value{4}); 
    if isstruct(sampledata); sampledata=sampledata.data; end
    u_samp = sampledata(:,1)*1e3;
    cl_samp = sampledata(:,2)*1e3;
    
    %Sample cl_up, solve for ustar at window
    P_samp = rho0.*cumtrapz(u_samp,cl_samp)*1e3;

    %Sample response splines
    P_spline_guess = spline(u_samp,P_samp);
    Cl_spline_guess = spline(u_samp,cl_samp);
    

    %Initialize boundary condition
    ustar_array = interp1(P_samp,u_samp,P_w_array);
    temp = isnan(ustar_array); ustar_array(temp) = 0;
    
    %Initialize Variables
    up = zeros(N_char,N_char);
    ustar = zeros(N_char,N_char);
    Cl = zeros(N_char,N_char);
    P = zeros(N_char,N_char);
    X = zeros(N_char,N_char);
    t = zeros(N_char,N_char);
    

    %Initial conditions
     for i = 1:N_char
         up(i,i) = up_array(i);
         t(i,i) = time_array(i);
         ustar(i,i) = ustar_array(i);
         P(i,i) = P_w_array(i);
         X(i,i) = XR;
     end
     
     
    %Backwards characteristics looping   
    %Create waitbar
    wb=SMASH.MUI.Waitbar('Performing Inverse Lagrangian Analysis');
    for iposOuter = 1:N_char
        for ineg = 1:N_char-iposOuter   
            ipos = iposOuter+ineg;

            %Equations (5)            
            R_ipos = up(ineg+1,ipos)+ustar(ineg+1,ipos);
            R_ineg = up(ineg,ipos-1)-ustar(ineg,ipos-1);

            %Equations (6)
            up(ineg,ipos) = (R_ipos + R_ineg)/2;
            ustar(ineg,ipos) = (R_ipos - R_ineg)/2;

            %Equations (7) 
            Cl(ineg,ipos) = ppval(Cl_spline_guess ,ustar(ineg,ipos));
            if isnan(Cl(ineg,ipos)) | isinf(Cl(ineg,ipos))
                Cl(ineg,ipos)=0;
            end
            
            %P(ineg,ipos) = ppval(P_spline_guess ,ustar(ineg,ipos));

            %Equations (8)
            C_ipos = (Cl(ineg,ipos)+Cl(ineg+1,ipos))/2;
            C_ineg = (Cl(ineg,ipos)+Cl(ineg,ipos-1))/2;

            %Equation (9)
            t(ineg,ipos) = (X(ineg,ipos-1)-X(ineg+1,ipos)+C_ineg*t(ineg,ipos-1)+C_ipos*t(ineg+1,ipos))/(C_ipos+C_ineg);

            %Equation (10)
            X(ineg,ipos) = X(ineg,ipos-1) - C_ineg*(t(ineg,ipos)-t(ineg,ipos-1));

            %Equations (11)
            t_iposR(ipos) = t(1,ipos) + (XR-X(1,ipos))/Cl(1,ipos);
            ustar_iposR(ipos) = ustar(1,ipos);
        end
    update(wb,iposOuter/N_char);    
    end
    delete(wb);
    
    newx = t_iposR(2:end)';
    newy = ustar_iposR(2:end)';
     
    [~, ia] = unique(newx); newx = newx(ia); newy = newy(ia);
    newsig = SMASH.SignalAnalysis.Signal(newx,newy);
    
    
end

locate(dlg,'east')
dlg.Hidden = false;
end %Inverse Lagrangian analysis

%% Lagrangian Analysis (In-Situ Velocities Only)
function LA(src,varargin)
    
% see if dialog already exists
dlg=FindOrCreateDlg(src,'LA');
if ishandle(dlg)
    return
end

%% SignalGroup(time, [u cl density stress])
LA_result = SMASH.SignalAnalysis.SignalGroup(0,[0 0 0 0]);
stress0 = 0; strain0 = 0; thickness = 0;

dlg.Hidden = true;
dlg.Name = 'InSitu Lagrangian Analysis';
h=addblock(dlg,'edit','Initial density:');
for i =1:numel(sig_num);
    name = sprintf('%s thickness:',sig{sig_num(i)}.Name);
    h = addblock(dlg,'edit',name);
end

h = addblock(dlg,'edit','Initial Strain'); set(h(2),'String', 0);
h = addblock(dlg,'edit','Initial Stress'); set(h(2),'String', 0);
h = addblock(dlg,'check',{'Unloading Only','Loading Only'}); 

h = addblock(dlg,'button',{'Perform Analysis','Save Results','Cancel'});
dlg.Hidden = false;

set(h(1),'Callback',@PerformCallback);
function PerformCallback(varargin)
    time = []; u = []; cl = [];  stress = []; rho =[]; strain =[];
    %Hardwired parameters
    num_upoints = 10.0e3; 
    
    %Get parameters
    value = probe(dlg);
    rho0 = str2double(value{1});
    thickness = [];
    for i = 2:numel(sig_num)+1;
        thickness(i-1) = str2double(value{i});
    end
    
    
    %If only 1 signal, create a 0 time "shock"
    if numel(sig_num) == 1
        [time vel] = limit(sig{sig_num(1)});
        dt = (min(time)+max(time))/numel(time);
        tshock = [0;dt/20;dt/10];
        vshock = [0;max(vel);0];
        sig_tot = sig_tot+1;
        sig{sig_tot} = SMASH.SignalAnalysis.Signal(tshock,vshock);
        sig{sig_tot}.Name = 'CenteredWaveSource';
        %Set some object properties
        sig{sig_tot}.GraphicOptions.LineWidth=3;
        sig{sig_tot}.GraphicOptions.LineColor=DistinguishedLines(sig_tot);
        sig_num = [sig_num sig_tot];
        thickness(end+1) = 0;
    end
        
    strain0 = str2double(value{i+1});
    stress0 = str2double(value{i+2});
    unloadingonly = value{i+3};
    loadingonly = value{i+4};
    
    %Get signals
    t = []; us = [];
    for i = 1:numel(sig_num);   
        [t{i} us{i}] = limit(sig{sig_num(i)});
        %[t{i} ia] = unique(t{i}); u{i} = u{i}(ia); 
        %Assume SI units, scale to km/s
        t{i}=t{i}.*1e6;
        us{i}=us{i}.*1e-3;

        [maxu(i) maxu_index(i)] = max(us{i});
        [minu(i) minu_index(i)] = min(us{i});
        endu(i)  = us{i}(end);
    end

    %Define loading and unloading
    [umax index] = min(maxu);
    if maxu_index(index)+1 <= length(us{index})
        umax2 = us{index}(maxu_index(index)+1);
    else
        umax2 = umax;
    end
    umin = max(minu);
    uend = max(endu);

    if umin <= 0;umin = 0;end

    uload = linspace(umin,umax,num_upoints)';
    uunload = flipud(linspace(uend,umax2,num_upoints)');


    %Interploate to find times
    for i = 1:numel(sig_num); 
        if numel(t{i}(1:maxu_index(i))) > 1
            utemp = us{i}(1:maxu_index(i)); ttemp = t{i}(1:maxu_index(i));
            [~, ia] = unique(utemp); utemp = utemp(ia); ttemp = ttemp(ia);
            tload{i}=interp1(utemp,ttemp,uload,'linear',t{i}(maxu_index(i)));
        else
            uload = []; 
        end
        
        %if numel(t{i}(maxu_index(i):end)) > 1
        try
            utemp = us{i}(maxu_index(i):end); ttemp = t{i}(maxu_index(i):end);
            [~, ia] = unique(utemp); utemp = utemp(ia); ttemp = ttemp(ia);
            tunload{i}=interp1(utemp,ttemp,uunload,'linear',t{i}(maxu_index(i)));
        %else
        catch
            uunload = [];  
        end
    end  
    
    
    %Don't use fits for unloading and loading if selected
    if unloadingonly; uload = []; end
    if loadingonly; uunload = []; end
    
    u = [uload; uunload];
    for i = 1:numel(sig_num); 
        if isempty(uload)
            tload{i} = [];
        elseif isempty(uunload)
            tunload{i} = [];
        end
        t_tot{i} =[tload{i}; tunload{i}];
    end
            
    
    %Least squares fit c(u)
    tarray=[]; xarray=[];
    for i=1:numel(t_tot)
        tarray(i,:) = t_tot{i};
        xarray(i,:) = tarray(i,:).*0 + thickness(i);
    end

    for i=1:length(tarray)
        p{i} = polyfit(tarray(:,i),xarray(:,i),1);
        cl(i,1) = p{i}(1);
    end
    
    
    %Integrate conservation equations
    stress = stress0+rho0.*cumtrapz(u,cl);
    strain = strain0+cumtrapz(u,1./cl);
    rho = rho0./(1-strain);
    
%     %Convert to true strain
%     truestrain = log(1+strain);
%     
%     %Convert to 2nd Piola Kirchoff stress
%     stretch = 1+strain;
%     PKstress=stress./stretch;
    
    %figure; plot(u,cl)

    %Compile result and grid uniformly
    [~,ia]=unique(t_tot{index});
    LA_result = SMASH.SignalAnalysis.SignalGroup(t_tot{index}(ia),[u(ia),cl(ia),rho(ia),stress(ia)]);
    LA_result = regrid(LA_result);
    [time LA_array] = limit(LA_result);

%     %Calculate strain rate
%     [time LA_array] = limit(LA_result);
%     d = differentiate(LA_result);
%     %xfilt = 200; Nsmooth=int32(length(LA_array(:,8))./xfilt); %LowPassFilt
%     %kernel = ones(Nsmooth,1);kernel = kernel/sum(kernel);
%     %d = regrid(d); d = smooth(d,'kernel',kernel);
%     [temp dLA_array] = limit(d); LA_array(:,8) = dLA_array(:,8);
%     
%     LA_result = SMASH.SignalAnalysis.SignalGroup(time,LA_array);
    
    
%Plot results
        LAResults=figure('Name','Results of Lagrangain Analysis','Units','normalized','Position',[.1,.1,.8,.8]);
        figure(LAResults);
        
        
        %Plot interpolated points
        subplot(1,2,1)
        plotdata(LAResults,sig,sig_num); axis tight;
        for i = 1:numel(sig_num);
            line(tload{i}*1e-6,uload*1e3,'Color','k');
            line(tunload{i}*1e-6,uunload*1e3,'Color',[0.5 0.5 0.5]);  
            line(tload{i}*1e-6,uload*1e3,'Marker','o','MarkerSize',4,'Color','k');
            line(tunload{i}*1e-6,uunload*1e3,'LineStyle','none','Marker','o','MarkerSize',4,'Color',[0.5 0.5 0.5]);     
        end
        title('Profile Interpolation'); xlabel('Time'); ylabel('Particle Velocity');
        text((t_tot{1}(end)+t_tot{end}(end))/2e6,max(u)'*1e3,sprintf('Attenuation = %f',max(maxu)-min(maxu)));
        
        %Wavespeed response
        subplot(1,2,2);
        plot(LA_array(:,1),LA_array(:,2),'LineWidth',3);
        title('Wavespeed Response'); xlabel('Particle Velocity'); ylabel('Wavespeed');
        
        hin = axes('Position',[.62 .7 .2 .2]); plot(strain,stress,'LineWidth',3);
         xlabel('Strain'); ylabel('Stress');
        
        %x-t diagram
        stepnum=50;
        hin = axes('Position',[0.2 .3 .2 .2]); 
        hold on; hold all;
        for i=1:numel(t_tot)
            step=int32(length(xarray(i,:))./stepnum-1);
            for j=1:stepnum
             xp(i,j)=xarray(i,step.*j);
             tp(i,j)=tarray(i,step.*j);
            end
            
            plot(xp(i,:),tp(i,:),'o'); 
        end

        xpp=linspace(min(thickness),max(thickness),100);
        for j=1:stepnum
             %tpp=(min(tp(j,:)):(max(tp(j,:))-min(tp(j,:)))/100:max(tp(j,:)));
             %xpp=(p{step.*j}(1)).*tpp+p{step.*j}(2);
             tpp=(xpp-p{step.*j}(2))./(p{step.*j}(1));
             line(xpp,tpp,'Color','k');
        end
        title('Characteristics'); xlabel('Position'); ylabel('Time');
    
end

set(h(2),'Callback',@SaveCallback);
function SaveCallback(varargin)
   [savename, savepath] = uiputfile({'*.dat;*.txt;*.out','All ASCII Files'; '*.sda','SandiaDataArchive'; ...
   '*.*','All Files'}, 'Save Lagrangian Analysis Results');
    saveas = fullfile(savepath,savename);
    
    [~,~,ext]=fileparts(savename);
    if strcmp(ext,'.sda')
       labelname = inputdlg('Enter label name for sda file'); labelname = labelname{1}; 
       store(LA_result,fullfile(savepath,savename),labelname);
    else 
        fid=fopen(saveas,'w');   
        fprintf(fid,'# LagrangianAnalysis of:');
        for i = 1:numel(sig_num)
            fprintf(fid,'%s (thickness = %f),',sig{sig_num(i)}.Name,thickness(i));
        end
        fprintf(fid,'\n# Initial stress: %f , Initial strain : %f',stress0,strain0);
        fprintf(fid,'\n# time\tup\tcl\tdens\tstress\n'); 
        [time LA_array] = limit(LA_result);
        dlmwrite(saveas, [time' LA_array],'-append','delimiter','\t','precision','%10.8e');
        fclose(fid);
    end    
end

set(h(3),'Callback',@CancelCallback);
function CancelCallback(varargin)
    delete(dlg);
end

end %Lagrangian analysis

%% Integrate wavespeed-particle velocity response
function IntegrateWavespeed(src,varargin)
    
% see if dialog already exists
dlg=FindOrCreateDlg(src,'IntegrateWavespeed');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Integrate conservation equations';
h=addblock(dlg,'edit_check',{'Initial density','Output LA file'});
dlg.Hidden = false;

OkApplyCancel(dlg,@IW);

function newsig = IW(n)
    value = probe(dlg);
    rho0 = str2double(value{1}); 
    [u cl] = limit(sig{n});
    %Integrate conservation equations (simple wave assumption)
    stress = rho0.*cumtrapz(u,cl);
    strain = cumtrapz(u,1./cl);
    dens = rho0./(1-strain);
    newsig = SMASH.SignalAnalysis.Signal(dens,stress);
 

    %If checked, write file
    if value{2}
        t = 1:length(u); t = reshape(t,size(u));
        savepath = fullfile(pathname,horzcat(sig{n}.Name,'_Integratedclup.txt'))
        fid=fopen(savepath,'w');       
        fprintf(fid,'time\tup\tcl\tdens\tstress\n');
        dlmwrite(savepath, [t,u,cl,dens,stress],'-append','delimiter','\t','precision','%10.6f');
        fclose(fid);
    end
    
end

end %Integrate cons eqns

%% Create Sesame
function CreateSesame(src,varargin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'SesameDialog');
if ishandle(dlg)
    return
end 
dlg.Name = 'Create Limited Range Sesame Table';
dlg.Hidden = true;   

%int: rho0,g0,L,cv,Z,AW,K0
%Cv (mgrun.ref to Sesame units): cv*1e-10/11604.5
%Cv (mgrun.ref to SI units): cv*1e-4/11604.5

%init = [19.24,2.97,1,1.2667e-4,79,1.9697e2,1.66953e2]; % Au
init = [16.55,1.6,1,1.3788e-4,73,1.80948e2,1.9953e2]; % Ta
%init = [1.84,1.19,1,2.7662e-3,4,9.0122,1.13367372e2]; % Be
%init = [21.02,2.44,1,1.3357e-4,75,1.86207e2,3.70e2]; % Re
%init = [10.915,2.5,1,1.2064e-4,82,207.2,4.178e2]; % Pb
%init = [2.5,0.5,1,8.0e-4,10,60.08,39.0]; % Soda Lime Glass
%init = [2.21,0.5,1,8.0e-4,10,60.08,39.0]; % Borosilicate Glass

ReferenceOptions={'cuisentrope','pdisentrope','usup','pdhugoniot'};
h=addblock(dlg,'listbox','ReferenceCurveType',ReferenceOptions);

h=addblock(dlg,'edit','Initial Density'); set(h(2),'String', init(1));
h=addblock(dlg,'edit','Initial Gruneisen'); set(h(2),'String', init(2));
h=addblock(dlg,'edit','Gruneisen power (L)'); set(h(2),'String', init(3));
h=addblock(dlg,'edit','Specific Heat'); set(h(2),'String', init(4));


h = addblock(dlg,'text',' ');
h = addblock(dlg,'text','Table 201 Specifications:');
h=addblock(dlg,'edit','Atomic Number'); set(h(2),'String', init(5));
h=addblock(dlg,'edit','Atomic Weight'); set(h(2),'String', init(6));
h=addblock(dlg,'edit','Initial Bulk Modulus'); set(h(2),'String', init(7));

h = addblock(dlg,'check','Also Create Binary Version');
h = addblock(dlg,'button','Create Table');
set(h(1),'Callback',@PerformCallback);
function PerformCallback(varargin);
    for i = 1:length(sig_num)
        
        %Create Sesame object
        value = probe(dlg);
        [x y] = limit(sig{sig_num(i)});
        rho0 = str2num(value{2});
        g0 = str2num(value{3});
        L = str2num(value{4});
        cv = str2num(value{5});
        sesobj = SMASH.DynamicMaterials.EOS.Sesame('Mie-Gruneisen',value{1},x,y,rho0,g0,L,cv,298.15,1.0e4,300,100);
        [sesname,sespath] = uiputfile({'*.*','All Files';'*.ses*;*.a;*.asc','Sesame Files'},'Select Sesame File');
        
        %Table 201 paramters
        Z = str2num(value{6});
        W = str2num(value{7});
        K = str2num(value{8});
        
        %Create ascii version of table
        export(sesobj,fullfile(sespath,sesname),9999,Z,W,rho0,K,298)
        
        %Also create binary. REQUIRES bcat on path
        if value{9}
            [path, name, ext] = fileparts(fullfile(sespath,sesname));
            currdir = pwd;
            oldname = sprintf('%s%s',name,ext);
            newname = sprintf('%s.b',name);
            cd(path);
            command = sprintf('bcat <<EOF\nnone\nasc2bin\n%s %s\nyes\nquit\nEOF',oldname,newname);
            unix(command);
            cd(currdir);

        end
    end
end
            

locate(dlg,'east');
dlg.Hidden=false;
    
end %Sesame Table


%%%%%%%%%%% Programs Launcher %%%%%%%%%%%%%
function PointVISARLaunch(src,varargin)    
    PointVISAR('-gui');
end %PointVISAR

function SIRHENLaunch(src,varargin)    
    SIRHEN;
end %SIHREN

function datninjaLaunch(src,varargin)        
    datninja;
end %datninja

function MGrunP_uLaunch(src,varargin)
    SMASH.DynamicMaterials.Impact;
end %ImpedanceMatching

function StrengthLaunch(src,varargin)
    SMASH.DynamicMaterials.StrengthGUI;
end %StrengthGUI


%%%%%%%%%%% Plotting Callbacks %%%%%%%%%%%%%

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
    marksize = get(lh,'MarkerSize');
    if ~iscell(marksize); marksize = {marksize}; end;
    
    %Update as long as signal numbering is OK
    if (numel(color) == numel(sig_num))
        for i = 1:numel(sig_num);
            index = numel(color)+1-i;
            sig{sig_num(i)}.GraphicOptions.LineWidth=width{index,1};
            sig{sig_num(i)}.GraphicOptions.LineColor=color{index,1};
            sig{sig_num(i)}.GraphicOptions.LineStyle=style{index,1};
            sig{sig_num(i)}.GraphicOptions.Marker=mark{index,1};
            sig{sig_num(i)}.GraphicOptions.MarkerSize=marksize{index,1};
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
dlg.Hidden = false

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
       for i = 2:numel(sig_num);
           newsig{i} = SMASH.SignalAnalysis.Signal(0,0);
       end
       
       for i=1:numel(sig_num)
           newindex(i)
          sig_num(i)
            newsig{newindex(i)} = sig{sig_num(i)};
       end
       sig = newsig;
       clear newsig;

       plotdata(fig.Handle,sig,sig_num);
       delete(dlg);
    end
    
    set(h(2),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
end %Order 

%% Label signal callback
function EditAxisLabel(src,varagin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'AxisLabelDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Axis Labels';

%Create edit box for each signal
h=addblock(dlg,'edit','Grid Axis Label'); set(h(2),'String', sig{sig_num(1)}.GridLabel);
h=addblock(dlg,'edit','Data Axis Label'); set(h(2),'String', sig{sig_num(1)}.DataLabel);

h=addblock(dlg,'button',{ 'Apply Label Change', 'Cancel'});

dlg.Hidden = false;

%Define button callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       newnames = probe(dlg);
       for i=1:numel(sig_num)
            sig{i}.GridLabel = newnames{1};
            sig{i}.DataLabel = newnames{2};
       end
    plotdata(fig.Handle,sig,sig_num);
    delete(dlg);
    end
    
    set(h(2),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
end %Label 

%% Percent Difference
function PercentDifference(src,varargin)
    
    %Find absolute min and max
    xmin=[]; xmax=[];
    for i=1:numel(sig_num)
        xmin = [xmin;min(sig{sig_num(i)}.Grid)];
        xmax = [xmax;max(sig{sig_num(i)}.Grid)];
    end
    
    x=linspace(max(xmin),min(xmax),2e3)';
    
    %Find common y
    for i=1:length(sig_num)
        y{i} = lookup(sig{sig_num(i)},x);
    end
    newsig = sig;
    %Calculate % difference from 1st signal
    for i=1:length(sig_num)
        PercentDiff{i} = ((y{i}-y{1})./y{1})*100;
        newsig{sig_num(i)} = SMASH.SignalAnalysis.Signal(x,PercentDiff{i});
        %Set some object properties
        newsig{sig_num(i)}.GraphicOptions=sig{sig_num(i)}.GraphicOptions;
        newsig{sig_num(i)}.GridLabel= 'x'; newsig{i}.DataLabel= '% from 1st signal';
        legendentry{i}=strrep(sig{sig_num(i)}.Name,'_','\_');
    end
    
    %Create plot
    fig2=figure('units','normalized','Position',[.10,.10,0.7,0.7]); 
    movegui(fig2,'center');
    for i=1:length(sig_num)
    h1 = subplot(2,1,1); view(sig{sig_num(i)},fig2); title('Signals'); axis tight; 
    h2 = subplot(2,1,2); view(newsig{sig_num(i)},fig2); title('Percent Difference');
    end
                        
    legend(legendentry,'Color','none'); legend('boxoff');
    hold off;
    set(gcf,'Color','w');
    linkaxes([h1 h2],'x');
    axis([x(1) x(end) -10*max(mean(cell2mat(PercentDiff))) 10*max(mean(cell2mat(PercentDiff)))]); 
end %Percent difference


%% Velocity Residuals
function VelocityResiduals(src,varargin)
    
    %Find absolute min and max
    xmin=[]; xmax=[];
    for i=1:numel(sig_num)
        xt = limit(sig{sig_num(i)});
        xmin = [xmin;min(xt)];
        xmax = [xmax;max(xt)];
    end
    xmin = max(xmin); xmax = min(xmax);
    
    %Limit range of first curve
    %vobj=limit(sig{sig_num(1)},[xmin xmax]);
    texp = linspace(xmin,xmax,5e3)';
    vobj = regrid(sig{sig_num(1)},texp);
    [texp,vexp]=limit(vobj);
    
    
    %Calculate error in velocity curve
    evis = sqrt((0.002.*vexp).^2 + 8.4^2);
    tvis = [];
    
%     %Total variance w/ time:
%     dt = 0.5e-9; ndt = 100; % Time variance settings
%     tvis = evis*0;
%     for i = 1:length(texp)
%         if texp(i)+dt >= max(texp)
%             tlookup = linspace(texp(i)-dt,texp(i),ndt);
%         elseif texp(i)-dt <= max(texp)
%             tlookup = linspace(texp(i),texp(i)+dt,ndt);
%         else
%             tlookup = linspace(texp(i)-dt,texp(i)+dt,ndt);
%         end
%         vel = interp1(texp,vexp,tlookup,'linear',0);
%         tvis(i) = var(vel);
%     end
    
    fh = SMASH.Graphics.AIPfigure(4,'14in'); fh.Color='w'; delete(gca);
    ax1 = axes('Parent',fh,'Units','normalized','Position',[0.125 0.55 0.85 0.4]); box on; hold on;
    set(gca,'LineWidth',2.0,'FontSize',24);
    ax2 = axes('Parent',fh,'Units','normalized','Position',[0.125 0.15 0.85 0.4]); box on; hold on;
    set(gca,'LineWidth',2.0,'FontSize',24);
    linkaxes([ax1,ax2],'x');
    
    
    %Plot velocity trace
    axes(ax1);
    if ~isempty(tvis)
        hfill=fill([texp' fliplr(texp')],[(vexp+2*(evis+tvis))',fliplr((vexp-2*(evis+tvis))')],[0.75,0.75,0.75]);
        hfill.EdgeColor=[0.75 0.75 0.75];
    end
    hfill=fill([texp' fliplr(texp')],[(vexp+2*evis)',fliplr((vexp-2*evis)')],[0.6,0.6,0.6]);
    hfill.EdgeColor=[0.6 0.6 0.6];
    %uistack(hfill,'bottom');
    he = line(texp,vexp); he.Color = 'k';
    ylabel(sig{sig_num(1)}.DataLabel,'FontSize',32);
    ax1.XTickLabel = [];
    ax1.YLim = [0,max(vexp+2*evis)];
    
    
    
    %Plot residuals
    axes(ax2);
    if ~isempty(tvis)
        hfill=fill([texp' fliplr(texp')],[(2*(evis+tvis))',fliplr((-2*(evis+tvis))')],[0.75,0.75,0.75]);
        hfill.EdgeColor=[0.75,0.75,0.75];
    end
    hfill=fill([texp' fliplr(texp')],[(2*evis)',fliplr((-2*evis)')],[0.6,0.6,0.6]);
    hfill.EdgeColor=[0.6,0.6,0.6];
    he = line(texp,texp.*0); he.Color = 'k';
    xlabel(sig{sig_num(1)}.GridLabel,'FontName','times','FontAngle','normal','FontSize',32);
    ylabel('Residual','FontSize',32);
    ax2.XLim = [xmin,xmax];
    

    %Loop through and plot each
    maxr = 0;
    for i=2:length(sig_num)
        col =  sig{sig_num(i)}.GraphicOptions.LineColor;
        y = lookup(sig{sig_num(i)},texp);
        axes(ax1);
        hs = line(texp,y); hs.Color = col;
        axes(ax2);
        hs = line(texp,vexp-y); hs.Color = col;
        maxr = max(maxr,max(abs(vexp-y)));
    end
    maxr = max(max(2*(evis+tvis)),maxr);
    ax2.YLim = [-maxr,maxr];
   
end %Velocity Residuals




%% Large plot 
function BigPlot(src,varargin)
    AIPFig = SMASH.Graphics.AIPfigure(4,'11in');
    set(AIPFig,'name','AIP Large Fig');
    plotdata(AIPFig,sig,sig_num)

    set(gca,'FontName','times','FontAngle','normal','LineWidth',2.5,'FontSize',30);
    set(gcf,'Color','w');
    box on;
    xlabel(sig{sig_num(1)}.GridLabel,'FontName','times','FontAngle','normal','FontSize',40);
    ylabel(sig{sig_num(1)}.DataLabel,'FontName','times','FontAngle','normal','FontSize',40);
    
end %Big plot

%% Single column AIP
function AIPFigure1(src,varargin)
    AIPFig = SMASH.Graphics.AIPfigure(1);
    set(AIPFig,'name','AIP Single Column Fig');
    
    for i=1:length(sig_num); sig{sig_num(i)}.GraphicOptions.LineWidth=1; end;
    plotdata(AIPFig,sig,sig_num)
    for i=1:length(sig_num); sig{sig_num(i)}.GraphicOptions.LineWidth=3; end;
    
    set(gca,'FontName','times','FontAngle','normal','FontSize',10);
    set(gcf,'Color','w'); box on;
    xlabel(sig{sig_num(1)}.GridLabel,'FontName','times','FontAngle','normal','FontSize',12);
    ylabel(sig{sig_num(1)}.DataLabel,'FontName','times','FontAngle','normal','FontSize',12);

end %AIP single column

%% Double column AIP
function AIPFigure2(src,varargin)
    AIPFig = SMASH.Graphics.AIPfigure(2);
    set(AIPFig,'name','AIP Double Column Fig');
    
    for i=1:length(sig_num); sig{sig_num(i)}.GraphicOptions.LineWidth=1; end;
    plotdata(AIPFig,sig,sig_num)
    for i=1:length(sig_num); sig{sig_num(i)}.GraphicOptions.LineWidth=3; end;
    
    set(gca,'FontName','times','FontAngle','normal','FontSize',10);
    %box off; 
    set(gcf,'Color','w'); box on;
    xlabel(sig{sig_num(1)}.GridLabel,'FontName','times','FontAngle','normal','FontSize',12);
    ylabel(sig{sig_num(1)}.DataLabel,'FontName','times','FontAngle','normal','FontSize',12);
end %AIP double column

%% Create dual axes plot
function DualAxes(src,varargin)
    AIPFig = SMASH.Graphics.AIPfigure(4,'11in');
    set(AIPFig,'name','Dual Axis Fig');
    ax1 = axes; ax2 = axes;
    linkaxes([ax1 ax2],'x');
    
    %Plot all signals except last
    axes(ax1);
    if ~isempty(sig_num)
        legendentry = [];
        for i=1:length(sig_num)-1
            ph(i) = view(sig{sig_num(i)},AIPFig);
            legendentry{i}=strrep(sig{sig_num(i)}.Name,'_','\_');
        end
     
     axis tight;

    
     %Plot last signal on right axis
     set(ax2,'YAxisLocation','right','Color','none','YColor',sig{sig_num(i+1)}.GraphicOptions.LineColor);
     axes(ax2);
     ph(i+1) = line(sig{sig_num(i+1)}.Grid,sig{sig_num(i+1)}.Data);
     %apply(sig{sig_num(i+1)}.GraphicOptions,ph(i+1));
     set(ph(i+1),'Color',sig{sig_num(i+1)}.GraphicOptions.LineColor,'LineWidth',sig{sig_num(i+1)}.GraphicOptions.LineWidth, ...
         'LineStyle',sig{sig_num(i+1)}.GraphicOptions.LineStyle);
     %ph(i+1)=view(sig{sig_num(i+1)},AIPFig);
     %ph(i+2)=view(sig{sig_num(i+2)},ax2);    
     legendentry{i+1}=strrep(sig{sig_num(i+1)}.Name,'_','\_');
     %legendentry{i+2}=strrep(sig{sig_num(i+2)}.Name,'_','\_');
     legend(ph,legendentry,'Color','none','Location','Best','EdgeColor','w');
     legend('boxoff');
     
     
    set(ax1,'XColor','w'); 
    xlabel(ax2,sig{sig_num(1)}.GridLabel,'FontSize',40); 
    ylabel(ax1,sig{sig_num(1)}.DataLabel,'FontSize',40); ylabel(ax2,sig{sig_num(end)}.DataLabel,'FontSize',40);
    set(ax1,'FontName','times','FontAngle','normal','FontSize',30);
    set(ax2,'FontName','times','FontAngle','normal','FontSize',30);
    set(gcf,'Color','w');
    pause(0.1);
    ax1.Position = ax2.Position;

    
    
    end

end %Dual axes

%% Create an inset
function AIPAxesInset(src,varargin)
    
AxisMod(0,@inset);
    function [h] = inset(limits)
        h = SMASH.Graphics.AxesInset('xlim',limits(1:2),'ylim',limits(3:4));
    end
    

    
end %Inset

%% Define axis limits
function SetAxis(src,varargin)
    
AxisMod(0,@changeaxis);

    function [] = changeaxis(limits)
        axis(limits);
    end
    
end %Limits


%% Print current plot
function PrintPlot(src,varargin)
    x = inputdlg({'Plot Name','Resolution (dpi)','Extension (eg. png, bmp, tiff, pdf, epsc)'},'Print Plot', [1 40;1 20;1 20],{'Plot','300','png'}); 
    
    fighandles = findobj('type','figure');
    
    print(fighandles(2),x{1},['-d' x{3}],['-r' x{2}],'-painters');
end %Limits



%%
function Template(src,varargin)
    
% see if dialog already exists
dlg=FindOrCreateDlg(src,'TempDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Temp Signal';
h=addblock(dlg,'edit','Lower Bound');
dlg.Hidden = false;

OkApplyCancel(dlg,@FUN,'overlay');

function newsig = IM(n)
    newsig = sig{n};
end

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
        plotdata(fig.Handle,sig,sig_num);
        plotdata(fig.Handle,newsig,sig_num,'overlay');
    elseif strcmp(options,'overlay_all')
        plotdata(fig.Handle,sig,sig_num);
        plotdata(fig.Handle,newsig,sig_num,'overlay_all');     
        plotdata(fig.Handle,newsig,sig_num,'overlay');      
    else
        plotdata(fig.Handle,newsig,sig_num);
    end
    figure(dlg.Handle);
end

set(h(2),'Callback',@OKCallback);
function OKCallback(varargin)
    for i = 1:length(sig_num)
        if strcmp(redo,'redo')
            sig{sig_num(i)} = func(sig_num(i)); 
        else
            %Don't redo the apply calculation if it's been done
            if numel(newsig{sig_num(i)}.Grid) > 1
                sig{sig_num(i)}=reset(sig{sig_num(i)},newsig{sig_num(i)});
            else
                sig{sig_num(i)}=reset(sig{sig_num(i)},func(sig_num(i)));
            end
        end
    end
    plotdata(fig.Handle,sig,sig_num);
    clear newsig; clear previous;
    if ~strcmp(options,'preserve'); delete(dlg); end
end

set(h(3),'Callback',@CancelCallback);
function CancelCallback(varargin)
    plotdata(fig.Handle,sig,sig_num);
    delete(dlg);  clear newsig;  
end
end


%% Axis modification
function AxisMod(src,varargin)

    if (nargin < 1)
    error('Require function handle')
    else
        func = varargin{1};
    end
    
    %Close all figures expect those of potential interest
    fighandles = findobj('type','figure');
    fignames = get(fighandles,'name'); 
    if ~iscell(fignames); fignames = {fignames}; end;
    for i=1:numel(fignames);
        switch fignames{i}
            case 'SMASH Signal GUI'
            case 'AIP Large Fig'
            case 'AIP Single Column Fig'
            case 'AIP Double Column Fig'
            otherwise
                close(fighandles(i));
        end
    end
    fighandles = findobj('type','figure');
    fignames = get(fighandles,'name');
    if ~iscell(fignames); fignames = {fignames}; end;
    
    % see if dialog already exists
    dlg=FindOrCreateDlg(src,'AxesInsetDialog');
    if ishandle(dlg)
        return
    end

    dlg.Hidden = true;
    dlg.Name = 'Axis Modification';

    h=addblock(dlg,'listbox','Select Figure',fignames);
    h=addblock(dlg,'edit','xmin        '); set(h(2),'String',min(sig{sig_num(1)}.Grid));
    h=addblock(dlg,'edit','xmax        '); set(h(2),'String',max(sig{sig_num(1)}.Grid));
    h=addblock(dlg,'edit','ymin        '); set(h(2),'String',min(sig{sig_num(1)}.Data));
    h=addblock(dlg,'edit','ymax        '); set(h(2),'String',max(sig{sig_num(1)}.Data));
    h=addblock(dlg,'button',{'Apply','OK','Cancel'});
   
    box_h = [];
    %Define callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
        if ishandle(box_h); delete(box_h); end
        values=probe(dlg);
        dlg_hc = get(dlg.Handle,'Children');
        hn=get(dlg_hc(12),'Value');
        limits = [sort([str2double(values(2)) str2double(values(3))]) sort([str2double(values(4)) str2double(values(5))])];
        figure(fighandles(hn));
        box_h(1) = line([limits(1) limits(2)],[limits(3) limits(3)],'Color','k','LineStyle','--','LineWidth',3);
        box_h(2) = line([limits(1) limits(2)],[limits(4) limits(4)],'Color','k','LineStyle','--','LineWidth',3);
        box_h(3) = line([limits(1) limits(1)],[limits(3) limits(4)],'Color','k','LineStyle','--','LineWidth',3);
        box_h(4) = line([limits(2) limits(2)],[limits(3) limits(4)],'Color','k','LineStyle','--','LineWidth',3);
        figure(dlg.Handle)
        
    end

    set(h(2),'Callback',@OKCallback);
    function OKCallback(varargin)
        if ishandle(box_h); delete(box_h); end
        values=probe(dlg);
        dlg_hc = get(dlg.Handle,'Children');
        hn=get(dlg_hc(12),'Value');
        limits = [sort([str2double(values(2)) str2double(values(3))]) sort([str2double(values(4)) str2double(values(5))])];
        if ishandle(box_h); delete(box_h); end
        figure(fighandles(hn));
        func(limits);
        %delete(dlg);
    end
    
    set(h(3),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        if ishandle(box_h); delete(box_h); end
        delete(dlg);
    end

    
    locate(dlg,'center');
    dlg.Hidden = false;
    
end




end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End SignalGUI



%% utilities

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
function plotdata(varargin)
    if (nargin < 3)
        error('Require (figure handle, signal object, signal numbers)')
    else
        fig = varargin{1};
        sig = varargin{2};
        sig_num = varargin{3};
        options = 'new plot';
    end
    if (nargin ==4); options = varargin{4}; end;
    
    figure(fig);
    ha=gca;

    switch lower(options)
        case 'new plot'
            cla;

            if ~isempty(sig_num)
                legendentry = [];
                for i=1:length(sig_num)
                    %set(sig{sig_num(i)}.GraphicOptions,'LineWidth',1);                 
                    view(sig{sig_num(i)},ha);
                    legendentry{i}=strrep(sig{sig_num(i)}.Name,'_','\_');
                end
                lh = legend(legendentry,'Color','none','Location','Best','EdgeColor','w','LineWidth',1);
                legend('boxoff');
                %set(lh,'Box','off');
                xlabel(sig{sig_num(1)}.GridLabel);
                ylabel(sig{sig_num(1)}.DataLabel);
            end
           
            
        case 'overlay'    
            %Current signals in black
            for i=1:length(sig_num)
            [tempsigx tempsigy] = limit(sig{sig_num(i)});
            line(tempsigx, tempsigy,'Color',[0 0 0],'LineStyle','--','LineWidth',2);
            end  
            
      
        case 'overlay_all'
            
            %All signals in grey
            for i=1:numel(sig)
            [tempsigx tempsigy] = limit(sig{i});
            line(tempsigx, tempsigy,'Color',[0.75 0.75 0.75],'LineStyle','-.','LineWidth',2);
            end  

            
    end
end

%% Line colors initilization (modified from PointVISAR)
function color=DistinguishedLines(number)

map=[];
map = get(groot,'DefaultAxesColorOrder');

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
            'LiF','Lead','Molybdenum','Stainless Steel','Tantalum',...
            'Rhenium','Zirconium','Zirconium1','Zirconium2','Epoxy'};
        
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
            'Stainless Steel','Tantalum','Rhenium','Epoxy'};
        
    
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
    
    case 'Lead'
        rho = 11.3463;
        c0 = 2.16895;
        s = 1.41186;
        g0 = 2.5;   
        
        
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
   
    case 'Rhenium'
        rho = 21.02;
        c0 = 4.184;
        s = 1.367;
        g0 = 2.44;    
  
    case 'Zirconium'
        rho = 6.506;
        c0 = 3.89;
        s = 0.292;
        g0 = 0.93;  
        
    case 'Zirconium1'
        rho = 6.506;
        c0 = 3.757;
        s = 1.018;
        g0 = 1.09; 
        
    case 'Zirconium2'
        rho = 6.506;
        c0 = 3.296;
        s = 1.271;
        g0 = 1.09;   
        
    case 'Epoxy'
        rho = 1.107;
        c0 = 2.8;
        s = 1.7;
        g0 = 1.13;       
        
        
        
        
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



