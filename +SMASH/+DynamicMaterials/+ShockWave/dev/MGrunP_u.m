function MGrunP_u

%clear all; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%5%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Impact Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initialize parameters
pressureplot=1;
filecount=1; MatA=[]; PuA=[]; LegendEntry=[]; LegendEntryT=[]; LegendEntryI=[];
upmin=0; upmax=1; targetcounter=0; impvel=0; Psolve=0; upsolve=0;
MatNumTarg=1; MatNumImp=1; impveltemp=0; unloadshift=0;

%Going to read from EOS-Data.txt write data sets to P_u.txt
filename=mfilename('fullpath');
[filename,~]=fileparts(filename);
fid=fopen(fullfile(filename,'EOS-Data.txt'));
fid2=fopen(fullfile(filename,'P_u.txt'));

%MieGrunfile='EOS-Data.txt';
%fid=fopen(MieGrunfile,'r');
%fid2=fopen('P_u.txt','w');


%Get info from EOS file, each cell is a new line. Note - no comments in
%input file (must be modified slightly from Impact version).
count=0; MieGrundata=1;
while MieGrundata > 0
    count=count+1;
    MieGrundata=fgets(fid);
    MieGrunArray{count}=MieGrundata;
end

MieGrunLength=length(MieGrunArray)-1;

%Store data from cells in arrays for each material property - name,
%dens, C, S, Gamma
for i=1:MieGrunLength;
    [Materials(i),Density(i),C(i),S(i),Gamma(i)]=strread(MieGrunArray{i},'%s %f %f %f %f','delimiter',',');
end


%    Impedance=Density.*C;
%    fprintf('Material \t\t\t\t\t\t\t Acoustic Impedance \n');
%    for i=1:MieGrunLength
%        fprintf('%s \t\t\t\t\t\t\t %6.2f \n',Materials{i},Impedance(i));
%    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%GUI Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Initialize and hide the GUI as it is being constructed

%Figure size, invisible until all menus are set
f=figure('Visible','off','Position',[250,10,800,640],'ToolBar','figure','NumberTitle','off', ...
    'Name','Mie-Gruneisen Pressure - Particle Velocity Solver');

%axis setup
puaxes=axes('Units','pixels','FontWeight','b','FontSize',12,'Position',[75,85,500,500]);

%Target materials
targettext = uicontrol('Style','text','String','Target','Position',[600,575,80,25], ...
    'FontWeight','b','FontSize',14,'BackgroundColor',[0.8 0.8 0.8]);
targetpopup = uicontrol('Style','popupmenu','String',Materials,'Position',[600,545,160,25], ...
    'Callback',{@targetpopup_Callback},'FontWeight','b','FontSize',13,'BackgroundColor','b',...
    'ForegroundColor','c');

%Impactor materials
imptext=uicontrol('Style', 'text','String','Impactor','Position',[600,480,110,25], ...
    'FontWeight','b','FontSize',14,'BackgroundColor',[0.8 0.8 0.8]);
impactorpopup = uicontrol('Style','popupmenu','String',Materials,'Position',[670,450,100,25], ...
    'Callback',{@impactorpopup_Callback},'FontWeight','b','FontSize',13,'BackgroundColor','b','ForegroundColor','c');
impveledit = uicontrol('Style','edit','Position',[600,450,60,20],'Callback', ...
    {@impveledit_Callback},'BackgroundColor','r','FontSize',12,'FontWeight','b');
