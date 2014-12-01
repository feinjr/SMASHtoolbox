% guiLineVISAR Graphical user interface for LineVISAR objects
%
% created May 13, 2014 by Tommy Ao (Sandia National Laboratories)
%
function guiLineVISAR(varargin)

% determine if GUI already exists
h=findall(0,'Type','figure','Tag','guiPlanck');
if ishandle(h)
    figure(h);
    return
end

% create dialog box
diaLineVISAR=SMASH.MUI.Dialog;
diaLineVISAR.Hidden=true;
diaLineVISAR.Name='GUI for LinVISAR';
set(diaLineVISAR.Handle,'Tag','guiLineVISAR');

% add dialog edit blocks
label={'Input file name',' select '};
h=addblock(diaLineVISAR,'edit_button',label,40);
FileBox=h(2);
set(h(3),'Callback',@ChooseFile);
    function ChooseFile(varargin)
        current=get(FileBox,'String');
        [pathname,~]=fileparts(current);
        [filename,pathname]=uigetfile('*.*','Choose input file',pathname);
        if isnumeric(filename)
            return
        end
        set(FileBox,'String',fullfile(pathname,filename));
    end

% add dialog Update button
h=addblock(diaLineVISAR,'button',' Update ');
set(h,'Callback',@UpdateCallback);
    function UpdateCallback(varargin)
        value=probe(diaLineVISAR);
        file=value{1};        
        % create figure
        if isempty(figLineVISAR)
            figLineVISAR=SMASH.MUI.Figure();
            figLineVISAR.Name='Line VISAR';            
        end
    end

% add dialog Done button
h=addblock(diaLineVISAR,'button',' Done ');
set(h,'Callback',@DoneCallback);
    function DoneCallback(varargin)
        delete(diaLineVISAR);
        delete(figLineVISAR);
    end

% show dialog box
locate(diaLineVISAR,'center');
diaLineVISAR.Hidden=false;

figLineVISAR=[];

end