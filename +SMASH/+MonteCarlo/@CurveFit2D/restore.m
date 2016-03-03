function object=restore(data)

object=SMASH.MonteCarlo.CurveFit2D('-empty');
name=fieldnames(data);
for n=1:numel(name)
    if isprop(object,name{n})
        object.(name{n})=data.(name{n});
    end
end

end