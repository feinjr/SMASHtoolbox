function mergePlots(haxes)

figure;
target=axes('Box','on');

N=numel(haxes);
color=lines(N);
for n=1:N
    hl=findobj(haxes(n),'Type','line');
    new=copyobj(hl,target);
    set(new,'Color',color(n,:));
end


end