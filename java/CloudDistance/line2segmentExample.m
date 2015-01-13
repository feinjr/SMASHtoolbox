clear all; clear java;
clc;

%% setup problem
point=[0 0;];
segment=2*rand(1,4)-1;
%segment=nan(5,4);
%segment(1,:)=[-0.5 1 0.5 0.75];
%segment(2,:)=[0.5 0.25 0.4 -0.25];
%segment(3,:)=[-0 -0.5 -1 0.25];
%segment(4,:)=[-0.75 0.5 0.75 0.5];
%segment(5,:)=[1 1.2 0.9 -1.2];

% order is important!
%theta=[0 180]; 
theta=[45 180-45]; % degrees
%theta=[45 -45];
%theta=[80 100];
ux=cosd(theta(1));
uy=sind(theta(1));
vx=cosd(theta(2));
vy=sind(theta(2));
direction=[ux uy vx vy];

%% call method
M=size(segment,1);
result=nan(2,M);

for m=1:M
    result(:,m)=javaMethod('intersectBound','CloudDistance',...
        point,segment(m,:),direction);
end

%% show results
plot(point(1),point(2),'ksq');
R=2;
for k=1:2
    x=point(1)+R*cosd(theta(k));
    y=point(2)+R*sind(theta(k));
    line([point(1) x],[point(2) y],'Color','k','LineStyle','--');
    x=point(1)-R*cosd(theta(k));
    y=point(2)-R*sind(theta(k));
    line([point(1) x],[point(2) y],'Color','k','LineStyle','--');
end

phi=linspace(theta(1),theta(2),100);
color=lines(M);
 for m=1:M
     line(segment(m,[1 3]),segment(m,[2 4]),...
         'Color',color(m,:),'Marker','none','LineWidth',2);
     line([point(1) result(1,m)],[point(2) result(2,m)],...
         'Color',color(m,:));
     L=hypot(point(1)-result(1,m),point(2)-result(2,m));     
     line(point(1)+L*cosd(phi),point(2)+L*sind(phi),...
         'Color',color(m,:),'LineStyle','--');
     line(point(2)-L*cosd(phi),point(2)-L*sind(phi),...
         'Color',color(m,:),'LineStyle','--');
 end

daspect([1 1 1]);
pbaspect([1 1 1]);

xlabel('X');
ylabel('Y');

figure(gcf);
set(gcf,'Units','inches','PaperPositionMode','auto',...
    'Position',[0 0 4 4],'PaperSize',[4 4]);
movegui(gcf,'northeast');

