function user_input = binput(message_string)

binary_input_received=0;

while ~binary_input_received
    user_input=input(message_string);
    if isempty(user_input) || ~isnumeric(user_input) || ...
            ~isscalar(user_input) || (user_input~=1 && user_input~=0)
        disp('Message to user: your input must be a numeric scalar 1 or 0')
    elseif user_input==1 || user_input==0
        binary_input_received=1;
    end
end

end