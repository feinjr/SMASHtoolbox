   function [x,y]=DisplayCalibratedLineout(obj,image,type,value,varargin)
            %The DisplayCalibratedLineout method allows the user to take
            %lineouts by inputing several optional values.
            %Example: DisplayCalibratedLineout(dataImage,'AtTime',3000),
            %takes a lineout at 3000ns across all wavelengths.
            %
            %Example: DisplayCalibratedLineout(dataImage,'AtWavelength',600),
            %takes a lineout at 600nm across time.
            %
            %Example: DisplayCalibratedLineout(dataImage,'Select','X'),
            %prompts the user to a select a region for the lineout, and
            %plots the linoeut based on the inputed direction.
            %
            %If 'SelectPoints','on' is also inputed then the user will be
            %able to click a point on the lineout and add a label.
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