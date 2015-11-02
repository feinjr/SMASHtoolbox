function object=calculateInverses(object)

table=nan(object.NumberClouds,3);
for k=1:object.NumberClouds
    sigmax2=object.CloudData{k}.Moments(1,2);
    sigmay2=object.CloudData{k}.Moments(2,2);
    sigmaxy=object.CloudData{k}.Correlations(2,1)*sqrt(sigmax2*sigmay2);
    matrix=[sigmax2 sigmaxy; sigmaxy sigmay2];
    Q=pinv(matrix);
    table(k,:)=[Q(1,1) (Q(1,2)+Q(2,1))/2 Q(2,2)]; % [a bc d]
end

object.InverseElements=table;

end