%  fringen : fringe generator for VISAR/PDV measurements
% 
%  This function synthesizes VISAR and PDV signals for a given velocity
%  history.  Calling the function with no inputs:
%     >> fringen
%  launches a graphical interface for generating VISAR/PDV signals.
% 
%  Users can bypass the graphical interface by specifying 1-3 input
%  arguments.
%     >> [signal,time]=fringen(mode,history_file,parameters); 
%  Results are stored in the output arguments: signal and time.  The time
%  array is always one-dimensional, but the signal array may be
%  two-dimensional if multiple phase shifts are specified (see below).
% 
%  The first input argument, mode, defines the
%  measurement as 'VISAR' or 'PDV' (not case sensitive).  The second
%  argument defines an input history file containing 2-5 columns of
%  ASCII data.
%      Column 1: time (required)
%      Column 2: velocity (required)
%      Column 3: coherent target light intensity (optional)
%      Column 4: incoherent target light intensity (optional)
%      Column 5: reference light intensity (optional, PDV only)
%  
%  Measurement parameters are passed as a structure with the following fields.
%      wavelength: operating wavelength of the interferometer 
%      fshift: frequency shift (PDV only)
%      delay: interferometer delay time (VISAR only) 
%      dispersion: interfometer dispersion (VISAR only) 
%      ref_phase: reference phase of the interferometer (degrees) 
%      phase_shift: phase shifts for the various detectors (degrees) 
%      ref_scale: intensity scaling of the reference path 
%      delay_scale: intensity scaling of the delay path (VISAR only)
%      target_scale: intensity scaling of the target path (PDV only)
%  The number of signals generated by the program is defined by the number
%  of phase_shift entries.  By default, a VISAR measurement is calculated
%  with four phase shifts ([0 180 90 270]) and a PDV measurement is
%  simulated with on phase ([0]).  Additional or fewer phase shifts may be
%  specified for each configuation.  Intensity scaling defines how light
%  from each path couples to signal.  Individual scaling factors may be
%  specified for each phase shift; if the number of scaling factors does not
%  match the number of phase shifts, the first scaling factor will be
%  applied to all phase shifts. 
% 
%  Additional parameter fields are available
%  for transferring the ideal interferometer signal to an semi-realistic
%  measurement.
%      coupling: specifies 'DC' (default) or 'AC' coupling
%      impulse_response : define data file containing detector impulse
%         response
%      noise_fraction: Gaussian noise amplitude relative to signal amplitude
%         (default is zero)
%      bit_range: effective dynamic range of the digitized signal (default
%         is 8)
%  An additional field "noise_seed" is also available for resetting the
%  random number generator used in generating signal noise.  Specifying this
%  parameter (unsigned 32-bit integer) provides reproducible signals each
%  time the program runs.

varargout=fringen(varargin)
end
