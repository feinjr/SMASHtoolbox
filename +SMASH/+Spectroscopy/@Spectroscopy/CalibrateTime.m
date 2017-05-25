function obj=CalibrateTime(obj,ImpulseT,CombFreq,TimeDir)
%The CalibrateTime method takes an impulse time, comb frequency
%(in MHz), and Time Direction ('X', or 'Y') to calibrate the
%streak timing using the Time image in the spectroscopy class.
%The polynomial coefficients results are stored in
%TimePolyFitCoeff. See the CalibrateTimeGUI function help for
%more details.
%Example: obj.CalibrateTime(3100,35,'X')

obj.CombFrequency=CombFreq;
obj.ImpulseTime=ImpulseT;
obj.TimeDirection=TimeDir;
obj.TimePolyFitCoeff=CalibrateTimeGUI(obj.TimeImage,obj.ImpulseTime,obj.CombFrequency,obj.TimeDirection);
end