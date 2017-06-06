% close all
import SMASH.ImageAnalysis.Image

%%Clean Data
dfile='data_with_background_corrected.hdf';
wfile='hgne_corrected.hdf';
tfile='data_with_background_corrected.hdf';
d=Image(fullfile('\\snl','home','spatel','S1009830','Documents','ZShots','z3084','SVS5',dfile),'sydor');
data=d.Data;
w=Image(fullfile('\\snl','home','spatel','S1009830','Documents','ZShots','z3084','SVS5',wfile),'sydor');
wave=w.Data;
t=Image(fullfile('\\snl','home','spatel','S1009830','Documents','ZShots','z3084','SVS5',tfile),'sydor');
time=t.Data;
ImpulseTime=3008;
z3084_SVS5=Spectroscopy(data,wave,time);

%%
%temp=RotateImage(z3084_SVS5,'wavelength','all');
temp=z3084_SVS5.RotateImage('wavelength','all');

%z3084_SVS5.RotateImage(wave,'All');
%RotateImage(z3084_SVS5,wave,'All')
%%
z3084_SVS5.CalibrateTime(ImpulseTime,35,'X');
%%
z3084_SVS5.GetLampWavelengths(600,150,'Y');
%%
z3084_SVS5.CalibrateWavelength(z3084_SVS5.KnownWavelengthLines,'Y')
%%
z3084_SVS5.DisplayCalibratedImage(z3084_SVS5.DataImage);
%%
[x,y]=z3084_SVS5.DisplayCalibratedLineout(z3084_SVS5.DataImage,'AtWavelength',600);
%%
z3084_SVS5.DisplayCalibratedLineout(z3084_SVS5.DataImage,'AtTime',3100);
%%
z3084_SVS5.DisplayCalibratedLineout(z3084_SVS5.DataImage,'Select','Y');
%%
z3084_SVS5.DisplayCalibratedLineout(z3084_SVS5.DataImage,'AtTime',3100,'SelectPoints','on');

%%
%Messy Data
dfile='z3077_svs2.pff';
wfile='z3077_svs2.pff';
tfile='z3077_svs2.pff';
d=Image(fullfile('\\snl','home','spatel','S1009830','Documents','ZShots','z3077','SVS2',dfile),'film');
data=d.Data;
w=Image(fullfile('\\snl','home','spatel','S1009830','Documents','ZShots','z3077','SVS2',wfile),'film');
wave=w.Data;
t=Image(fullfile('\\snl','home','spatel','S1009830','Documents','ZShots','z3077','SVS2',tfile),'film');
time=t.Data;
ImpulseTime=2974;
z3077_svs2=Spectroscopy(data,wave,time);
%%
z3077_svs2.RotateImage(wave,'All');
%%
z3077_svs2.CalibrateTime(ImpulseTime,50,'X');
%%
z3077_svs2.KnownWavelengthLines=[543.5,457.9];
%%
z3077_svs2.CalibrateWavelength(z3077_svs2.KnownWavelengthLines,'Y')
%%
z3077_svs2.DisplayCalibratedImage(z3077_svs2.DataImage);