impveltext=uicontrol('Style', 'text','String','(km/s)','Position',[600,430,50,20], ...
    'FontWeight','b','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

%Interesection text
presstext=uicontrol('Style', 'text','String','P (GPa):','Position',[591,295,100,20], ...
    'FontWeight','n','FontSize',13,'BackgroundColor',[0.8 0.8 0.8]);
partveltext=uicontrol('Style', 'text','String','up (km/s):','Position',[580,270,100,20], ...
    'FontWeight','n','FontSize',13,'BackgroundColor',[0.8 0.8 0.8]);


%up axis scale
uptext=uicontrol('Style', 'text','String','Max','Position',[450,5,60,20], ...
    'FontWeight','b','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);
upedit = uicontrol('Style','edit','Position',[450,25,60,20],'Callback',{@upedit_Callback}, ...
    'BackgroundColor',[.4,.4,.4],'FontSize',12,'FontWeight','b');
%upmaxtext=uicontrol('Style', 'text','String','(km/s)','Position',[570,20,50,20], ...
%    'FontWeight','b','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);

%Rayleigh Line Inputs
rayleightext=uicontrol('Style', 'text','String','Rayleigh Line Input','Position',[600,120,180,20], ...
    'FontWeight','b','FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);
rayldenstext=uicontrol('Style', 'text','String','Density (g/cc):','Position',[600,95,130,20], ...
    'FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);
rayldens = uicontrol('Style','edit','Position',[725,95,50,20],'Callback',{@rayldens_Callback}, ...
    'BackgroundColor','c','FontSize',12,'FontWeight','b');
raylustext=uicontrol('Style', 'text','String','Us (km/s):','Position',[615,70,130,20], ...
    'FontSize',12,'BackgroundColor',[0.8 0.8 0.8]);
raylus = uicontrol('Style','edit','Position',[725,70,50,20],'Callback',{@raylus_Callback}, ...
    'BackgroundColor','c','FontSize',12,'FontWeight','b');


%File ShockVel plot, write, clear, calculate intersection, and reflection push buttons
shockvelbutton = uicontrol('Style','pushbutton','Position',[450,600,100,25],'String','ShockVel' , ...
    'FontWeight','b','FontSize',12,'Callback',{@shockvelbutton_Callback});

pressurebutton = uicontrol('Style','pushbutton','Position',[150,600,100,25],'String','Pressure' , ...
    'FontWeight','b','FontSize',12,'Callback',{@pressurebutton_Callback});

filebutton = uicontrol('Style','pushbutton','Position',[605,20,85,25],'String','Write File' , ...
    'FontWeight','b','FontSize',12,'Callback',{@filebutton_Callback});

clearbutton = uicontrol('Style','pushbutton','Position',[705,20,65,25],'String','Clear' , ...
    'FontWeight','b','FontSize',12,'Callback',{@clearbutton_Callback});

intersectionbutton = uicontrol('Style','pushbutton','Position',[600,325,180,25],'String',...
    'Calculate Intersection','FontWeight','b','FontSize',12,'Callback',{@intersectionbutton_Callback});

reflectionbutton = uicontrol('Style','pushbutton','Position',[600,225,180,25],'String',...
    'Reflect Current Target','FontWeight','b','FontSize',12,'Callback',{@reflectionbutton_Callback});
unloadbutton = uicontrol('Style','pushbutton','Position',[685,170,110,25],'String',...
    'Unload Shift','FontWeight','b','FontSize',12,'Callback',{@unloadbutton_Callback});
unloadedit = uicontrol('Style','edit','Position',[610,170,70,25],'Callback',{@unloadedit_Callback}, ...
    'BackgroundColor','y','FontSize',12,'FontWeight','b');

%Align menus
align([targettext,targetpopup, imptext...
    rayleightext,intersectionbutton, reflectionbutton],'Center','None');

%Initialize the GUI
set([f,puaxes],'Units','normalized');
%movegui(f,'center');
%set(0,'DefaultAxesLineStyleOrder','-|-.|--|:');

%Plot labels, settings
hold on; hold all;
xlabel({'';'u_p   (km/s)'},'fontsize',17,'fontweight','b','FontAngle','i');
ylabel({'P   (GPa)'},'FontSize',17,'FontWeight','b','FontAngle','i');
set(f,'Visible','on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Subfunctions below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Target popup Callback
    function targetpopup_Callback(source,eventdata)
        %Determine the selected data set
        str = get(source, 'String');
        val = get(source, 'Value');
        
        %Set current data to the selected data set
        uptarget=linspace(upmin,upmax,2000);
        MatNumTarg=val; targetcounter=targetcounter+1;
        MatTemp=horzcat(Materials(MatNumTarg),' Target'); MatTemp=cell2mat(MatTemp); MatTemp={MatTemp};
        
        
        %Plot pressure or Shock velocity - Note program only plots Us_up in
        %the sense of the "target". Anything else would be meaningless
        if pressureplot == 1
            Ptarget=pressurecalc(MatNumTarg,uptarget);
            plot(uptarget,Ptarget,'LineWidth',3); xlim([upmin,upmax]);
            filearray(uptarget,Ptarget,MatTemp);
        else
            UStarget=shockvelcalc(MatNumTarg,uptarget);
            plot(uptarget,UStarget,'LineWidth',3); xlim([upmin,upmax]);
            filearray(uptarget,UStarget,MatTemp);
        end
        
        LegendEntryT = horzcat(LegendEntryT,MatTemp);
        LegendEntry = horzcat(LegendEntry,MatTemp);
        legendhandle=legend(LegendEntry,'Location','Best');
        set(legendhandle,'Box','off');
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Impactor popup Callback
    function impactorpopup_Callback(source,eventdata)
        %Determine the selected data set
        str = get(source, 'String');
        val = get(source, 'Value');
        
        %Set current data to the selected data set
        uptarget=linspace(upmin,upmax,2000);
        uprev=impvel-uptarget; impveltemp=impvel;
        MatNumImp=val; targetcounter=targetcounter+1;
        Prev=pressurecalc(MatNumImp,uptarget);
        plot(uprev,Prev,'LineWidth',3); xlim([upmin,upmax]);
        MatTemp=horzcat(Materials(MatNumImp),' ',mat2str(impvel),' km/s Impactor');
        MatTemp=cell2mat(MatTemp); MatTemp={MatTemp};
        LegendEntryI = horzcat(LegendEntryI,MatTemp);
        LegendEntry = horzcat(LegendEntry,MatTemp);
        legendhandle=legend(LegendEntry,'Location','Best');
        set(legendhandle,'Box','off');
        
        filearray(uprev,Prev,MatTemp);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ShockVel button Callback
    function shockvelbutton_Callback(hObject,eventdata)
        pressureplot=0;
        MatA=[]; PuA=[]; targetcounter=0; LegendEntry=[]; LegendEntryT=[]; LegendEntryI=[]; cla;
        ylabel({'Shock Velocity      (km/s)'},'FontSize',17,'FontWeight','b','FontAngle','i');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ShockVel button Callback
    function pressurebutton_Callback(hObject,eventdata)
        pressureplot=1;
        MatA=[]; PuA=[]; targetcounter=0; LegendEntry=[]; LegendEntryT=[]; LegendEntryI=[]; cla;
        ylabel({'P   (GPa)'},'FontSize',17,'FontWeight','b','FontAngle','i');
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% reflection button Callback
    function reflectionbutton_Callback(hObject,eventdata)
        
        f=@(u) Psolve-Density(MatNumTarg).*(C(MatNumTarg)+S(MatNumTarg).*(u-upsolve)).*(u-upsolve);
        urefl=fzero(f,upsolve);
        
        uptarget=linspace(upmin,upmax+urefl,2000);
        uprefl=urefl-uptarget; impveltemp=urefl;
        targetcounter=targetcounter+1;
        Prefl=pressurecalc(MatNumTarg,uptarget);
        plot(uprefl,Prefl,'LineWidth',3); xlim([upmin,upmax]);
        MatTemp=horzcat(Materials(MatNumTarg), ' Reflection'); MatTemp=cell2mat(MatTemp); MatTemp={MatTemp};
        LegendEntry = horzcat(LegendEntry,MatTemp);
        legendhandle=legend(LegendEntry,'Location','Best');
        set(legendhandle,'Box','off');
        MatNumImp=MatNumTarg;
        filearray(uprefl,Prefl,MatTemp);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Impactor velocity field Callback
    function impveledit_Callback(hObject,eventdata)
        user_entry = str2double(get(hObject,'string'));
        impvel=user_entry;
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% up max field Callback
    function upedit_Callback(hObject,eventdata)
        user_entry = str2double(get(hObject,'string'));
        upmax=user_entry;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% rayleigh density field Callback
    function rayldens_Callback(hObject,eventdata)
        Density(MieGrunLength+1) = str2double(get(hObject,'string'));
        Materials(MieGrunLength+1)={'Rayleigh Line'};
        S(MieGrunLength+1)=0;Gamma(MieGrunLength+1)=0;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% rayleigh Us field Callback
    function raylus_Callback(hObject,eventdata)
        C(MieGrunLength+1) = str2double(get(hObject,'string'));        
        set(targetpopup,'String',Materials);
        set(impactorpopup,'String',Materials);        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Unload shift field Callback
    function unloadedit_Callback(hObject,eventdata)
        unloadshift = str2double(get(hObject,'string'));
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% unload button Callback
    function unloadbutton_Callback(hObject,eventdata)
        
        uptarget=linspace(upmin,upmax,2000);
        uprev=impvel-uptarget; impveltemp=impvel;
        targetcounter=targetcounter+1;
        Punload=pressurecalc(MatNumImp,uptarget)-unloadshift;
        plot(uprev,Punload,'LineWidth',3); xlim([upmin,upmax]);
        MatTemp=horzcat(Materials(MatNumImp), ' Unload'); MatTemp=cell2mat(MatTemp); MatTemp={MatTemp};
        LegendEntry = horzcat(LegendEntry,MatTemp);
        legendhandle=legend(LegendEntry,'Location','Best');
        set(legendhandle,'Box','off');
        filearray(uprev,Punload,MatTemp);
        
        f=@(up) (Density(MatNumTarg).*(C(MatNumTarg)+S(MatNumTarg).*up).*up)- ...
            ((Density(MatNumImp).*(C(MatNumImp)+S(MatNumImp) .*(impvel-up)).*(impvel-up))-unloadshift);
        
        [upsolve]=fzero(f,(upmax-upmin)/2);
        Psolve=(Density(MatNumTarg).*(C(MatNumTarg)+S(MatNumTarg).*upsolve).*upsolve);
        
        presstext2=uicontrol('Style', 'edit','String',Psolve,'Position',[675,295,120,20], ...
            'FontSize',13,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@Psolveedit_Callback});
        
        partveltext2=uicontrol('Style', 'edit','String',upsolve,'Position',[675,270,120,20], ...
            'FontSize',13,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@upsolveedit_Callback});
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% file button Callback
    function filebutton_Callback(hObject,eventdata)
        filewrite;
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% clear button Callback
    function clearbutton_Callback(hObject,eventdata)
        MatA=[]; PuA=[]; targetcounter=0; LegendEntry=[]; LegendEntryT=[]; LegendEntryI=[]; cla;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Intersection button Callback
    function intersectionbutton_Callback(hObject,eventdata)
        
        [upsolve, Psolve]=HugSolve(MatNumTarg, MatNumImp,impveltemp);
        
        presstext2=uicontrol('Style', 'edit','String',Psolve,'Position',[675,295,120,25], ...
            'FontSize',13,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@Psolveedit_Callback});
        
        partveltext2=uicontrol('Style', 'edit','String',upsolve,'Position',[675,270,120,25], ...
            'FontSize',13,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@upsolveedit_Callback});
        
    end

    function Psolveedit_Callback(hObject,eventdata)
        Psolve = str2double(get(hObject,'string'));
        f=@(up) Density(MatNumTarg).*(C(MatNumTarg)+S(MatNumTarg).*up).*up-Psolve;
        upsolve=fzero(f,upsolve);
        
        presstext2=uicontrol('Style', 'edit','String',Psolve,'Position',[675,295,120,20], ...
            'FontSize',13,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@Psolveedit_Callback});
        
        partveltext2=uicontrol('Style', 'edit','String',upsolve,'Position',[675,270,120,20], ...
            'FontSize',13,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@upsolveedit_Callback});
    end

    function upsolveedit_Callback(hObject,eventdata)
        upsolve = str2double(get(hObject,'string'));
        Psolve= (Density(MatNumTarg).*(C(MatNumTarg)+S(MatNumTarg).*upsolve).*upsolve);
        
        presstext2=uicontrol('Style', 'edit','String',Psolve,'Position',[675,295,120,20], ...
            'FontSize',13,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@Psolveedit_Callback});
        
        partveltext2=uicontrol('Style', 'edit','String',upsolve,'Position',[675,270,120,20], ...
            'FontSize',13,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@upsolveedit_Callback});
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Pressure Calculation function - given MatNum, Density, C, S, up(linspace), calculates P(up)
    function Pressure = pressurecalc(MatNum,up)
        Pressure=Density(MatNum).*(C(MatNum)+S(MatNum).*up).*up;
    end

