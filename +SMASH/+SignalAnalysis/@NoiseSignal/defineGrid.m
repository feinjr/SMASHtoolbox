function object=defineGrid(object,Grid)

% manage input
assert(nargin==2,'ERROR: invalid number of inputs');
assert(isnumeric(Grid),'ERROR: invalid Grid');
Grid=sort(Grid(:));
Data=nan(size(Grid));
object.Measurement=reset(object.Measurement,Grid,Data);

N=numel(Grid);
spacing=(Grid(end)-Grid(1))/(N-1);
N2=pow2(nextpow2(N));

object.Npoints=N;
object.Npoints2=N2;

object.ReciprocalGrid=(-N2/2):(+N2/2-1);
object.ReciprocalGrid=object.ReciprocalGrid(:)/(N2*spacing);
object.NyquistValue=abs(object.ReciprocalGrid(1));
object.ReciprocalGrid=fftshift(object.ReciprocalGrid);

end