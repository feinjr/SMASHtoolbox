% UNDER CONSTRUCTION
%
% Interface to aid in setting up the calibration object. Called as: 
% 
%   >> settingsGUI(object),
% 
% the method will load in any relevant settings currently associated the
% object and allows for thier modification. This method if primarily
% associated with the variable and MCMC setup. There is still some setup
% required with the model definition (residual calculation) and potentially
% the discrepancy model configuration.
%
% *The object update is currently handled with assignin, so cell array
% inputs are not compatible.

% created Oct 5, 2016 by Justin Brown (Sandia National Laboratories)


function settingsGUI(object)

vname = inputname(1);

objectorig = object;

%% create dialog
dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='Bayes Calibration Configuration (UNDER CONSTRUCTION)';
local=[]; % SDAfile object (created by loadFile callback, used everywhere)

%% Variable settings block
VariablesTitle=addblock(dlg,'text','Variable Settings');
set(VariablesTitle,'FontWeight','bold');

%VariablesButton=addblock(dlg,'edit_button',{'Number of Variables','Edit Variable Settings'},15);
%set(VariablesButton,'FontWeight','bold');
%set(VariablesButton,'Callback',@variablesButton);
%VariablesTable=addblock(dlg,'table',[{'Name'},{'Prior Type'},{'Prior Settings'},{'Inferred'},{'Shared'}],[15],1);


VariablesNumber=addblock(dlg,'edit','Number of Variables',15);
set(VariablesNumber,'Callback',@variablesNumber);

%Make space for uitable
for i = 1:10;
    TableFill(i)=addblock(dlg,'text',' ',80);
end


    % Create the uitable
    % Column names and column format
    prioropts = {'Gaussian','Uniform'};
    columnname = {'Name','    Prior Type    ','<html>&mu / LB </html>','<html>&sigma / UB </html>','Inferred','Shared','Starting Point','Proposal Covariance'};
    columnformat = {'char',prioropts,'numeric','numeric','logical','logical','numeric','numeric'};
    
    d={};
    if ~isempty(object.VariableSettings.Names)
        j=1;
        children=get(dlg.Handle,'Children');
        set(children(11),'string',length(object.VariableSettings.Names));
        for ii=1:length(object.VariableSettings.Names);
            d{ii,1} = object.VariableSettings.Names{ii};
            d{ii,2} = object.VariableSettings.PriorType{ii};
            d{ii,3} = object.VariableSettings.PriorSettings{ii}(1);
            d{ii,4} = object.VariableSettings.PriorSettings{ii}(2);
            try
                d{ii,5} = logical(object.VariableSettings.Infer(ii));
            catch
                d{ii,5} = true;
            end
            try
                d{ii,6} = logical(object.VariableSettings.Share(ii));
            catch
                 d{ii,6} = false;
            end
            d{ii,7} = object.MCMCSettings.StartPoint(ii);
            if d{ii,5}
                try
                    d{ii,8} = object.MCMCSettings.ProposalCov(j);
                    j=j+1;
                catch
                    d{ii,8}=[];
                end
                
            end
        end
    else
        d = {sprintf('Variable%i',1),'Gaussian',1,0,true,false,0,0};
    end
    
    t = uitable('Data', d,... 
                'ColumnName', columnname,...
                'ColumnFormat', columnformat,...
                'ColumnEditable', [true true true true true true true true],...
                'RowName',[],'ColumnWidth','auto');
    % Set width and height
    htop=TableFill(1);
    hbot=TableFill(10);
    t.Position(1) = htop.Position(1);
    t.Position(2) = hbot.Position(2);
    t.Position(3) = t.Extent(3)+20;
    t.Position(4) = htop.Position(2)-hbot.Position(2); 

gap=addblock(dlg,'text',' ',40); % extra gap

HyperText=addblock(dlg,'text','Hyper-parameter inverse gamma prior:');
HyperSettings=addblock(dlg,'table',{'Shape (a)','Scale (b)'},[],1);

box(dlg,[VariablesTitle,VariablesNumber,TableFill,HyperText,HyperSettings]);


