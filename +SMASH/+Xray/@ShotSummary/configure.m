function [ object ] = configure( object, varargin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
for n=1:2:numel(varargin)
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid setting name');
    value=varargin{n+1};
    switch lower(name)
        case 'shot'
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: shot number must be scalar integer');
            object.Shot=value;
            
        case 'date'
            assert(ischar(value), 'ERROR: Date must be a string');
            object.Date = value;
            
        case 'campaign'
            assert(ischar(value), 'ERROR: Campaign name must be a string');
            object.Campaign = value;
            
        case {'hardware', 'hardware set', 'hardwareset'}
            assert(ischar(value), 'ERROR: Hardware set must be a string');
            object.HardwareSet = value;
            
        case {'liner', 'dimensions', 'liner dimensions', 'linerdimensions'}
            assert(isnumeric(value) && numel(value) == 2,...
                'ERROR: Liner dimensions must be a 2-element array with [inner radius [cm], outer radius [cm]]');
            object.LinerDimensions = value;
            
        case {'height', 'imploding height', 'implodingheight'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: Height must be scalar number in [cm]');
            object.ImplodingHeight=value;
            
        case 'cushions'
            assert(iscell(value),...
                'ERROR: Cushions property must be a cell array of strings identifying the material of the top and bottom cushions');
            object.Cushions=value;
            
        case 'dopants'
            assert(ischar(value), 'ERROR: Dopants property must be a string');
            object.Dopants = value;
            
        case {'fill pressure','fillpressure', 'pressure'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: Gas fill pressure must be scalar');
            object.FillPressure=value;
            
        case {'fill temperature','filltemperature', 'temperature'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: Target temperature must be scalar');
            object.FillTemperature=value;
            
        case {'fieldstrength','field strength'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: Initial field strength must be scalar');
            object.FieldStrength=value;
            
        case {'phaseplate', 'phase plate', 'dpp'}
            assert(ischar(value), 'ERROR: PhasePlate property must be a string');
            object.PhasePlate = value;
            
        case {'laserconfiguration', 'laser configuration'}
            assert(ischar(value), 'ERROR: LaserConfiguration property must be a string');
            object.LaserConfiguration = value;

        case {'laserenergy', 'laser energy'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: LaserEnergy property must be scalar [J]');
            object.LaserEnergy=value;
        
        case {'windowthickness','window thickness'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: WindowThickness property must be scalar [um]');
            object.WindowThickness=value;
        
        case {'windowoffset','window offset'}
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: WindowOffset property must be scalar [um]');
            object.WindowOffset=value;
            
        case {'linercoating', 'liner coating', 'coating'}
            assert(iscell(value), 'ERROR: LinerCoating property must be a cell {thickness, material}');
            object.LinerCoating = value;
            
    end
end

end
