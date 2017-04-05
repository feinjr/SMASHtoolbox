function varargout = viewproperties( object,varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Narg=numel(varargin);

if Narg == 0
   view(object.Measurement) 
elseif Narg == 1
    switch varargin{1}
        case 'InstrumentResponse'
            obj = object.Settings.InstrumentResponse;
            obj.GridLabel = 'Time [ns]';
            obj.DataLabel = 'Response';
            obj.GraphicOptions.Title = 'Instrument Response Function';
            view(obj)
        case 'LightOutput'
            obj = object.Settings.LightOutput;
            obj.GridLabel = 'Neutron Energy [MeV]';
            obj.DataLabel = 'Relative Light Yield';
            obj.GraphicOptions.Title = 'Scintillator Light Output';
            view(obj)
        case 'Fit'
            X = object.Settings.FinalSignal.Grid;
            T = object.Settings.Fit.Parameter{1}(2);
            figure
            hold all
            plot(X,object.Settings.FinalSignal.Data)
            fitsignal = crop(object.Settings.FinalSignal,[object.Settings.FitLimits(1),object.Settings.FitLimits(2)]);
            hl1 = plot(fitsignal.Grid, fitsignal.Data,'LineWidth',3);
            hl2 = plot(X,evaluate(object.Settings.Fit,X),'Color','k','LineWidth',2,'LineStyle','--');
            
            xlabel('Time [s]')
            ylabel('Normalized Signal')
            title(sprintf('Measured Signal and Fit: %s',object.Settings.Location))
            
            legend([hl1, hl2],'Measured',sprintf('Fit: T_i = %3.2f keV',T),'Location','NorthEast');
    end
end

if nargout>=1
    varargout{1}=gca;
end

end

