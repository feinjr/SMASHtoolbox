function result=findPeak(f,P,width,varargin)

% manage input (eventually accept input options)
mode='centroid';
threshold=max(P)*0.50;

% perform peak analysis
switch lower(mode)
    case 'centroid'
        weight=P;
        weight(weight<threshold)=0;
        area=trapz(f,weight);
        weight=weight/area;
        center=trapz(f,weight.*f);
        if isempty(width)
            width=trapz(f,weight.*(f-center).^2);
            width=sqrt(width);
        end
        %amplitude=interp1(f,P,center,'linear');
        weight(abs(f-center) > width)=0;
        amplitude=trapz(f,weight.*P);
        result.Center=center;
        result.Width=width;
        result.Amplitude=amplitude;
    otherwise
        error('ERROR: invalid spectrum analysis mode');
end

end           