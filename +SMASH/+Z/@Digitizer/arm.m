function arm(object)

%%
if numel(object) > 1
    for k=1:numel(object)
        arm(object(k));
    end
    return
end

%%
fopen(object.VISA);
fwrite(object.VISA,':ADER?'); % clear Acquisition Done Event Register

fwrite(object.VISA,':single');
fprintf('Waiting for trigger...');
while true
    fwrite(object.VISA,':ADER?');
    done=fscanf(object.VISA,'%d');
    if done
        break
    else
        pause(0.1);
    end
end
fprintf('done\n');

fclose(object.VISA);


end