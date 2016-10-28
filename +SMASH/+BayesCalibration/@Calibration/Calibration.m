% This class creates objects for use in Bayesian calibration through Markov
% Chain Monte Carlo (MCMC)

% A Calibration object can be constructed without any input:
%
%        >> object = SMASH.BayesCalibration.Calibration
%
% There are 3 structures which must be configured prior to running the
% calibration.
%
%   ModelSettings:
%       Model : Function handle specification. The model must take the
%       variables as inputs and output the residuals (difference between 
%       experiment and model) and the covariance.
%
%   VariableSettings:
%       Names : cell array of strings specifiying variables names
%       PriorType : cell array of strings specifying the type of prior on
%           each name. Valid options are 'uniform' and 'gauss'
%       PriorSettings : cell array of arrays specifying the settings for
%           each prior. Uniform should be [lowerbound, upperbound], while
%           gauss is [mean, std].
%       ConstraintSettings : cell array specifying constraints on the
%           variables : {[variable numbers], @equation}. Equation should be 
%           a logical anonymous function relating to variables. 
%           eg. @(x) x(1)>0 & x(2) > 0.           
%       Infer (opt): Logical array specifying which variables should be 
%           inferred in the calibration. If they are fixed, then Feedback 
%           cutting / modularization  is applied (sampling occurs from 
%           prior / no MCMC updates). If left blank, the default is to 
%           infer all parameters.
%       Share (opt): Logical array specifying if any variables are shared 
%           when calibrating multiple objects (experiments). The default 
%           is to share no parameters.
%       EffectiveSampleSize : likelihood scaling algorithm based on ESS.
%           Note: this size is used in the conjugate sampling of phi.
%       DiscrepancyPriorCov : Switch into "standard" calibration mode where
%           this defines the correlation matrix, R. Note: this also
%           requires a switch from conjugate to Metropolis sampling of phi.
%       DiscrepancyPriorWeights : "Standard" calibration mode where this
%           defines the weights, sigma.
%       
%       
%   MCMCSettings : Settings for the Markov Chain Monte Carlo algorithm
%       StartPoint : Array specifying the starting set of parameters
%       ChainSize : Amount of points in the chain to generate
%       ProposalCov (opt) : Array specifying covariance for proposal
%           jumps. If empty, proposals are drawn from the priors instead.
%       DelayedRejectionScale : Scalar specifying the factor of decrease in
%           the proposal jump in the delayed rejection algorithm. If 0, no
%           delayed rejection is used.
%       AdaptiveInterval : Scalar specifying the length of chain points
%       between adaptation of the proposal covariance. If 0, no adaptation 
%            is used.
%       HyperSettings : Specification for inferrence of the error scaling
%           hyperparameter. This prior is an assumed inverse gamma with
%           parameters [shape,scale]. 
%
%   The Measurement options is provided as a placeholder for experimental
%       data for use in the ModelSettings.Model function.
%
%
% See also BayesCalibration, runMCMC
%

%
% created June 20, 2016 by Justin Brown (Sandia National Laboratories)
%
classdef Calibration
    %%
    properties (SetAccess=protected)
        
    end
    properties
        Comments = '' % Object comments
        Measurement % Experimental response
        ModelSettings % Structure defining the model
        VariableSettings % Structure defining the variables
        MCMCSettings % Structure defining MCMC settings
        MCMCResults % Structure without output of MCMC
    end    
    properties
        GraphicOptions % Graphic options (GraphicOptions object)        
    end   
    
    properties (SetAccess=protected,Hidden=true)        
        
    end
    %%
    methods (Hidden=true)
        function object=Calibration(varargin)
            object=create(object,varargin{:});            
        end
        %varargout=convert(varargin);
    end
    %%
    methods (Access=protected, Hidden=true)
        varargout=create(varargin);
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);        
    end   
end
