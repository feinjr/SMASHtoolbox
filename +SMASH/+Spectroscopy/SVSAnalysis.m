classdef SVSAnalysis < handle
    %% properties
    properties % core data     
        DataImage=[];
        WavelengthImage=[];
        TimeImage=[];
        
        TimeDirection=[]; %Enter 'X' or 'Y'
        WavelengthDirection=[];
        ImpulseTime=[];
        CombFrequency=[];      
        
        KnownWavelengthLines=[];
       
        WavePolyFitCoeff=[];
        TimePolyFitCoeff=[];

    end
    methods (Hidden=true)
        function obj=SVSAnalysis(data,wave,time)
            obj.DataImage=data;
            obj.WavelengthImage=wave;
            obj.TimeImage=time;           
        end       

        function RotatedData=RotateImage(obj,image,type)
            [RotatedData,angle]=RotateSpectraGUI(image);
            RotatedData(isnan(RotatedData))=0;
            if exist('type', 'var')
                if type=='All'
                    obj.WavelengthImage=Rotate(obj.WavelengthImage,angle);
                    obj.TimeImage=Rotate(obj.TimeImage,angle);
                    obj.DataImage=Rotate(obj.DataImage,angle);
                    
                    obj.DataImage(isnan(obj.DataImage))=0;
                    obj.TimeImage(isnan(obj.TimeImage))=0;
                    obj.WavelengthImage(isnan(obj.WavelengthImage))=0;
                end
            end
        end
        function CalibrateTime(obj,ImpulseT,CombFreq,TimeDir)
            obj.CombFrequency=CombFreq;
            obj.ImpulseTime=ImpulseT;
            obj.TimeDirection=TimeDir;   
            obj.TimePolyFitCoeff=CalibrateTime(obj.TimeImage,obj.ImpulseTime,obj.CombFrequency,obj.TimeDirection);
        end
        
        function GetLampWavelengths(obj,WaveDirection,centerWavelength,grating)
            obj.WavelengthDirection=WaveDirection;
            close all
            f=figure;
            ax=gca;
            ScaledImage(f,ax,obj.WavelengthImage);
            title('Select wavelength cal region')
            [ROI,~]=DrawRectangle();
            [x,y]=Lineout(obj.WavelengthImage,ROI(1),ROI(2),ROI(3),ROI(4),WaveDirection);
            obj.KnownWavelengthLines=MatchWavelength(x,y,centerWavelength,grating);         
            obj.KnownWavelengthLines=transpose(obj.KnownWavelengthLines);
        end
        
        function CalibrateWavelength(obj,KnownLines,WaveDirection)
            close all
            obj.WavelengthDirection=WaveDirection;
            obj.KnownWavelengthLines=KnownLines;
            
            f=figure;
            ax=axes;
            ScaledImage(f,ax,obj.WavelengthImage);
            ax.YLabel.String='Pixel';
            ax.XLabel.String='Pixel';
            
            title('Select region to calibrate for wavelength')
            [ROI,~]=DrawRectangle();
            obj.WavePolyFitCoeff=CalibrateWavelengthMatrix(obj.WavelengthImage,ROI,obj.KnownWavelengthLines,obj.WavelengthDirection);           
        
        end
        
        function DisplayCalibratedImage(obj,image)
        if isempty(obj.WavePolyFitCoeff)==1 || isempty(obj.TimePolyFitCoeff)==1
            error('Wavelength or Time Calibration not found')
        end
        PlotCalibratedImage(image,...
            obj.TimePolyFitCoeff,obj.WavePolyFitCoeff,obj.TimeDirection)  
        end
        
        function [x,y]=DisplayCalibratedLineout(obj,image,type,value,varargin)
            p=inputParser;
            addRequired(p,'image');
            addRequired(p,'type');
            addRequired(p,'value');
            addOptional(p,'Range',0,@isnumeric); %range is +/- in pixels.
            addOptional(p,'SelectPoints','off')
            parse(p,image,type,value,varargin{:});
            if p.Results.Range>0
                [x,y]=PlotCalibratedLineout(image,...
                    obj.TimePolyFitCoeff,obj.WavePolyFitCoeff,...
                    obj.TimeDirection, obj.WavelengthDirection,type,value,'Range',p.Results.Range);
            else
                [x,y]=PlotCalibratedLineout(image,...
                    obj.TimePolyFitCoeff,obj.WavePolyFitCoeff,...
                    obj.TimeDirection, obj.WavelengthDirection,type,value);
            end
            if strcmp(p.Results.SelectPoints,'on')==1
                hold on
                SelectPoints()
            end
        end
        
        function [PeakLocations,PeakWidths]=GetResolution(obj,x,y)
        [PeakLocations,PeakWidths]=Resolution(x,y,obj.KnownWavelengthLines);       
        end
        
    end
end