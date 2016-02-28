function object=setupSlackFunction(object)



if all(isinf(span))
    object.SlackFunction{index}=@(q) p0+q;
    q0=0;
elseif isinf(span(1))
    object.SlackFunction{index}=@(q) span(2) - q.^2;
    q0=sqrt(span(2)-p0);
elseif isinf(span(2))
    object.SlackFunction{index}=@(q) span(1) + q.^2;
    q0=sqrt(p0-span(1));
else
    L=(span(2)-span(1))/2;
    pmid=(span(2)+span(1))/2;
    qmid=-asin((p0-pmid)/L);
    object.SlackFunction{index}=@(q) pmid+L*sin(q-qmid);
    q0=0;
end
object.SlackVariables(index)=q0;

 object.SlackFunction=cell([object.NumberParameters 1]);
            for n=1:object.NumberParameters
                object.SlackFunction{n}=@(q) guess(n)+q;
            end


end