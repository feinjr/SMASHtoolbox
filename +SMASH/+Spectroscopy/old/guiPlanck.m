% guiPlanck Graphical user interface for Planck objects
%
% created May 12, 2014 by Tommy Ao (Sandia National Laboratories)
% modified July 8, 2014 by Tommy Ao
%
function varargout=guiPlanck(varargin)

% determine if GUI already exists
h=findall(0,'Type','figure','Tag','guiPlanck');
if ishandle(h)
    figure(h);
    return
end

% create dialog box
diaPlanck=SMASH.MUI.Dialog;
diaPlanck.Hidden=true;
diaPlanck.Name='GUI for Planck';
set(diaPlanck.Handle,'Tag','guiPlanck');

% add dialog edit blocks
wavelength1=10;
h=addblock(diaPlanck,'edit','Min Wavelength (nm)',20);
Wavelength1Edit=h(2);
set(Wavelength1Edit,'String',wavelength1);
wavelength2=1000;
h=addblock(diaPlanck,'edit','Max Wavelength (nm)',20);
Wavelength2Edit=h(2);
set(Wavelength2Edit,'String',wavelength2);
temperature=10000;
h=addblock(diaPlanck,'edit','Temperature (K)',20);
TemperatureEdit=h(2);
set(TemperatureEdit,'String',temperature);
emissivity=1;
h=addblock(diaPlanck,'edit','Emissivity',20);
EmissivityEdit=h(2);
set(EmissivityEdit,'String',emissivity);

% add dialog New Plot check box
h=addblock(diaPlanck,'check','New Plot');
NewPlotCheck=h(1);
set(NewPlotCheck,'Value',0);

% add dialog Update button
h=addblock(diaPlanck,'button',' Update ');
set(h,'Callback',@UpdateCallback);
    function UpdateCallback(varargin)
        value=probe(diaPlanck);
        wavelength1=sscanf(value{1},'%g');
        wavelength2=sscanf(value{2},'%g');
        temperature=sscanf(value{3},'%g');
        emissivity=sscanf(value{4},'%g');
        newfig=value{5};
        % calculate Planck radiance
        %objPlanck=calPlanck(wavelength1,wavelength2,temperature,emissivity);
        % create figure
        if isempty(figPlanck)
            figPlanck=SMASH.MUI.Figure();
            figPlanck.Name='Planck Radiation';            
        end
        figure(figPlanck.Handle);
        locate(figPlanck,'eastoutside',diaPlanck.Handle);
        if newfig==1 % plot new figure
            newplot; hline=[]; hlabel=[];
            hline{1}=line(objPlanck.Grid,objPlanck.Data);
            hlabel{1}=sprintf('T = %g K, emis. = %g',temperature,emissivity);
        else % add plot to current figure
            hlabel=getappdata(figPlanck,'Label');
            hline=getappdata(figPlanck,'Line');
            hline{end+1}=line(objPlanck.Grid,objPlanck.Data);
            hlabel{end+1}=sprintf('T = %g K, emis. = %g',temperature,emissivity);
        end
        setappdata(figPlanck,'Label',hlabel);
        setappdata(figPlanck,'Line',hline);
        map=jet(max(length(hline),10));
        for n=length(hline):-1:1
            length(hline)
            set(hline{n},'Color',map(n,:));
        end
        legend(hlabel{:});
        axis('auto');
        xlabel('Wavelength (nm)');
        ylabel('Spectral Radiance (W·sr^{-1}·m^{-2}·nm^{-1})');
        title('Planck Spectral Radiance');       
    end

% add dialog Done button
h=addblock(diaPlanck,'button',' Done ');
set(h,'Callback',@DoneCallback);
    function DoneCallback(varargin)
        delete(diaPlanck);
        delete(figPlanck);
    end

% show dialog box
locate(diaPlanck,'center');
diaPlanck.Hidden=false;

figPlanck=[];

end

% function objPlanck=calPlanck(wavelength1,wavelength2,temperature,emissivity)
% 
% % calculate Planck radiance
% wavelength=linspace(wavelength1,wavelength2,1000);
% objPlanck=SMASH.Spectroscopy.Planck(wavelength,temperature,emissivity);
% 
% end
