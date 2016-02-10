function width=KernelWidth(data)

N=numel(data);

temp=sort(data);
IQR=temp(round(0.75*N))-temp(round(0.25*N));
h=2*IQR/N^(1/3); % Freedman-Diaconis rule for ideal histogram bin width
%h=4*h; % stretch the kernel over several bins
%h=2*h;
%width=repmat(h,size(data));

width=h;

end