%% MCMC settings block
gap=addblock(dlg,'text',' ',60); % extra gap
delete(gap);
MCMCTitle=addblock(dlg,'text','MCMC Settings');
set(MCMCTitle,'FontWeight','bold');

ModelHandle=addblock(dlg,'edit','Model Function Handle',15);
ChainSize=addblock(dlg,'edit','Chain Size',15);
Burnin=addblock(dlg,'edit','Burn-In',15);
Adapt=addblock(dlg,'edit','Adaptive Interval',15);
DR=addblock(dlg,'edit','Delayed Rejection Scale',15);
Joint=addblock(dlg,'check','Block Proposal Sampling');


children=get(dlg.Handle,'Children');
set(children(1),'value',object.MCMCSettings.JointSampling);
set(children(2),'String',object.MCMCSettings.DelayedRejectionScale);
set(children(4),'String',object.MCMCSettings.AdaptiveInterval);
set(children(6),'String',object.MCMCSettings.BurnIn);
set(children(8),'String',object.MCMCSettings.ChainSize);
set(children(10),'String',char(object.ModelSettings.Model));
try
    set(children(13),'Data',{object.VariableSettings.HyperSettings(1),object.VariableSettings.HyperSettings(2)});
catch
    set(children(13),'Data',{[],[]});
end
box(dlg,[MCMCTitle,ChainSize,Burnin,Adapt,DR,Joint]);



%% Apply, done
gap=addblock(dlg,'text',' ',60); % extra gap
delete(gap);
ApplyDone=addblock(dlg,'button',{' Apply ',' Done '});
set(ApplyDone(1),'Callback',@apply);
set(ApplyDone(2),'Callback',@done);


dlg.Hidden = false;





%% Callbacks
% Update UItable
function variablesNumber(varargin)
    
    x = probe(dlg);
    nrows = str2double(x{1});    

    % Define the data
    
    d = get(t,'Data');
    [nr,~]=size(d);

    if nrows <= nr
        d=d(1:nrows,:);
    else
        for ii=nr+1:nrows
            dtemp = {sprintf('Variable%i',ii),'Gaussian',1,0,true,false,0,0};
            d=[d;dtemp];
        end
    end
            

    set(t,'Data',d);
end

% Done button
function done(varargin)
    delete(dlg);
end


% Apply button
function apply(varargin)
    
    object=objectorig;
    
    % Parse GUI
    pdlg = probe(dlg);
    %tdat = t.Data;
    tdat = pdlg{2};
    
    [nv,~]=size(tdat);
    
    j=1;
    for ii=1:nv
        object.VariableSettings.Names{ii} = tdat{ii,1};
        if strcmpi(tdat{ii,2},'Gaussian')
            object.VariableSettings.PriorType{ii} = 'Gauss';
        elseif strcmpi(tdat{ii,2},'Uniform')
            object.VariableSettings.PriorType{ii} = 'Uniform';
        end
        object.VariableSettings.PriorSettings{ii} = [tdat{ii,3},tdat{ii,4}];
        object.VariableSettings.Infer(ii) = tdat{ii,5};
        object.VariableSettings.Share(ii) = tdat{ii,6};
        object.MCMCSettings.StartPoint(ii) = tdat{ii,7};
        if tdat{ii,5}
            object.MCMCSettings.ProposalCov(j) = tdat{ii,8};
            j=j+1;
        end
    end
    object.VariableSettings.Infer = logical(object.VariableSettings.Infer);
    object.VariableSettings.Share = logical(object.VariableSettings.Share);
    object.VariableSettings.HyperSettings=cell2mat(pdlg{3});
    object.ModelSettings.Model=str2func(pdlg{4});
    object.MCMCSettings.ChainSize=str2double(pdlg{5});
    object.MCMCSettings.BurnIn =str2double(pdlg{6});
    object.MCMCSettings.AdaptiveInterval =str2double(pdlg{7});
    object.MCMCSettings.DelayedRejectionScale =str2double(pdlg{8});
    object.MCMCSettings.JointSampling = pdlg{9};
   
    assignin('base',vname,object);
    
    
end


end