%Shock Velocity Calculation function
    function ShockVel = shockvelcalc(MatNum,up)
        ShockVel=C(MatNum)+S(MatNum).*up;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Array writing function -combines all names and data sets
    function  filearray(up,Y,Mat)
        
        %Create cell matrix with all file headings
        Mat={Mat}; MatA=horzcat(MatA,Mat);
        
        %Create cell array with all data sets
        Pu=horzcat(up',Y');
        PuA{filecount}=Pu;
        
        filecount=filecount+1;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%File writing function - given name and data set arrays, writes file
    function  filewrite()
        fprintf('Writing File....');
        
        %%%%%%%%%%%%%%%%%%%%%%Pressure-particle velocity file
        if pressureplot ==1
            %Write plot headings to file
            fid2=fopen('P_u.txt','w');
            
            for i=1:length(MatA)
                MatTemp=cell2mat(MatA{i});
                fprintf(fid2,'%s up, %s P,',MatTemp, MatTemp);
            end
            fprintf(fid2,'\n');
            
            %Write data sets to file
            dlmwrite('P_u.txt', PuA,'-append');
            fclose(fid2);
            
            %%%%%%%%%%%%%%%%%%%%%%Shock velocity-particle velocity file
        else
            %Write plot headings to file
            fid2=fopen('Us_up.txt','w');
            
            for i=1:length(MatA)
                MatTemp=cell2mat(MatA{i});
                fprintf(fid2,'%s up, %s Us,',MatTemp, MatTemp);
            end
            fprintf(fid2,'\n');
            
            %Write data sets to file
            dlmwrite('Us_up.txt', PuA,'-append');
            fclose(fid2);
        end
        
        fprintf('Complete\n');
    end


%Pressure Calculation function - given MatNum, Density, C, S, up(linspace), calculates P(up)
    function [upsolve,Psolve] = HugSolve(Mat1,Mat2,revup)
        f=@(up) (Density(Mat1).*(C(Mat1)+S(Mat1).*up).*up)-(Density(Mat2).*(C(Mat2)+S(Mat2) ...
            .*(revup-up)).*(revup-up));
        [upsolve]=fzero(f,(upmax-upmin)/2);
        Psolve=(Density(Mat1).*(C(Mat1)+S(Mat1).*upsolve).*upsolve);
    end

end %End entire program



