import java.util.Arrays;

public class CloudDistanceFast
{
public double[][] DataX,DataY; // cloud position data [MxN]
public double[][] Bound; // bound directions data [Mx4]
public double[][] Curve; // curve data [Lx2]
public double[][] Distance2,XIntersection,YIntersection; // intersection data [MxN]

// constructor
public CloudDistanceFast()
{      
	//System.out.println("Creating Java object");		
}

// calculate method
public void calculate()
{
	int M=DataX.length; // number of clouds
	int N=DataX[0].length; // points per cloud
	int L=Curve.length; // number of curve points 
	double ux,uy,vx,vy; // bound vectors
	double X,Y; // cloud point
	double XP,YP,XQ,YQ; // segment points
	double XR,YR,dx,dy; // segment references	
	double gx,gy,hx,hy; // point to segment vectors
	double gamma; // segment distance parameter
	double alpha,beta; // decomposition parameters
	double[] GammaArray = new double[4]; 
	double dxnew,dynew; // revised segment references
	double Xint,Yint,L2; // intersection variables
	double Xnew,Ynew,L2new; // temporary intersection variables
	double Xbest,Ybest,L2best; // best intersection variables
	
	Distance2=new double[M][N];
	XIntersection=new double[M][N];
	YIntersection=new double[M][N];
		
	for (int m=0; m<M; m++) // cloud index
	{	
		// Bound limit vectors (externally normalized)		
		ux=Bound[m][0];
		uy=Bound[m][1];
		vx=Bound[m][2];
		vy=Bound[m][3];	
		for (int n=0; n<N; n++) // point index
		{
			X=DataX[m][n];
			Y=DataY[m][n];
			Xbest=Double.NaN;
			Ybest=Double.NaN;
			L2best=Double.POSITIVE_INFINITY;
			for (int k=0; k<(L-1); k++) // segment index
			{
				// verify segment
				XP=Curve[k][0];
				YP=Curve[k][1];
				if (Double.isNaN(XP) || Double.isNaN(YP)) {continue;}
				XQ=Curve[k+1][0];
				YQ=Curve[k+1][1];
				if (Double.isNaN(XQ) || Double.isNaN(YQ)) {continue;}
				// reference point and vector
				XR=XP;
				YR=YP;			
				dx=XQ-XP;
				dy=YQ-YP;			
				// find nearest allowed intersection
				if ((ux == vx) && (uy == vy)) // single direction
				{
					gx=XP-X;
					gy=YP-Y;
					gamma=-(gx*uy-gy*ux)/(dx*uy-dy*ux);
					if ((gamma<0) || (gamma>1))
					{
						Xint=Double.NaN;
						Yint=Double.NaN;
						L2=Double.POSITIVE_INFINITY;
					}
					else
					{
						Xint=XR+gamma*dx;
						Yint=YR+gamma*dy;
						L2=(Xint-X)*(Xint-X)+(Yint-Y)*(Yint-Y);
					}
				}
				else if ((ux == -vx) && (uy == -vy)) // all directions
				{
					gx=XP-X;
					gy=YP-Y;
					gamma=-(gx*dx+gy*dy)/(dx*dx+dy*dy);
					if (gamma<0) {gamma=0;}
					else if (gamma>1) {gamma=1;}
					Xint=XR+gamma*dx;
					Yint=YR+gamma*dy;
					L2=(Xint-X)*(Xint-X)+(Yint-Y)*(Yint-Y);						
				}
				else // limited directions
				{				
					// test first segment boundary
					gx=XP-X;
					gy=YP-Y;
					alpha=(gx*vy-gy*vx)/(ux*vy-uy*vx);
					beta= (gx*uy-gy*ux)/(vx*uy-vy*ux);
					if (alpha*beta >= 0) {GammaArray[0]=0;}
					else {GammaArray[0]=Double.NaN;}	 
					// test second segment boundary
					hx=XQ-X;
					hy=YQ-Y;
					alpha=(hx*vy-hy*vx)/(ux*vy-uy*vx);
					beta= (hx*uy-hy*ux)/(vx*uy-vy*ux);
					if (alpha*beta >= 0) {GammaArray[1]=1;}
					else {GammaArray[1]=Double.NaN;}	 
					// test limit projections
					gamma=-(gx*uy-gy*ux)/(dx*uy+dy*ux);
					if ((gamma>=0) && (gamma<=1)) {GammaArray[2]=gamma;}
					else {GammaArray[2]=Double.NaN;}
					gamma=-(gx*vy-gy*vx)/(dx*vy+dy*vx);
					if ((gamma>=0) && (gamma<=1)) {GammaArray[3]=gamma;}
					else {GammaArray[3]=Double.NaN;}					
					// analyze sorted gamma array
					Arrays.sort(GammaArray);				
					Xint=Double.NaN;
					Yint=Double.NaN;
					L2=Double.POSITIVE_INFINITY;
					for (int j=0; j<4; j=j+2) // sub-segment index
					{
						if (Double.isNaN(GammaArray[j])) {break;}
						XP=XR+GammaArray[j]*dx;
						YP=YR+GammaArray[j]*dy;
						XQ=XR+GammaArray[j+1]*dx;
						YQ=YR+GammaArray[j+1]*dy;
						gx=XP-X;
						gy=YP-Y;
						dxnew=XQ-XP;
						dynew=YQ-YP;
						gamma=-(gx*dxnew+gy*dynew)/(dxnew*dxnew+dynew*dynew);
						if (gamma<0) {gamma=0;}
						else if (gamma>1) {gamma=1;}
						Xnew=XP+gamma*dxnew;
						Ynew=YP+gamma*dynew;
						L2new=(Xnew-X)*(Xnew-X)+(Ynew-Y)*(Ynew-Y);
						if (L2new<L2)
						{
							Xint=Xnew;
							Yint=Ynew;
							L2=L2new;
						}
					}
				}
				// compare intersection with previous best
				if (L2<L2best)
				{
					Xbest=Xint;
					Ybest=Yint;
					L2best=L2;
				}
			}
			// store results
			Distance2[m][n]=L2best;
			XIntersection[m][n]=Xbest;
			YIntersection[m][n]=Ybest;
		}
	}				
}

}