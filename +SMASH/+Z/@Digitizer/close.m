function close(object)

if strcmpi(object.VISA.Status,'open')
    fclose(object.VISA);
end

end