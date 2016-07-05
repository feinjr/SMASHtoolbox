% This class creates objects for training and evaluating Gaussian Processes
% (GP) emulators. It utilzes the DACE (Design and Analysis of Computer Experiments) 
% Toolbox Version 2.5, September 4, 2002 Copyright (c) 2002 by Hans Bruun Nielsen and IMM. 

% A GP object can be constructed without any input:
%
%        >> object = SMASH.BayesCalibration.Emulator.GP
%
% Build data can then be input directly into the object properties, or by
% using the loadDakotaTraining method. Alternatively, the training data
% can be input during the construction:
%
%       >> object = SMASH.BayesCalibration.Emulator.GP(VD,RD)
%
% where VD is an mxn matrix containing the VariableData while RD is an mxq
% matrix containing the ResponseData.
%
% The Grid property allows the object to carry along an independent data
% set (such as time). 
%
% See also BayesCalibration, create, fit, evaluate
%

%
% created June 20, 2016 by Justin Brown (Sandia National Laboratories)
%
classdef GP
    %%
    properties (SetAccess=protected)
        DACEFit % Structure for the fit GP
    end
    properties
        Comments = '' % Object comments
        VariableNames % Cell array of variable names
        VariableData % Design sites : mxn matrix
        ResponseNames % Cell array of response names 
        ResponseData % Responses : mxq matrix
        Settings % Analysis settings
        Grid % Independent data array (typically time)
    end
    properties
        GraphicOptions % Graphic options (GraphicOptions object)        
    end   
    properties (SetAccess=protected,Hidden=true)        
        NumberVariables
        NumberResponses
    end
    %%
    methods (Hidden=true)
        function object=GP(varargin)
            object=create(object,varargin{:});            
        end
        %varargout=convert(varargin);
    end
    %%
    methods (Access=protected, Hidden=true)
        %varargout=create(varargin);
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);        
    end   
end