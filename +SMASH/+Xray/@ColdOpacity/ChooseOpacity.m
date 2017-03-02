function object = ChooseOpacity(object,varargin)
%function object = ChooseOpacity(varargin)

CompoundList = ...
    {'Quartz','Polyimide','Polypropelene','Polycarbonate','Mylar',...
    'Saran','Kapton','Zinc Oxide','Selenium Oxide','Lithium Fluoride',...
    'Sodium Chloride','Aluminum Oxide','Formvar','ParyleneD',...
    'ParyleneN','CH','ParyleneC'};

diaKappa=SMASH.MUI.Dialog;
diaKappa.Hidden=true;
diaKappa.Name='Calculate Transmission';
set(diaKappa.Handle,'Tag','guiKappa');

hpop = addblock(diaKappa,'popup','Choose Material:',CompoundList);
hmaterial = addblock(diaKappa,'edit','Or enter Element ',20); % Edit box to input rotation angle
set(hmaterial(2),'String','')

hMin = addblock(diaKappa,'edit','Set Minimum Energy [eV]',20); % Edit box to input rotation angle
set(hMin(2),'String','1000')
hMax = addblock(diaKappa,'edit','Set Maximum Energy [eV]',20); % Edit box to input rotation angle
set(hMax(2),'String','10000')
hPts = addblock(diaKappa,'edit','Set Number of Points',20); % Edit box to input rotation angle
set(hPts(2),'String','500')

Egrid = [];
material = [];

hDone=addblock(diaKappa,'button',' Done '); % commits the rotation and grabs the new object
set(hDone,'Callback',@DoneCallback);

diaKappa.Hidden=false;
uiwait

object.Material = material;
hnu = linspace(Egrid(1),Egrid(2),Egrid(3));
object.Grid = hnu;

    function DoneCallback(varargin)
        obj=get(gcbf,'UserData');
        values=probe(obj);
        
        if isempty(values{2})
            material = values{1};
            Egrid = [str2double(values{3}) str2double(values{4}) str2double(values{5})];
        else
            material = values{2};
            Egrid = [str2double(values{3}) str2double(values{4}) str2double(values{5})];
        end
        delete(diaKappa);
    end

end
