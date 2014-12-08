%% Impact is an impedance matching GUI
%
%% created July 15, 2014 by Justin Brown (Sandia National Laboraties)

%%
function Impact()
close all; clear all; clc;

% Initialize Variables
sig = SMASH.SignalAnalysis.Signal(0,0); 
sig_tot = 0;
sig_num = [];

%MGmats=[];MGd=0;MGc=0;MGs=0;MGg=0;


% Set system defaults
set(0,'DefaultAxesFontSize',14);
set(0,'DefaultUIControlFontSize',14);


% create figure if not already running
check=findobj('Name','Impact');
if ishandle(check) % program is already running
    disp('GUI already running!');
    figure(check);
    return;
end

fig = SMASH.MUI.Figure; fig.Hidden = true;
fig.Name = 'Impact';
set(fig.Handle,'Tag','Impact');
set(fig.Handle,'Units','normalized');
set(fig.Handle,'Position',[0.05 0.05 .75 .8]);
set(fig.Handle,'Toolbar','figure');
ha=axes('Parent',fig.Handle,'Units','normalized','OuterPosition',[0 0 1 1]);
xlabel('Particle Velocity (km/s)');
ylabel('Pressure (GPa)');


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
    sig = SMASH.SignalAnalysis.Signal(0,0);
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
hm=uimenu(fig.Handle,'Label','Add Curve');
uimenu(hm,'Label','Mie_Gruneisen','Callback',@MG);
uimenu(hm,'Label','Sesame','Callback',@Sesame);
uimenu(hm,'Label','Rayleigh Line','Callback',@Rayleigh);
uimenu(hm,'Label','Load File','Callback',@LoadSignal);
uimenu(hm,'Label','Labels','Callback',@Label);
uimenu(hm,'Label','Comment','Callback',@Comment);
uimenu(hm,'Label','Save','Callback',@SaveSignal);
%uimenu(hm,'Label','Close');

%% create Analysis menu
hm=uimenu(fig.Handle,'Label','Analysis');
uimenu(hm,'Label','Calculate Intersections','Callback',@FindIntersections);


%% create Plotting menu
hm=uimenu(fig.Handle,'Label','Plotting');
uimenu(hm,'Label','Update Line Properties','Callback',@UpdateLineProp);
uimenu(hm,'Label','Edit Signal Order','Callback',@EditOrder);
uimenu(hm,'Label','Edit axis labels','Callback',@EditAxisLabel);
uimenu(hm,'Label','Large AIP Figure','Callback',@BigPlot);
uimenu(hm,'Label','Single column AIP Figure','Callback',@AIPFigure1);
uimenu(hm,'Label','Double column AIP Figure','Callback',@AIPFigure2);
uimenu(hm,'Label','Axes Inset','Callback',@AIPAxesInset);
uimenu(hm,'Label','Axis Limits','Callback',@SetAxis);

fig.Hidden = false;


%Load Hugoniot data from EOS-Data.txt
filename=mfilename('fullpath');
[filename,~]=fileparts(filename);
fid=fopen(fullfile(filename,'EOS-Data.txt'));
count=0; MGdata=1;
while MGdata > 0
    count=count+1;
    MGdata=fgets(fid);
    MGarray{count}=MGdata;
end

for i=1:(length(MGarray)-1)
    [MGmats(i),MGd(i),MGc(i),MGs(i),MGg(i)]=strread(MGarray{i},'%s %f %f %f %f','delimiter',',');
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

slist = {sig.Name};
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
       if (numel({sig.Name}) > numel(get(dlg_hc(1),'String')))
        delete(dlg); ActiveSignal(src,'ActiveDialog');
       end
             
    end
    
    set(h(2),'Callback',@DeleteCallback);
    function DeleteCallback(varargin)
        sig_del=get(dlg_hc(1),'Value');
        delete(dlg);
        
        %Renumber signals
        new_num = 1; new_sig=SMASH.SignalAnalysis.Signal(0,0);
        check = ~ismember([1:sig_tot],sig_del);
        for i=1:sig_tot;
            if check(i)
                new_sig(new_num)=sig(i); 
                new_num=new_num+1;
            end
        end
        
        %Clear old signals then update
        clear sig; sig = new_sig; clear new_sig;
        sig_tot = numel(sig);
        sig_num = [1:sig_tot];
     
        
        %If all signals were deleted, reset
        if new_num == 1
            sig = SMASH.SignalAnalysis.Signal(0,0);
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



