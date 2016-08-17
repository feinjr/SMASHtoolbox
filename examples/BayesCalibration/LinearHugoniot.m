function varargout = LinearHugoniot(object,x)

Us = x(1)+x(2).*object.Measurement.Grid;
varargout{1} = Us-object.Measurement.Data;



if nargout > 1
    %varargout{2} = diag(object.Measurement.Variance);
    varargout{2} = object.Measurement.Variance;
end


end