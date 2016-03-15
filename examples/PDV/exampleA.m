%% create PDV object
assert(exist('exampleA.txt','file')==2,...
    'ERROR: unable to find signal file.  Try running GenerateSignals function first');

object=SMASH.Velocimetry.PDV('exampleA.txt','column');
object=configure(object,'Window','hann');
object=preview(object,'Duration',[5e-9 1e-9]);
preview(object);

duration=2e-9;
skip=0.1e-9;

%% define bounds
manual=false;
if manual
    object=bound(object);
else
    previous=SMASH.FileAccess.readFile(...
        'PreviousBoundary.sda','sda','manual selection');
    object=bound(object,'add',previous);
end

%% power analysis
object=configure(object,'Window','Hann','Duration',[duration*(0.58/0.34) skip]);

tic
object=analyze(object,'power');
toc;
result1=split(object.Frequency{1});

result1=scale(result1,1e9);
result1=result1/1e9;

%% sinusoid analysis
object=configure(object,'Duration',[duration skip]);

tic;
object=analyze(object,'sinusoid');
toc;
result2=split(object.Frequency{1});

result2=scale(result2,1e9);
result2=result2/1e9;

%% compare results
figure;
result1.GraphicOptions.LineColor='b';
result2.GraphicOptions.LineColor='r';

view(result1,gca);
view(result2,gca);
xlabel('Time (ns)');
ylabel('Beat frequency (GHz)');

source=SMASH.FileAccess.readFile('VelocityProfile.txt','column');
beat=1e9+2*source.Data(:,2)/1550e-9;
line(source.Data(:,1)*1e9,beat/1e9,'Color','k');

legend('centroid','sinusoid','source');

temp=object.Boundary{1};
line(temp.Data(:,1)*1e9,temp.Data(:,2)/1e9,'Color','m','Marker','o');

%%
%fs=(numel(time)-1)/(time(end)-time(1));
%tau=duration;
%uncertainty=sqrt(6/fs/tau^3)*sigma/pi;
%uncertainty=uncertainty/1e9;
%fprintf('Limiting uncertainty: %#.1g GHz\n',uncertainty);

%temp=regrid(result1,result2.Grid);
%view(temp-result2);
%xlabel('Time (ns)')
%ylabel('Difference (GHz)');

%line(xlim,repmat(uncertainty,[1 2]),'Color','k','LineStyle','--');
%line(xlim,repmat(-uncertainty,[1 2]),'Color','k','LineStyle','--');