%%%%%%%%%%% Signal Callbacks %%%%%%%%%%%%%

%Generate curve based on shock data: c0, s
function MG(src,varargin)
    
% see if dialog already exists
dlg=FindOrCreateDlg(src,'MieGruneisen');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Mie-Gruneisen Curve Addition';
h=addblock(dlg,'popup','Select Material',MGmats);
h=addblock(dlg,'edit_check',{'Initial Velocity (km/s)','Reverse (Impactor)'}); set(h(2),'String', 0);
h=addblock(dlg,'edit','Initial Pressure (GPa)'); set(h(2),'String', 0);
h=addblock(dlg,'edit','Max Pressure (GPa)'); set(h(2),'String', 100);
rh=addblock(dlg,'radio','display shocked state based on pressure');
h=addblock(dlg,'button',{ 'Apply', 'Cancel'});


dlg.Hidden = false;

%Define button callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       
        value = probe(dlg);
        up0 = str2double(value{2});
        P0 = str2double(value{4});
        Pmax = str2double(value{5});

        n = find(strcmpi(value{1},MGmats),1,'First');

        %Find maximum particle velocity
        upmax = fzero(@(u) MGd(n).*u.*(MGc(n)+MGs(n).*u)-Pmax,1);
        up = linspace(0,upmax,1e3)';
        P = MGd(n).*up.*(MGc(n)+MGs(n).*up);

        if P0 > 0
            if ~value{3}
                up0 = fzero(@(u) P0-MGd(n).*(up0-u).*(MGc(n)+MGs(n).*(up0-u)),up0);
            else
                up0 = fzero(@(u) P0-MGd(n).*(u-up0).*(MGc(n)+MGs(n).*(u-up0)),up0);
            end                
        end

        addstr =[];
        if ~value{3}
            if up0 ~= 0
                up = up + up0;
                addstr=sprintf(' %+2.1f km/s',up0);
            end
        else
           up = up0 - up;
           addstr=sprintf(' %2.1f km/s impactor',up0);
        end
       
       
       sig_tot = sig_tot+1;
       sig_num = [1:sig_tot];

       %Set some properties
       sig(sig_tot)=SMASH.SignalAnalysis.Signal(up,P);
       sig(sig_tot).PlotOptions = set(sig(sig_tot).PlotOptions,'LineWidth',3,'LineColor', DistinguishedLines(sig_tot));
       sig(sig_tot).Name = [MGmats{n},addstr];
       sig(sig_tot).Title = 'MieGruneisen';
       sig(sig_tot).GridLabel = 'Particle Velocity (km/s)';
       sig(sig_tot).DataLabel = 'Pressure (GPa)';

       plotdata(fig.Handle,sig,sig_num);
    end
    
    set(h(2),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
    
    set(rh(1),'Callback',@HugoniotCallback);
    function HugoniotCallback(varargin)
        value = probe(dlg);
        pressed = get(rh,'Value');

        if ~pressed
           set(rh,'String','display shocked state based on pressure');
        else
            %Find principal Hugoniot state associated with P0
            n = find(strcmpi(value{1},MGmats),1,'First');
            Ph = str2double(value{4});
            uph = fzero(@(u) MGd(n).*u.*(MGc(n)+MGs(n).*u)-Ph,1);
            Ush = MGc(n)+MGs(n)*uph;
            eh=uph/Ush;
            dh=MGd(n)/(1-eh);
            str = sprintf('Shock Velocity: %f , Shock Density: %f',Ush,dh);
            set(rh,'String',str)
        end
    end

   
end


%Generate curve based on sesame table
function Sesame(src,varargin)
    
% see if dialog already exists
dlg=FindOrCreateDlg(src,'Sesame');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Sesame Curve Addition';

%Find sesame files
%eospath=mfilename('fullpath');
%[eospath,~,~] = fileparts(fullfile(filename,'TabularEOS','temp.m'));
eospath = '/remote/jlbrown/EOS/sesame';

contents = dir(eospath);
eosfiles=[];
for i = 3:length(contents);
    temp = contents(i).name;
    eosfiles{i-2}=temp;
end
        
h=addblock(dlg,'popup','Select Sesame Table',eosfiles);
h=addblock(dlg,'edit_check',{'Impact Velocity (km/s)','Reverse (Impactor)'}); set(h(2),'String', 0);
h=addblock(dlg,'edit','Initial Principal Pressure (GPa)'); set(h(2),'String', 0);
h=addblock(dlg,'edit','Ending Pressure (GPa)'); set(h(2),'String', 100);
h=addblock(dlg,'button',{ 'Apply', 'Cancel'});

dlg.Hidden = false;

%Define button callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
        
        value = probe(dlg);
        neos = value{1};
        ses = SMASH.DynamicMaterials.EOS.Sesame(str2num(neos),fullfile(eospath,neos));
        
        IV = str2num(value{2});
        P0 = str2num(value{4});
        Pend = str2num(value{5});
        
        %Starting density and temperature
        stap = stp(ses);
        %stap = stp(ses,1);
        rho0 = stap.Density;
        
        %If not principal, assume on initial Hugoniot
        if P0>0
            dens = linspace(rho0,rho0*2,100)';
            hug = hugoniot(ses,dens,0,rho0,0);
            
            while max(hug.Pressure) < P0
                dens = dens.*2-rho0;
                hug = hugoniot(ses,dens,0,rho0,0);
            end
                     
            uh = hug.Data{1};
            rhoh = hug.Density;
            Ph=hug.Pressure;
            rho0 = interp1(Ph,rhoh,P0,'pchip');
            up0 = interp1(Ph,uh,P0,'pchip');
            %T0 = interp1(Ph,hug.Temperature,P0,'pchip');
            %lookup(ses,'Pressure',rho0,T0)
            
        else
            up0=IV;
        end           
        
        
        Poff = 1e-3; %Offset to help numerics
        %Isentrope
        if Pend < P0
            dens = sort(linspace(stap.Density/1.5,rho0,100)','descend');
            path = isentrope(ses,dens,P0,rho0,up0);            
        %Hugoniot
        else
            dens = linspace(rho0,rho0*2,100)';
            path = hugoniot(ses,dens,P0+Poff,rho0,up0);
            while max(path.Pressure) < Pend
                dens = dens.*2-rho0;
                path = hugoniot(ses,dens,P0+Poff,rho0,up0);
            end
        end
        
        P=path.Pressure;
        up= path.Data{1}; 
        
        limit = P <= max(P0,Pend)*1.01 & P >= (min(P0,Pend)-1e-9)*.99 & ~isnan(up) & ~isnan(P);
        P=P(limit);
        up = up(limit);
        
        addstr=[];
        if value{3}
           up = 2*up(1)-up;
           addstr=' impactor';
        end
        
        
       sig_tot = sig_tot+1;
       sig_num = [1:sig_tot];

       [~,ia]=unique(up);    
       %Set some properties
       sig(sig_tot)=SMASH.SignalAnalysis.Signal(up(ia),P(ia));
       sig(sig_tot).PlotOptions = set(sig(sig_tot).PlotOptions,'LineWidth',3,'LineColor', DistinguishedLines(sig_tot));
       sig(sig_tot).Name = [neos,addstr];
       sig(sig_tot).Title = 'Sesame';
       sig(sig_tot).GridLabel = 'Particle Velocity (km/s)';
       sig(sig_tot).DataLabel = 'Pressure (GPa)';

       plotdata(fig.Handle,sig,sig_num);
    end
    
    set(h(2),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
 

end


%Generate Rayleigh line
function Rayleigh(src,varargin)
    
% see if dialog already exists
dlg=FindOrCreateDlg(src,'Rayleigh');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Rayleigh Line Addition';
h=addblock(dlg,'edit','Initial Density (g/cc)'); set(h(2),'String', 0);
h=addblock(dlg,'edit','Shock Velocity (km/s)'); set(h(2),'String', 0);
h=addblock(dlg,'edit','Max Pressure (GPa)'); set(h(2),'String', 100);
h=addblock(dlg,'button',{ 'Apply', 'Cancel'});

dlg.Hidden = false;

%Define button callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       
        value = probe(dlg);
        rho0 = str2double(value{1});    
        Us = str2double(value{2});
        maxP = str2double(value{3});

        maxup = maxP./(rho0.*Us); 
        up = linspace(0,maxup,1e3)';
        P = rho0.*Us.*up;
          
       sig_tot = sig_tot+1;
       sig_num = [1:sig_tot];

       %Set some properties
       sig(sig_tot)=SMASH.SignalAnalysis.Signal(up,P);
       sig(sig_tot).PlotOptions = set(sig(sig_tot).PlotOptions,'LineWidth',3,'LineColor', DistinguishedLines(sig_tot));
       sig(sig_tot).Name = 'Rayliegh Line';
       sig(sig_tot).Title = 'Rayleigh';
       sig(sig_tot).GridLabel = 'Particle Velocity (km/s)';
       sig(sig_tot).DataLabel = 'Pressure (GPa)';

       plotdata(fig.Handle,sig,sig_num);
    end
    
    set(h(2),'Callback',@CancelCallback);
    function CancelCallback(varargin)
        delete(dlg);      
    end
 

end


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
        [content,summary] = probe(SDAobj)
        
        %Load in by date added
        for ii = 1:length(content)
            d(ii) = datenum(content(ii,1).Added,'dd-mmm-yyyy HH:MM:SS');
            [sortd id] = sort(d,'ascend');
        end
        
        for ii = 1:length(id);
            if strcmp(content(id(ii),1).Category,'SMASH.SignalAnalysis.Signal')
                %Advance to next record
                update(wb,(ii*i)/(numfiles*length(id)));
                sig_tot = sig_tot+1;
                sig(sig_tot) = SMASH.SignalAnalysis.Signal('restore',fullfile(pathname,filename{i}),content(id(ii),1).Label);
                
            elseif strcmp(content(id(ii),1).Category,'array1D')
                %Advance to next record
                sig_tot = sig_tot+1;
                sig(sig_tot) = SMASH.SignalAnalysis.Signal('import',fullfile(pathname,filename{i}),'sda',content(id(ii),1).Label);
                %Set some object properties
                sig(sig_tot).PlotOptions = set(sig(sig_tot).PlotOptions,'LineWidth',3,'LineColor', DistinguishedLines(sig_tot));
                sig(sig_tot).GridLabel= 'Particle Velocity (km/s)'; 
                sig(sig_tot).DataLabel= 'Pressure (GPa)';
                sig(sig_tot).Name = content(id(ii),1).Label;
                sig(sig_tot).Title = 'Loaded';
            end
        end
        
    %Load ascii file    
    else
        %Advance to next signal
        sig_tot = sig_tot+1;
        sig(sig_tot) = SMASH.SignalAnalysis.Signal('import',fullfile(pathname,filename{i}),'column');
        %Probe file to find number of columns
        source=SMASH.FileAccess.ColumnFile(fullfile(pathname,filename{i}));
        p=probe(source); ncol = p.NumberColumns;

        [~,name,ext]=fileparts(filename{i}); 
        if length(ext) > 4; name = [name ext]; end
        sig(sig_tot).Name = name;

        %Set some object properties
        sig(sig_tot).PlotOptions = set(sig(sig_tot).PlotOptions,'LineWidth',3,'LineColor', DistinguishedLines(sig_tot));
        %sig(sig_tot).GridLabel= 'x'; sig(sig_tot).DataLabel= 'y';

        %Loop through column numbers 2 and higher and load if there is data
        if ncol > 2; data = read(source); end; 
        for cn=3:ncol
            if ~(all(data.Data(:,cn)==0)) %Make sure there is data in column
            %Increment total number signals, load and save to object
            sig_tot = sig_tot + 1;
            sig(sig_tot) = SMASH.SignalAnalysis.Signal('import',fullfile(pathname,filename{i}),'column',[1 cn]);  
            str=sprintf('%s col%i',name,cn);
            sig(sig_tot).Name = str;

            %Set some object properties
            sig(sig_tot).PlotOptions = set(sig(sig_tot).PlotOptions,'LineWidth',3,'LineColor', DistinguishedLines(sig_tot));
            sig(sig_tot).GridLabel= 'Particle Velocity (km/s)'; 
            sig(sig_tot).DataLabel= 'Pressure (GPa)';
            sig(sig_tot).Title = 'Loaded';
            end
        end
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

%% Label signal callback
function Label(src,varagin)

% see if dialog already exists
dlg=FindOrCreateDlg(src,'LabelDialog');
if ishandle(dlg)
    return
end

dlg.Hidden = true;
dlg.Name = 'Label Signal';
locate(dlg,'south');

%Create edit box for each signal
for i=1:numel(sig_num)
    h=addblock(dlg,'edit',sig(sig_num(i)).Name); set(h(2),'String', sig(sig_num(i)).Name);
end
h=addblock(dlg,'button',{ 'Apply Label Change', 'Cancel'});
dlg.Hidden = false

%Define button callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       newnames = probe(dlg);
       for i=1:numel(sig_num)
        if ~isempty(newnames{i})
            sig(sig_num(i)).Name = newnames{i};
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
        sig(sig_num(i))=comment(sig(sig_num(i)));
    end

end %Comment

%% Save signal callback
function SaveSignal(src,varargin)     


   %Set save to all active signals
   savenum = sig_num;
   for i = 1:numel(savenum)
       [savename, savepath] = uiputfile({'*.dat;*.txt;*.out','All ASCII Files'; '*.sda','SandiaDataArchive'; ...
           '*.*','All Files'}, sprintf('Save Signal #%i',savenum(i)),sig(savenum(i)).Name);

       %savename = inputdlg(sig(savenum(i)).Name,'Select file to write',1,{horzcat(sig(savenum(i)).Name,'.dat')});
       %savename = savename{1}; savepath = pathname;
       
       %Export all objects to Sandia Data Archive if .sda extension, otherwise ASCII
       [~,~,ext]=fileparts(savename);
       if strcmp(ext,'.sda')
           for i = 1:numel(savenum)
            %labelname = inputdlg('Enter label name for sda file','SDA Label',1,{sig(savenum(i)).Name}); labelname = labelname{1};
            labelname = sig(savenum(i)).Name;
            %export(sig(savenum(i)),fullfile(savepath,savename),labelname);
            store(sig(savenum(i)),fullfile(savepath,savename),labelname);
           end
           return; %Only ask for sda name once
       else
        export(sig(savenum(i)),fullfile(savepath,savename));
       end  
   end



end %Save


%%%%%%%%%%% Analysis Callbacks %%%%%%%%%%%%%


function FindIntersections(src,varargin)
plotdata(fig.Handle,sig,sig_num);
for i=1:numel(sig_num)-1
   for j = i+1:numel(sig_num)
    [x,y] = intersections(sig(sig_num(i)).Grid,sig(sig_num(i)).Data,sig(sig_num(j)).Grid,sig(sig_num(j)).Data);
    if y>0
    lc = get(sig(sig_num(i)).PlotOptions,'LineColor');
    text(x,y,['\leftarrow ',sprintf('(%3.3f,%3.3f)',x,y)],'FontSize',14,'Color',lc);
    end

   end

end


end










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

    %Update as long as signal numbering is OK
    if (numel(color) == numel(sig_num))
        for i = 1:numel(sig_num);
            index = numel(color)+1-i;
            sig(sig_num(i)).PlotOptions = set(sig(sig_num(i)).PlotOptions,'LineWidth',width{index,1}, ...
                'LineColor', color{index,1},'LineStyle',style{index,1},'Marker',mark{index,1});
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
    h=addblock(dlg,'edit',sig(sig_num(i)).Name); set(h(2),'String', num2str(i));
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
       
       newsig = SMASH.SignalAnalysis.Signal(0,0);
       for i = 2:numel(sig_num);
           newsig(i) = SMASH.SignalAnalysis.Signal(0,0);
       end
       
       for i=1:numel(sig_num)
           newindex(i)
          sig_num(i)
            newsig(newindex(i)) = sig(sig_num(i));
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
h=addblock(dlg,'edit','Grid Axis Label'); set(h(2),'String', sig(sig_num(1)).GridLabel);
h=addblock(dlg,'edit','Data Axis Label'); set(h(2),'String', sig(sig_num(1)).DataLabel);

h=addblock(dlg,'button',{ 'Apply Label Change', 'Cancel'});

dlg.Hidden = false;

%Define button callbacks
    set(h(1),'Callback',@ApplyCallback);
    function ApplyCallback(varargin)
       newnames = probe(dlg);
       for i=1:numel(sig_num)
            sig(i).GridLabel = newnames{1};
            sig(i).DataLabel = newnames{2};
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
        xmin = [xmin;min(sig(sig_num(i)).Grid)];
        xmax = [xmax;max(sig(sig_num(i)).Grid)];
    end
    
    x=linspace(max(xmin),min(xmax),2e3)';
    
    %Find common y
    for i=1:length(sig_num)
        y{i} = lookup(sig(sig_num(i)),x);
    end
    newsig = sig;
    %Calculate % difference from 1st signal
    for i=1:length(sig_num)
        %PercentDiff(i) = abs(2.*(y{1}-y{i})./(y{1}+y{i}))*100;
        PercentDiff = (1-y{1}./y{i})*100;
        newsig(sig_num(i)) = SMASH.SignalAnalysis.Signal(x,PercentDiff);
        %Set some object properties
        sig(sig_num(i)).PlotOptions = set(sig(sig_num(i)).PlotOptions,'LineWidth',3,'LineColor', DistinguishedLines(sig_tot));
        newsig(sig_num(i)).GridLabel= 'x'; newsig(i).DataLabel= '% from 1st signal';
        legendentry{i}=strrep(sig(sig_num(i)).Name,'_','\_');
    end
    
    %Create plot
    fig2=figure('units','normalized','Position',[.10,.10,0.7,0.7]); 
    movegui(fig2,'center');
    for i=1:length(sig_num)
    h1 = subplot(2,1,1); view(sig(sig_num(i)),fig2); title('Signals'); axis tight; 
    h2 = subplot(2,1,2); view(newsig(sig_num(i)),fig2); title('Percent Difference');
    end
                        
    legend(legendentry,'Color','none'); legend('boxoff');
    axis([x(1) x(end) -100 100]); 
    hold off;
    set(gcf,'Color','w');
    linkaxes([h1 h2],'x');
end %Percent difference

%% Large plot 
function BigPlot(src,varargin)
    AIPFig = SMASH.Graphics.AIPfigure(4,'11in');
    set(AIPFig,'name','AIP Large Fig');
    plotdata(AIPFig,sig,sig_num)

    set(gca,'FontName','times','FontAngle','normal','LineWidth',2.5,'FontSize',30);
    set(gcf,'Color','w');
    xlabel(sig(sig_num(1)).GridLabel,'FontName','times','FontAngle','normal','FontSize',40);
    ylabel(sig(sig_num(1)).DataLabel,'FontName','times','FontAngle','normal','FontSize',40);
    
end %Big plot

%% Single column AIP
function AIPFigure1(src,varargin)
    AIPFig = SMASH.Graphics.AIPfigure(1);
    set(AIPFig,'name','AIP Single Column Fig');
    
    for i=1:length(sig_num); sig(sig_num(i)).PlotOptions = set(sig(sig_num(i)).PlotOptions,'LineWidth',1); end;
    plotdata(AIPFig,sig,sig_num)
    for i=1:length(sig_num); sig(sig_num(i)).PlotOptions = set(sig(sig_num(i)).PlotOptions,'LineWidth',3); end;
    
    set(gca,'FontName','times','FontAngle','normal','FontSize',10);
    set(gcf,'Color','w');
    xlabel(sig(sig_num(1)).GridLabel,'FontName','times','FontAngle','normal','FontSize',12);
    ylabel(sig(sig_num(1)).DataLabel,'FontName','times','FontAngle','normal','FontSize',12);

end %AIP single column

%% Double column AIP
function AIPFigure2(src,varargin)
    AIPFig = SMASH.Graphics.AIPfigure(2);
    set(AIPFig,'name','AIP Double Column Fig');
    
    for i=1:length(sig_num); sig(sig_num(i)).PlotOptions = set(sig(sig_num(i)).PlotOptions,'LineWidth',1); end;
    plotdata(AIPFig,sig,sig_num)
    for i=1:length(sig_num); sig(sig_num(i)).PlotOptions = set(sig(sig_num(i)).PlotOptions,'LineWidth',3); end;
    
    set(gca,'FontName','times','FontAngle','normal','FontSize',10);
    %box off; 
    set(gcf,'Color','w');
    xlabel(sig(sig_num(1)).GridLabel,'FontName','times','FontAngle','normal','FontSize',12);
    ylabel(sig(sig_num(1)).DataLabel,'FontName','times','FontAngle','normal','FontSize',12);
end %AIP double column


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
    newsig = sig(n);
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
    newsig(sig_num(i)) = func(sig_num(i)); 
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
            sig(sig_num(i)) = func(sig_num(i)); 
        else
            %Don't redo the apply calculation if it's been done
            if numel(newsig(sig_num(i)).Grid) > 1
                sig(sig_num(i))=reset(sig(sig_num(i)),newsig(sig_num(i)));
            else
                sig(sig_num(i))=reset(sig(sig_num(i)),func(sig_num(i)));
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
    h=addblock(dlg,'edit','xmin        '); set(h(2),'String',min(sig(sig_num(1)).Grid));
    h=addblock(dlg,'edit','xmax        '); set(h(2),'String',max(sig(sig_num(1)).Grid));
    h=addblock(dlg,'edit','ymin        '); set(h(2),'String',min(sig(sig_num(1)).Data));
    h=addblock(dlg,'edit','ymax        '); set(h(2),'String',max(sig(sig_num(1)).Data));
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




end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End Impact



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
                    %sig(sig_num(i)).LineWidth = 1;
                    view(sig(sig_num(i)),ha);
                    legendentry{i}=strrep(sig(sig_num(i)).Name,'_','\_');
                end
                lh = legend(legendentry,'Color','none','Location','Best','EdgeColor','w','LineWidth',0);
                %set(lh,'Box','off');
                xlabel(sig(sig_num(1)).GridLabel);
                ylabel(sig(sig_num(1)).DataLabel);
            end
           
            
        case 'overlay'    
            %Current signals in black
            for i=1:length(sig_num)
            [tempsigx tempsigy] = limit(sig(sig_num(i)));
            line(tempsigx, tempsigy,'Color',[0 0 0],'LineStyle','--','LineWidth',2);
            end  
            
      
        case 'overlay_all'
            
            %All signals in grey
            for i=1:numel(sig)
            [tempsigx tempsigy] = limit(sig(i));
            line(tempsigx, tempsigy,'Color',[0.75 0.75 0.75],'LineStyle','-.','LineWidth',2);
            end  

            
    end
end

%% Line colors initilization (modified from PointVISAR)
function color=DistinguishedLines(number)

map=[];
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



%Curve intersection
function [x0,y0,iout,jout] = intersections(x1,y1,x2,y2)

    % Input checks.
    error(nargchk(2,4,nargin))

    % Adjustments when fewer than five arguments are supplied.
    switch nargin
        case 2
            x2 = x1;
            y2 = y1;
            self_intersect = true;
        case 3
            x2 = x1;
            y2 = y1;
            self_intersect = true;
        case 4
            self_intersect = false;

    end

    % x1 and y1 must be vectors with same number of points (at least 2).
    if sum(size(x1) > 1) ~= 1 || sum(size(y1) > 1) ~= 1 || ...
            length(x1) ~= length(y1)
        error('X1 and Y1 must be equal-length vectors of at least 2 points.')
    end
    % x2 and y2 must be vectors with same number of points (at least 2).
    if sum(size(x2) > 1) ~= 1 || sum(size(y2) > 1) ~= 1 || ...
            length(x2) ~= length(y2)
        error('X2 and Y2 must be equal-length vectors of at least 2 points.')
    end

    % Force all inputs to be column vectors.
    x1 = x1(:);
    y1 = y1(:);
    x2 = x2(:);
    y2 = y2(:);

    % Compute number of line segments in each curve and some differences we'll
    % need later.
    n1 = length(x1) - 1;
    n2 = length(x2) - 1;
    xy1 = [x1 y1];
    xy2 = [x2 y2];
    dxy1 = diff(xy1);
    dxy2 = diff(xy2);

    % Determine the combinations of i and j where the rectangle enclosing the
    % i'th line segment of curve 1 overlaps with the rectangle enclosing the
    % j'th line segment of curve 2.
    [i,j] = find(repmat(min(x1(1:end-1),x1(2:end)),1,n2) <= ...
        repmat(max(x2(1:end-1),x2(2:end)).',n1,1) & ...
        repmat(max(x1(1:end-1),x1(2:end)),1,n2) >= ...
        repmat(min(x2(1:end-1),x2(2:end)).',n1,1) & ...
        repmat(min(y1(1:end-1),y1(2:end)),1,n2) <= ...
        repmat(max(y2(1:end-1),y2(2:end)).',n1,1) & ...
        repmat(max(y1(1:end-1),y1(2:end)),1,n2) >= ...
        repmat(min(y2(1:end-1),y2(2:end)).',n1,1));

    % Force i and j to be column vectors, even when their length is zero, i.e.,
    % we want them to be 0-by-1 instead of 0-by-0.
    i = reshape(i,[],1);
    j = reshape(j,[],1);

    % Find segments pairs which have at least one vertex = NaN and remove them.
    % This line is a fast way of finding such segment pairs.  We take
    % advantage of the fact that NaNs propagate through calculations, in
    % particular subtraction (in the calculation of dxy1 and dxy2, which we
    % need anyway) and addition.
    % At the same time we can remove redundant combinations of i and j in the
    % case of finding intersections of a line with itself.
    if self_intersect
        remove = isnan(sum(dxy1(i,:) + dxy2(j,:),2)) | j <= i + 1;
    else
        remove = isnan(sum(dxy1(i,:) + dxy2(j,:),2));
    end
    i(remove) = [];
    j(remove) = [];

    % Initialize matrices.  We'll put the T's and B's in matrices and use them
    % one column at a time.  AA is a 3-D extension of A where we'll use one
    % plane at a time.
    n = length(i);
    T = zeros(4,n);
    AA = zeros(4,4,n);
    AA([1 2],3,:) = -1;
    AA([3 4],4,:) = -1;
    AA([1 3],1,:) = dxy1(i,:).';
    AA([2 4],2,:) = dxy2(j,:).';
    B = -[x1(i) x2(j) y1(i) y2(j)].';

    % Loop through possibilities.  Trap singularity warning and then use
    % lastwarn to see if that plane of AA is near singular.  Process any such
    % segment pairs to determine if they are colinear (overlap) or merely
    % parallel.  That test consists of checking to see if one of the endpoints
    % of the curve 2 segment lies on the curve 1 segment.  This is done by
    % checking the cross product
    %
    %   (x1(2),y1(2)) - (x1(1),y1(1)) x (x2(2),y2(2)) - (x1(1),y1(1)).
    %
    % If this is close to zero then the segments overlap.

    for k = 1:n
        [L,U] = lu(AA(:,:,k));
        T(:,k) = U\(L\B(:,k));
    end

    % Find where t1 and t2 are between 0 and 1 and return the corresponding
    % x0 and y0 values.
    in_range = (T(1,:) >= 0 & T(2,:) >= 0 & T(1,:) < 1 & T(2,:) < 1).';
    x0 = T(3,in_range).';
    y0 = T(4,in_range).';

    % Compute how far along each line segment the intersections are.
    if nargout > 2
        iout = i(in_range) + T(1,in_range).';
        jout = j(in_range) + T(2,in_range).';
    end
end


