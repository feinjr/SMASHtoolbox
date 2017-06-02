%This class produces time and wavelength calibrated spectra for streaked
%spectral analysis. The Spectroscopy object is created by
%SVSAnalysis(dataImage,wavelengthImage,timeImage)
%where dataImage is the image to be calibrated, wavelengthImage is used to
%calibrate the wavelength, and timeImage is used to calibrate the time. In
%practice it is possible for two or three of these images to be the same,
%particularly on the film systems. The calibration is stored as polynomial 
%coefficients, which are used to plot intensity (in arbitrary units for now) 
%as a function of time or wavelength. 
%Most of the properties are set after using the methods in this class.

%created May 12, 2017 by Sonal Patel (Sandia National Laboratories)

classdef Spectroscopy 
    %% properties
    properties     
        DataImage=[];
        WavelengthImage=[];
        TimeImage=[];
        
        TimeDirection=[]; 
        WavelengthDirection=[];
        ImpulseTime=[];
        CombFrequency=[];      
        
        KnownWavelengthLines=[];
       
        WavePolyFitCoeff=[];
        TimePolyFitCoeff=[];

    end
    methods 
        function obj=Spectroscopy(data,wave,time)
            obj.DataImage=data;
            obj.WavelengthImage=wave;
            obj.TimeImage=time;           
        end              
        
    end
end