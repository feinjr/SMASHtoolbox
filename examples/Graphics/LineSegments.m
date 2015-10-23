%% basic demonstration
figure;
points=[0.2 0.2; 0.5 0.9; 0.75 0.9; 0.8 0.3;];
object=SMASH.Graphics.LineSegments(points);

N=25;
origin=rand(N,2);
%matrix=eye(2);
matrix=[1 0.5;0.5 1];

ha(1)=subplot(2,2,1);
object.BoundaryType='projected';
view(object,gca);
[~,location]=calculateDistance(object,origin,matrix);
for n=1:N
    line([location(n,1) origin(n,1)],[location(n,2) origin(n,2)],...
        'Marker','*');
end
axis image
title('Extend boundaries');

ha(2)=subplot(2,2,2);
object.BoundaryType='closed';
view(object,gca);
[~,location]=calculateDistance(object,origin,matrix);
for n=1:N
    line([location(n,1) origin(n,1)],[location(n,2) origin(n,2)],...
        'Marker','*');
end
axis image
title('Closed boundaries');

ha(3)=subplot(2,2,3.5);
object.BoundaryType='wrapped';
view(object,gca);
[~,location]=calculateDistance(object,origin,matrix);
for n=1:N
    line([location(n,1) origin(n,1)],[location(n,2) origin(n,2)],...
        'Marker','*');
end
axis image
title('Wrapped boundaries');

linkaxes(ha,'xy');
xlim([0 1]);
ylim([0 1]);

%% timing demonstration
Nsegments=1000;
object=SMASH.Graphics.LineSegments(rand(Nsegments+1,2));

Npoints=1e4;
origin=randn(Npoints,2);
tic;
[D2,location]=calculateDistance(object,origin);
total=toc;
fprintf('Calculation time: %#.3g seconds\n',total);
fprintf('Time per point per segment: %#.3g seconds\n',...
    total/Nsegments/Npoints);
