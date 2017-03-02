function object = CalculateOpacity(varargin)
%% sig = CalculateOpacity(element,L)
% This is a function to calculate the transmission through a foil of
% thickness L comprised of element 'element' at standard temperature and
% pressure:
% Inputs:   name: string containing element symbol, i.e. 'Al', 'V', etc.,
% material name (from list) or chemical formula.  Format for using chemical
% formula:  silicon dioxide - SiO2, (elements must be (Upper)(lower), i.e.
% Si. or (Upper) i.e. O).  If quantity is 1, omit the numeral.
%           L: foil thickness in microns
%           Varargin:
%               'Elims' - [Emin Emax] photon energy range
%               'Epts' - (scalar) number of points to use
%               'rho' - (scalar) density of compound if using chemical formula
% Outputs:  hnu: vector of photon energies in eV
%           Tx: transmission through filter
%           sig: opacity in cm^2/g
%
% Required files:   Atomic_Properties.xls
%                   atomic scattering factors from CXRO (Henke data)
%
% Written By: P. F. Knapp, pfknapp@sandia.gov
% Written On: 7/26/2011
% Modified On: 8/12/2011
%   Added ability to input compounds using matrial name from list below
%   or a chemical formula, in which case density must also be input
%
% Notes:  Includes elements 1-92
%
%% Relevant Constants
Navogadro = 6.0221415e23; %Avogadro's number
r0 = 2.81794e-13; %electron radius [cm]
lambda_conv = 1.2398e-4;  %cm/eV
object = varargin{1};

CompoundList = struct(...
    'name',...
    {'Quartz','Polyimide','Polypropelene','Polycarbonate','Mylar',...
    'Saran','Kapton','Zinc Oxide','Selenium Oxide','Lithium Fluoride',...
    'Sodium Chloride','Aluminum Oxide','Formvar','ParyleneD',...
    'ParyleneN','CH','ParyleneC'},...
    'formula',...
    {'SiO2','C22H10N2O5','C3H6','C16H14O3','C10H8O4','C4H5Cl3',...
    'C22H10N2O5','ZnO','SeO2','LiF','NaCl','Al2O3','C3H7','','C8H8','CH','C8H7Cl1'},...
    'density',...
    {2.66,1.43,0.9,1.2,1.4,1.63,1.43,5.6,3.95,2.635,2.165,3.95,1.23,1.3,...
    1.11,2.2,1.29});

%% Load atomic data
name = object.Material;
Atomic_Data = importdata('/Users/pfknapp/Documents/MATLAB/Transmission Data/sf/Atomic_Properties.xls');
NumElements = size(Atomic_Data.textdata,1);
rho_list = Atomic_Data.data(:,5); %g/cc
AtmWt_list = Atomic_Data.data(:,4); %amu

%%  Parse variable inputs
rho_in = object.Density;

hnu = object.Grid;
Epts = length(hnu);
if Epts == 0
    hnu = linspace(10,10000,500);
    Epts = length(hnu);
    object.Grid = hnu;
end

if max(hnu)>30000 && min(hnu) < 10
    warning('Photon energy cannot exceed 30000 eV or be less than 10 eV');
    hnu = linspace(10,30000,Epts);
elseif max(hnu)>30000
    warning('Photon energy cannot exceed 30000 eV');
    Emin = min(hnu);
    hnu = linspace(Emin,30000,Epts);
elseif min(hnu)<10
    warning('Minimum photon energy must be greater than 10 eV');
    Emax = max(hnu);
    hnu = linspace(10,Emax,Epts);
end

%% Determine Elements and quantities for input material

U = isstrprop(name,'upper'); %find all caps (same as elements)
A = isstrprop(name,'alpha');
if sum(U) >= 2 || sum(A) > 2 %if > 2 letters then it must be a compound, not an element
    compound_flag = 0;
    for n = 1:length(CompoundList)  %look for match to list
        if strcmp(CompoundList(n).name,name)
            rho = CompoundList(n).density;
            formula = CompoundList(n).formula;
            compound_flag = 1; %set flag if match is found
            break
        end
    end
    if ~compound_flag && isempty(rho_in)   %no match found AND no rho input
        disp(sprintf('Sorry, Your Compound [%s] is not on the list',name))
        reply = input('Enter The Density of your compound [g/cc] or quit [Q/quit]: ','s');
        if strcmp(reply,'Q') || strcmp(reply,'quit') || strcmp(reply,'Quit')
            return
        else
            rho = str2double(reply);
            formula = name;
        end
    elseif ~compound_flag && ~isempty(rho_in) % no match, but rho input
        formula = name;
        rho = rho_in;
    end
    Formula = TranslateChem(formula);
else % U<=2, therefore it is a single element
    Formula(1).element = name;
    Formula(1).quantity = 1;
end

%% initialize arrays
element = cell(1,length(Formula));
quantity = zeros(1,length(Formula));
Z = zeros(1,length(Formula));
AtmWt = zeros(1,length(Formula));
rho_temp = zeros(1,length(Formula));

% loop through elements and grab Z, atomic weight, density adn quantity
for n = 1:length(Formula)
    element{n} = sprintf('%s ',Formula(n).element);
    quantity(n) = Formula(n).quantity;
    flag = 1;
    i = 1;
    while flag && (i < NumElements)
        if strcmp(element{n},Atomic_Data.textdata(i+1,2))
            Z(n) = i;
            AtmWt(n) = AtmWt_list(i);
            rho_temp(n) = rho_list(i);
            flag = 0;
        end
        i = i+1;
    end
end

%% If only one element, use rho from look up above, otherwise use rho from list or input
if length(rho_temp) == 1
    rho = rho_temp(1);
end

%% Calculate number densities and open atomic scattering factor files
MolarMass = sum(AtmWt.*quantity); %Molar Mass
Ndensity = Navogadro*rho/MolarMass; %number density of MOLECULES

lambda = lambda_conv./hnu;  %convert energy(eV) to lambda(Angstroms)
f2 = zeros(Epts,length(AtmWt)); %initialize array for ASF's
% Loop through and calc # Density of each element in list (g/cc)
NumDensity = zeros(1,length(AtmWt));
for i = 1:length(AtmWt)
    NumDensity(i) = Ndensity*quantity(i);
    % Open Atomic Scattering Factor file
    if numel(Formula(i).element) == 1
        ASF_file = strcat('sf/',lower(Formula(i).element(1)),'.nff');
    elseif numel(Formula(i).element) == 2
        ASF_file = strcat('sf/',lower(Formula(i).element(1)),Formula(i).element(2),'.nff');
    end
    fid = fopen(ASF_file);
    ASF = textscan(fid,'%f %f %f','CommentStyle','E');
    f2(:,i) = interp1(ASF{1},ASF{3},hnu);
end
NumDensity = repmat(NumDensity,Epts,1);
%% Calculate linear absorption coefficient
mu_L = 2*r0*lambda'.*sum(NumDensity.*f2,2);
object.Data = mu_L/rho;
object.Density = rho;
end
