function f=abel(y,F)
if ~ismonotonic(y)
    error('y input must be monotonic');
end
if y(1)>=0
    f=abelmain(y,F);
else
    y0i=find(y>=0,1,'first');
    yl=-flipRDM(y(1:y0i-1));
    yr=y(y0i:end);
    Fl=fliplr(F(:,1:y0i-1));
    Fr=F(:,y0i:end);
    fl=fliplr(abelmain(yl,Fl));
    fr=abelmain(yr,Fr);
    f=[fl,fr];
end
end

function f=abelmain(y,F)
np=length(y);
f=zeros(size(F));
dr=y(2)-y(1);
D=D2pt(np);
for k=1:size(F,1)
    f(k,:)=f(k,:)'+D*F(k,:)';
end
f=f/dr;
end

function D=D2pt(np)
D=zeros(np);
for i=1:np
    for j=1:np
        if j<i
            D(i,j)=0.0;
        elseif j==i
            D(i,j)=J(i,j);
        elseif j>i
            D(i,j)=J(i,j)-J(i,j-1);
        end
    end
end
end

function Jij=J(i,j)
if j<i
    Jij=0.0;
elseif j==0 && i==0
    Jij=2/pi;
elseif j>=i
    Jij=1/pi*log((((j+1)^2-i^2)^(1/2)+j+1)/...
        ((j^2-i^2)^(1/2)+j));
end
end