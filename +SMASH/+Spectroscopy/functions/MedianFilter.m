function MedianBackground=MedianFilter(x,y,order)
    if mod(order,2) == 0
        order=order+1; %force odd order
    end
    MedianBackground=zeros(length(x),1);
    for i=1:1:length(x)
        first=i-((order-1)/2.0);
        first_append=[];
        last_append=[];
        if first<1
            first_mean=mean(y(1:5)); %average first five values
            first_append=ones(abs(first),1)*first_mean;
            first=1;
        end
        last=i+((order-1)/2.0);
        if last>length(x)
            last_mean=mean(y(length(x)-5:length(x)));
            last_append=ones(abs(last)-length(x),1)*last_mean;  %average last five values
            last=length(x);
        end
        y=y(:);
        first=[first_append;y(first:last);last_append];
        MedianBackground(i)=median(first);
    end
end