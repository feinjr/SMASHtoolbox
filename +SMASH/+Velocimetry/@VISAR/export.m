% EXPORT - Export the data and settings from a VISAR object
%
% This method exports data from a VSIAR object ot a column text file
%     >> view(object,filename,option);
%
% Filename defines the file the data is saved to.  These can be *.txt,
% *.out, or *.dat extensions.
%
% Otpion defines which signal is to be exported
%     'Measurement'  - Export the Raw measurement signals.  This is the
%                      default.
%     'Experiment'   - Export the Experimental region of the raw signals
%                      only.
%     'Reference'    - Export the reference region of the raw signals only.
%     'Quadrature'   - Export the quadrature signals.  The VISAR object 
%                      must be processed for this option.
%     'Fringeshift'  - Export the Fringe shift signal.  The VISAR object 
%                      must be processed for this option.
%     'Contrast'     - Export the Contrast signal.  The VISAR object must
%                      be processed for this option.
%     'Velocity'     - Export the Velocity signal.  The VISAR object must
%                      be analyzed for this option.
% 
% created March 21, 2016 by Paul Specht (Sandia National Laboratories)

function object=export(object,filename,option)

%manage input
if nargin < 3 || nargin > 3
    error('ERROR:  Invalid Export Input.  Must Define File Name.');
end

%export the signals
switch lower(option)
    case 'measurement'
        export(object.Measurement,filename);
    case 'processed'
        export(object.Processed,filename);
    case 'experiment'
        objtemp=crop(object,object.ExperimentalRegion);
        export(objtemp.Measurement,filename);
    case 'reference'
        objtemp=crop(object,object.ReferenceRegion);
        export(objtemp.Measurement,filename);
    case 'fringeshift'
        export(object.FringeShift,filename);
    case 'contrast'
        export(object.Contrast,filename);
    case 'quadrature'
        export(object.Quadrature,filename);
    case 'velocity'
        export(object.Velocity,filename);
    otherwise
        error('ERROR: Invalid Export Option');
end

end