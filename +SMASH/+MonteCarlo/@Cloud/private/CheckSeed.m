% CheckSeed : verify random number seed
%
% input converted to unsigned 32-bit integer
% numerical input converted directly
% text input converted in sequential 8-bit blocks

function value=CheckSeed(value)

if isnumeric(value)
        value=uint32(value(1));
    elseif ischar(value)
        byte=zeros(4,1);
        N=numel(value);
        for m=1:4:N
            stop=min(m+3,N);
            for n=m:stop
                index=n-m+1;
                byte(index)=byte(index)+double(value(n));
            end
        end
        byte=rem(byte,pow2(8));
        byte=dec2bin(byte,8);
        value=bin2dec([byte(1,:) byte(2,:) byte(3,:) byte(4,:)]);
        value=uint32(value);
    else
        error('ERROR: unable to use seed value');
end    
    
end