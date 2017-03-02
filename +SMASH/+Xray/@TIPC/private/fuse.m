function [ Ifuse ] = fuse( I,J )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

Ifuse = zeros(size(I,1),size(I,2),3);

Iscaled = (I - min(I(:)))/(max(I(:)) - min(I(:)));
Jscaled = (J - min(J(:)))/(max(J(:)) - min(J(:)));

Ifuse(:,:,1) = Iscaled/0.2989;
Ifuse(:,:,2) = Jscaled/0.5870;

end

