function data=object2structure(object)

field=properties(object);
data=struct();
for n=1:numel(field)
    data.(field{n})=object.(field{n});
end

end