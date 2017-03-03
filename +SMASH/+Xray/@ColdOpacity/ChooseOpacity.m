function object = ChooseOpacity(object,varargin)
%function object = ChooseOpacity(varargin)

CompoundList = {'Quartz','Kapton','Mylar','Lexan','Stainless','IP','Saran','Paralyne-C'};

diaKappa=SMASH.MUI.Dialog;
diaKappa.Hidden=true;
diaKappa.Name='Calculate Transmission';
set(diaKappa.Handle,'Tag','guiKappa');

hpop = addblock(diaKappa,'popup','Choose Material:',CompoundList);
hmaterial = addblock(diaKappa,'edit','Or enter Element ',20); % Edit box to input rotation angle
set(hmaterial(2),'String','')

hMin = addblock(diaKappa,'edit','Set Minimum Energy [eV]',20); % Edit box to input rotation angle
set(hMin(2),'String','100')
hMax = addblock(diaKappa,'edit','Set Maximum Energy [eV]',20); % Edit box to input rotation angle
set(hMax(2),'String','30000')
hPts = addblock(diaKappa,'edit','Set Number of Points',20); % Edit box to input rotation angle
set(hPts(2),'String','500')

hThickness = addblock(diaKappa,'edit','Set Material Thickness',20); % Edit box to input rotation angle
set(hThickness(2),'String','')

hRho = addblock(diaKappa,'edit','Set Material Density',20); % Edit box to input rotation angle
set(hRho(2),'String','')

Egrid = [];
material = [];
Thickness = [];
Density = [];

hDone=addblock(diaKappa,'button',' Done '); % commits the rotation and grabs the new object
set(hDone,'Callback',@DoneCallback);

diaKappa.Hidden=false;
uiwait

object.Settings.Material = material;
object.Settings.Energy = Egrid;

if isnan(Thickness); object.Settings.Thickness = [];
else object.Settings.Thickness = Thickness; 
end
object.Settings.Density = Density;

    function DoneCallback(varargin)
        obj=get(gcbf,'UserData');
        values=probe(obj);
        
        if isempty(values{2})
            material = values{1};
            Egrid = [str2double(values{3}) str2double(values{4}) str2double(values{5})];
            Thickness = str2double(values{6});
            Density = values{7};
        else
            material = values{2};
            Egrid = [str2double(values{3}) str2double(values{4}) str2double(values{5})];
            Thickness = str2double(values{6});
            Density = values{7};
        end
        delete(diaKappa);
    end

end
