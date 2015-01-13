import java.util.Arrays;

public class CloudDistance
{
private int M,N; // M: number of clouds, N: points per cloud
public double[][] DataX,DataY; // cloud position data [MxN]
public double[][] Bound; // bound directions data [Mx4]
private int L; // L: number of segments (at least one less than number of curve points)
public double[][] Curve; // curve data [Lx2]
public double[][] Segment; // segment [(L-1)x4]
public double[][] Distance2,XIntersection,YIntersection; // intersection data [MxN]

// constructor
public CloudDistance()
{      
	//System.out.println("Creating Java object");		
}

// initialize method
private void initialize()
{
	int ValidSegments=0,kvalid=0;
	double P,Q,R,S;
	double[][] InitialSegment;			
	// process cloud data
	M=DataX.length;
	N=DataX[0].length;
	if ((M!=DataY.length) || (N!=DataY[0].length))
	{
		System.out.println("ERROR: inconsistent cloud arrays");
		return;
	}
	M=DataX.length;
	N=DataX[0].length;	
	// process curve data
	if (Curve[0].length!=2)
	{
		System.out.println("ERROR: curve array must have two columns [x y]");
		return;
	}
	L=Curve.length-1;
	InitialSegment=new double[L][4];
	for (int k=0; k<L; k++)
	{
		P=Curve[k][0];
		Q=Curve[k][1];
		R=Curve[k+1][0];
		S=Curve[k+1][1];
		if (Double.isNaN(P) || Double.isNaN(Q) || Double.isNaN(R) || Double.isNaN(S))
		{
			continue;
		}
		InitialSegment[kvalid][0]=P;
		InitialSegment[kvalid][1]=Q;
		InitialSegment[kvalid][2]=R;
		InitialSegment[kvalid][3]=S;
		kvalid++;
	}
	Segment=new double[kvalid][4];
	L=kvalid+1;
	for (int k=0; k<kvalid; k++)
	{
		Segment[k][0]=InitialSegment[k][0];
		Segment[k][1]=InitialSegment[k][1];
		Segment[k][2]=InitialSegment[k][2];
		Segment[k][3]=InitialSegment[k][3];
	}
	// allocate output arrays
	Distance2=new double[M][N];
	XIntersection=new double[M][N];
	YIntersection=new double[M][N];
}

// calculate method
public void calculate()
{
	double[] LocalPoint = new double[2];
	double[] LocalSegment = new double[4];
	double[] LocalBound = new double[4];
	double[] Intersection = new double[2]; 
	double[] BestIntersection = new double[2];
	double L2,BestL2;	
	initialize(); // test inputs and set up outputs
	for (int m=0; m<M; m++) // m: cloud index
	{
		// Bound limit vectors (externally normalized)		
		LocalBound[0]=Bound[m][0];
		LocalBound[1]=Bound[m][1];
		LocalBound[2]=Bound[m][2];
		LocalBound[3]=Bound[m][3];						
		for (int n=0; n<N; n++) // n: point index
		{
			// cloud point
			LocalPoint[0]=DataX[m][n];
			LocalPoint[1]=DataY[m][n];
			BestL2=Double.POSITIVE_INFINITY;
			BestIntersection[0]=Double.NaN;
			BestIntersection[1]=Double.NaN;
			for (int k=0; k<(L-1); k++) // k: segment index
			{							
				// segment positions
				LocalSegment[0]=Segment[k][0];
				LocalSegment[1]=Segment[k][1];
				LocalSegment[2]=Segment[k][2];
				LocalSegment[3]=Segment[k][3];	
				Intersection=intersectBound(LocalPoint,LocalSegment,LocalBound);
				if (Double.isNaN(Intersection[0])) {continue;}
				L2=squareDistance(LocalPoint,Intersection);
				if (L2>=BestL2) {continue;}	
				BestL2=L2;
				BestIntersection[0]=Intersection[0];
				BestIntersection[1]=Intersection[1];				
			}
			// store results
			Distance2[m][n]=BestL2;
			XIntersection[m][n]=BestIntersection[0];
			YIntersection[m][n]=BestIntersection[1];
		}
	}
}

/******************/
/* static methods */
/******************/

public static double squareDistance(double[] A, double[] B)
{
/* square distance

L2=squareDistance(PointA,PointB)

PointA: [XA YA]
PointB: [XB YB]

L2: positive scalar

*/
	double L2=0;
	double[] Delta = new double[2];
	for (int k=0; k<2; k++)
	{
		Delta[k]=A[k]-B[k];
		L2=L2+Delta[k]*Delta[k];
	}
	return L2;
}

public static double[] lookup(double[] Segment, double gamma)
{
/* look up point inside a line segment

Point=lookup(Segment,gamma);

Segment: [XP YP XQ YQ]
gamma: scalar between 0 and 1 (inclusive)

Point: [X Y]

*/
	double[] u = new double[2]; // Segment vector
	double[] NewPoint = new double[2]; // lookup coordinates
	u[0]=Segment[2]-Segment[0];
	u[1]=Segment[3]-Segment[1];	
	NewPoint[0]=Segment[0]+gamma*u[0];
	NewPoint[1]=Segment[1]+gamma*u[1];
	return NewPoint; 
}

public static double project(double[] Point, double[] Segment, double[] Direction)
{
/* calculate projection from a point to a line segment along a specified direction

gamma=project(Point,Segment,Direction);

Point: [X Y]
Segment: [XP YP XQ YQ]
Direction: [ux uy]

gamma: scalar between 0 and 1 (inclusive)

*/
	double gamma;
	double[] u = new double[2]; // Segment vector
	double[] v = new double[2]; // Segment to Point vector
	double[] NewPoint = new double[2];
	// calculate vector components
	u[0]=Segment[2]-Segment[0];
	u[1]=Segment[3]-Segment[1];
	v[0]=Point[0]-Segment[0];
	v[1]=Point[1]-Segment[1];
	gamma=(v[0]*Direction[1]-v[1]*Direction[0])/(u[0]*Direction[1]-u[1]*Direction[0]);
	return gamma;	
}

public static double validGamma(double gamma)
{
/* force valid gamma value

gamma=validGamma(gamma);

*/
	if (gamma<0) {gamma=0;}
	else if (gamma>1) {gamma=1;}
	return gamma;
}

public static double[] intersectFree(double[] Point, double[] Segment)
{
/* find shortest intersection between a point and a line segment

result=intersectFree(Point,Segment);

Point: [X Y]
Segment: [XP YP XQ YQ]

result: [Xintersect Yintersect]

*/
	double gamma;	
	double[] u = new double[2]; // Segment vector
	double[] v = new double[2]; // Segment to Point vector
	double[] result = new double[2]; // intersection coordinates and square distance
	// calculate vector components
	u[0]=Segment[2]-Segment[0];
	u[1]=Segment[3]-Segment[1];
	v[0]=Point[0]-Segment[0];
	v[1]=Point[1]-Segment[1];
	// determine gamma
	gamma=(u[0]*v[0]+u[1]*v[1])/(u[0]*u[0]+u[1]*u[1]);
	gamma=validGamma(gamma);
	// determine nearest point and square distance
	result[0]=Segment[0]+gamma*u[0];
	result[1]=Segment[1]+gamma*u[1];	
	return result;
}

public static double[] intersectBound(double[] Point, double[] Segment, double Bound[])
{
/* determine shortest intersection between a point and a line segment within a pair of bounding vectors

result=intersectBound(Point,Segment,Bound);

Point: [X Y]
Segment: [XP YP XQ YQ]
Bound: [ux uy vx vy]

result: [Xintersect Yintersect]

*/
	double gamma;
	double[] u = new double[2]; // boundary vector
	double[] v = new double[2]; // boundary vector
	double[] w = new double[2]; // point to segment vector
	double crossA, crossB; // cross product z-components
	double alpha, beta; // decomposition parameters
	double[] GammaArray = new double[4];
	double[] NewPoint = new double[2];
	double[] NewSegment = new double[4];
	double L2, L2previous; // square distance
	double[] result = new double[2]; // intersection coordinates
	// extract boundary vectors
	u[0]=Bound[0];
	u[1]=Bound[1];
	v[0]=Bound[2];
	v[1]=Bound[3];
	// pick appropriate calculation
	if ((u[0] == v[0]) && (u[1] == v[1]))
	{
		//System.out.println("Case A");
		gamma=project(Point,Segment,u);
		gamma=validGamma(gamma);		
		result=lookup(Segment,gamma);
	}
	else if ((u[0] == -v[0]) && (u[1] == -v[1]))
	{
		//System.out.println("Case B");
		result=intersectFree(Point,Segment);	
	}
	else
	{	
		//System.out.println("Case C");	
		// test first segment bound	
		w[0]=Segment[0]-Point[0];
		w[1]=Segment[1]-Point[1];	 	
		alpha=(w[0]*v[1]-w[1]*v[0])/(u[0]*v[1]-u[1]*v[0]); // (w x v) / (u x v)
		beta= (w[0]*u[1]-w[1]*u[0])/(v[0]*u[1]-v[1]*u[0]); // (w x u) / (v x u)
		if (alpha*beta >= 0) {GammaArray[0]=0;}
		else {GammaArray[0]=Double.NaN;}	 	
		// test second segment bound	
		w[0]=Segment[2]-Point[0];
		w[1]=Segment[3]-Point[1];
		alpha=(w[0]*v[1]-w[1]*v[0])/(u[0]*v[1]-u[1]*v[0]); // (w x v) / (u x v)
		beta= (w[0]*u[1]-w[1]*u[0])/(v[0]*u[1]-v[1]*u[0]); // (w x u) / (v x u)
		if (alpha*beta >= 0) {GammaArray[1]=1;}
		else {GammaArray[1]=Double.NaN;}	 			
		//test limit projections
		gamma=project(Point,Segment,u);	
		if (gamma == validGamma(gamma)) {GammaArray[2]=gamma;}
		else {GammaArray[2]=Double.NaN;}
		gamma=project(Point,Segment,v);
		if (gamma == validGamma(gamma)) {GammaArray[3]=gamma;}
		else {GammaArray[3]=Double.NaN;}
		//for (int k=0; k<4; k++){System.out.println(GammaArray[k]);}
		// process allowed line segment(s)		
		Arrays.sort(GammaArray);		
		result[0]=Double.NaN;
		result[1]=Double.NaN;
		L2=Double.POSITIVE_INFINITY;
		L2previous=L2;
		for (int k=0; k<4; k=k+2)
		{
			if (Double.isNaN(GammaArray[k])) {break;}
			{
				NewPoint=lookup(Segment,GammaArray[k]);			
				NewSegment[0]=NewPoint[0];
				NewSegment[1]=NewPoint[1];
				NewPoint=lookup(Segment,GammaArray[k+1]);
				NewSegment[2]=NewPoint[0];
				NewSegment[3]=NewPoint[1];
				NewPoint=intersectFree(Point,NewSegment);
				L2=squareDistance(Point,NewPoint);
				if (L2<L2previous)
				{
					result=NewPoint;
					L2previous=L2;
				}								
			}
		}	
	}
	return result;
}

}