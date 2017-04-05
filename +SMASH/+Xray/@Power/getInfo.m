%
%
% created February 28, 2017 by Adam Harvey-Thompson (Sandia National Laboratories)
%

function object = getInfo(object)


SignalName = object.RawSignal.Legend
SignalNumber = size(object.RawSignal.Legend,2);


object.Settings(1,2:SignalNumber+1)=SignalName(1,1:end);
object.AnalysisSummary(1,2:SignalNumber+1)=SignalName(1,1:end);  

KeepSettings = any(~cellfun('isempty',object.Settings), 1);  % keep columns that don't only contain [] 
object.Settings = object.Settings(:,KeepSettings);
KeepSummary = any(~cellfun('isempty',object.AnalysisSummary), 1);  
object.AnalysisSummary = object.AnalysisSummary(:,KeepSummary);

SignalNames = object.Settings(1,2:end);

for i = 1:SignalNumber;
    
    Names = SignalNames(1,i);
    Name = char(Names);
ElementIdent = cellstr(Name(end-10:end-8));
ElementNumber = cellstr(Name(end-2:end));

if strcmpi(ElementIdent,'pcd')==1;
    ElementType = 'Pcd';
    if strcmp(ElementNumber,'022')==1;
        ElementSize = [3,500];
        ElementSensitivity = [5e-5 0.11];
    elseif strcmp(ElementNumber,'024')==1;
        ElementSize = [3,1000];
        ElementSensitivity = [5e-4 0.16];   
    elseif strcmp(ElementNumber,'044')==1;
        ElementSize = [3,500];
        ElementSensitivity = [2e-4 0.049];   
    elseif strcmp(ElementNumber,'047')==1;
        ElementSize = [3,500];
        ElementSensitivity = [3.2e-4 0.068];   
    elseif strcmp(ElementNumber,'050')==1;
        ElementSize = [3,500];
        ElementSensitivity = [3.0e-4 0.084];
    elseif strcmp(ElementNumber,'051')==1;
        ElementSize = [3,500];
        ElementSensitivity = [2.6e-4 0.08];
    elseif strcmp(ElementNumber,'052')==1;
        ElementSize = [3,500];
        ElementSensitivity = [5.5e-4 0.07];
    elseif strcmp(ElementNumber,'062')==1;
        ElementSize = [3,500];
        ElementSensitivity = [6.0e-4 0.073];
    elseif strcmp(ElementNumber,'063')==1;
        ElementSize = [3,500];
        ElementSensitivity = [7.0e-4 0.054];
    elseif strcmp(ElementNumber,'066')==1;
        ElementSize = [3,500];
        ElementSensitivity = [9.0e-4 0.03];     
    elseif strcmp(ElementNumber,'072')==1;
        ElementSize = [3,500];
        ElementSensitivity = [6e-4 0.08];    
    elseif strcmp(ElementNumber,'074')==1;
        ElementSize = [3,500];
        ElementSensitivity = [3.0e-4 0.12];
    elseif strcmp(ElementNumber,'078')==1;
        ElementSize = [3,500];
        ElementSensitivity = [3.0e-4 0];
    elseif strcmp(ElementNumber,'079')==1;
        ElementSize = [3,500];
        ElementSensitivity = [2.5e-4 0];
    elseif strcmp(ElementNumber,'108')==1;
        ElementSize = [1,500];
        ElementSensitivity = [4e-4 0];    
    elseif strcmp(ElementNumber,'109')==1;
        ElementSize = [1,500];
        ElementSensitivity = [4e-4 0.058]; 
    elseif strcmp(ElementNumber,'110')==1;
        ElementSize = [1,500];
        ElementSensitivity = [2e-4 0.024];  
    elseif strcmp(ElementNumber,'111')==1;
        ElementSize = [1,500];
        ElementSensitivity = [5e-4 0.024];   
    elseif strcmp(ElementNumber,'112')==1;
        ElementSize = [1,500];
        ElementSensitivity = [6.0e-4 0.38]; 
    elseif strcmp(ElementNumber,'118')==1;
        ElementSize = [1,500];
        ElementSensitivity = [4.0e-4 0.38];    
    elseif strcmp(ElementNumber,'119')==1;
        ElementSize = [1,500];
        ElementSensitivity = [5.5e-4 0.027]; 
    elseif strcmp(ElementNumber,'121')==1;
        ElementSize = [1,500];
        ElementSensitivity = [4e-4 0.071];
    elseif strcmp(ElementNumber,'122')==1;
        ElementSize = [1,500];
        ElementSensitivity = [5e-4 0.071];
    elseif strcmp(ElementNumber,'131')==1;
        ElementSize = [1,500];
        ElementSensitivity = [7e-4 0.040];
    elseif strcmp(ElementNumber,'132')==1;
        ElementSize = [1,500];
        ElementSensitivity = [4e-4 0.059];
    elseif strcmp(ElementNumber,'133')==1;
        ElementSize = [1,500];
        ElementSensitivity = [6e-4 0];
    elseif strcmp(ElementNumber,'135')==1;
        ElementSize = [1,500];
        ElementSensitivity = [9e-4 0];
    elseif strcmp(ElementNumber,'141')==1;
        ElementSize = [1,500];
        ElementSensitivity = [1e-3 0];
    elseif strcmp(ElementNumber,'164')==1;
        ElementSize = [1,500];
        ElementSensitivity = [2.4e-3 0.13]; 
    elseif strcmp(ElementNumber,'165')==1;
        ElementSize = [1,500];
        ElementSensitivity = [1.4e-3 0.15]; 
    elseif strcmp(ElementNumber,'166')==1;
        ElementSize = [1,500];
        ElementSensitivity = [2.3e-3 0.02]; 
    elseif strcmp(ElementNumber,'167')==1;
        ElementSize = [1,500];
        ElementSensitivity = [3.0e-3 0.11]; 
    elseif strcmp(ElementNumber,'168')==1;
        ElementSize = [1,500];
        ElementSensitivity = [2.0e-3 0.03];
    elseif strcmp(ElementNumber,'168')==1;
        ElementSize = [1,500];
        ElementSensitivity = [2.5e-3 0];
    else
    end
