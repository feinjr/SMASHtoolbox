% getLabel : sets the labels
%
% created 10/19/2016  by Paul Specht
%
%
% This function sets the labels for the VISAR view method

function Label=getLabel(object,label,type)
if type < 2
    %determine the number of signals
    N=object.Measurement.NumberSignals;
    if N > 3
        l={['D1A-',object.Label],['D1B-',object.Label],['D2A-',object.Label],['D2B-',object.Label]};
    elseif N > 2
        l={['D1-',object.Label],['D2-',object.Label],['BIM-',object.Label]};
    else
        l={['D1-',object.Label],['D2-',object.Label]};
    end
elseif type == 2
    l={['Lissajou-',object.Label]};
elseif type == 3
    l={['DX-',object.Label],['DY-',object.Label]};
elseif type > 3
    l={object.Label};
end
Label=[label,l];
end