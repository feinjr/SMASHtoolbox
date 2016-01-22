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
            plot(X,evaluate(object.Settings.Fit,X),'Color','r','LineWidth',2,'LineStyle','--')
            plot(X,object.Settings.FinalSignal.Data,'Color','b')
            
            xlabel('Time [s]')
            ylabel('Normalized Signal')
            title(sprintf('Measured Signal and Fit: %s',object.Settings.Location))
            
            legend(sprintf('Fit: T_i = %3.2f keV',T),'Measured','Location','NorthEast');
    end
end

if nargout>=1
    varargout{1}=h;
end

end