elseif strcmpi(ElementIdent,'sid')==1;
    ElementType = 'Sid';
    ElementSize = [0.28,22];
    ElementSensitivity = [0.274 0];
else
end
% Identify source distance
  
object.Settings{2,i+1}= ElementType;
object.Settings{3,i+1}= num2cell(ElementSize);
object.Settings{4,i+1}= num2cell(ElementSensitivity);

object.AnalysisSummary{2,i+1}= ElementType;
object.AnalysisSummary{8,i+1}= ElementSize(1);
LOSIdent = cellstr(Name(end-7:end-6));

if strcmp(LOSIdent,'05')==1;
   SourceDistance = 18.17   ;
   GeometryCorrection = 0.901;
elseif strcmp(LOSIdent,'17')==1;
   SourceDistance =  2.49;
   GeometryCorrection = 0.892;
elseif strcmp(LOSIdent,'21')==1;
   SourceDistance = 7.287  ;
   GeometryCorrection = 0.901;
else
end

object.Settings(5,i+1)= num2cell(SourceDistance);
object.Settings(14,i+1)= num2cell(GeometryCorrection);


%% Identify filter material and thickness
FilterIdent = Name(end-4:end-3);

if strcmpi(FilterIdent,'10')==1;
   FilterMaterial = {'Kapton'};
   FilterThickness = [50.8]   ;
elseif strcmpi(FilterIdent,'11')==1;
   FilterMaterial = {'Kapton'};
   FilterThickness = [25.4] ;
elseif strcmpi(FilterIdent,'13')==1;
   FilterMaterial = {'Kapton'};
   FilterThickness = [254]  ;
elseif strcmpi(FilterIdent,'15')==1;
   FilterMaterial = {'Beryllium','Parylene-N'};
   FilterThickness = [8,1]  ;
elseif strcmpi(FilterIdent,'50')==1;
   FilterMaterial = {'Kapton'};
   FilterThickness = [508]  ;
elseif strcmpi(FilterIdent,'53')==1;
   FilterMaterial = {'Kapton','Parylene-N'};
   FilterThickness = [8,1]  ;    
elseif strcmpi(FilterIdent,'66')==1;
   FilterMaterial = {'Kapton','Aluminum'};
   FilterThickness = [127,0.25] ;
elseif strcmpi(FilterIdent,'76')==1;
   FilterMaterial = {'Beryllium'};
   FilterThickness = [38.1] ;
elseif strcmpi(FilterIdent,'88')==1;
   FilterMaterial = {'Kapton','Aluminum'};
   FilterThickness = [50.8,0.25] ;
elseif strcmpi(FilterIdent,'90')==1;
   FilterMaterial = {'Saran'};
   FilterThickness = [12.7] ;
elseif strcmpi(FilterIdent,'91')==1;
   FilterMaterial = {'Molybdenum','Kapton'};
   FilterThickness = [9,127]   ; 
elseif strcmpi(FilterIdent,'92')==1;
   FilterMaterial = {'Titanium'};
   FilterThickness = [16]     ;
elseif strcmpi(FilterIdent,'A0')==1;
   FilterMaterial = {'Kapton','Beryllium','Parylene-N'};
   FilterThickness = [762,8,1] ;
elseif strcmpi(FilterIdent,'A2')==1;
   FilterMaterial = {'Kapton','Beryllium','Parylene-N'};
   FilterThickness = [25.4,8,1]    ; 
elseif strcmpi(FilterIdent,'A7')==1;
   FilterMaterial = {'Kapton','Beryllium','Parylene-N'};
   FilterThickness = [254,8,1]    ;
elseif strcmpi(FilterIdent,'d2')==1;
   FilterMaterial = {'Zinc'};
   FilterThickness = [125]   ;
elseif strcmpi(FilterIdent,'d3')==1;
   FilterMaterial = {'Lead'};
   FilterThickness = [30]       ;
elseif strcmpi(FilterIdent,'d4')==1;
   FilterMaterial = {'Tin'};
   FilterThickness = [75]      ;
elseif strcmpi(FilterIdent,'e1')==1;
   FilterMaterial = {'Aluminum'};
   FilterThickness = [1000]    ;     
elseif strcmpi(FilterIdent,'a0')==1;
   FilterMaterial = {'Kapton','Beryllium','Parylene-N'};
   FilterThickness = [762,8,1]    ;
elseif strcmpi(FilterIdent,'a2')==1;
   FilterMaterial = {'Kapton','Beryllium','Parylene-N'};
   FilterThickness = [25.4,8,1]       ;
elseif strcmpi(FilterIdent,'a7')==1;
   FilterMaterial = {'Kapton','Beryllium','Parylene-N'};
   FilterThickness = [254,8,1]    ;  
else
   FilterMaterial = {};
   FilterThickness = []     ;  
end

object.Settings{6,i+1}= FilterMaterial;
object.Settings{7,i+1}= num2cell(FilterThickness);

object.AnalysisSummary{3,i+1}= FilterMaterial;
object.AnalysisSummary{4,i+1}= num2cell(FilterThickness);

end
end