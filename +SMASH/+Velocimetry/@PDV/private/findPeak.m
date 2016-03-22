function [center,amplitude]=findPeak(f,P,varargin)

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
        amplitude=interp1(f,P,center,'linear');
    otherwise
        error('ERROR: invalid spectrum analysis mode');
end

end           