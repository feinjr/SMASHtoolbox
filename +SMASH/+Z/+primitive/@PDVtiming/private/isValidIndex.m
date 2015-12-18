function result=isValidIndex(index)

result=false;
for n=1:numel(index)
    if SMASH.General.testNumber(index(n),'integer')
        continue
    else
        return
    end
end
result=true;

end