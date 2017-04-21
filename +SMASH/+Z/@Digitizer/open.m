function open(object)

if strcmpi(object.VISA.Status,'closed')
    fopen(object.VISA);
end

end