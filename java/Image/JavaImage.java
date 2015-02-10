import java.util.Arrays;

public class JavaImage
{

// constructor
//public JavaImage()
//{      
//	// do nothing	
//}


/******************/
/* static methods */
/******************/

public static double[][] medianFilter(double[][] Data, int[] nhood)
{
	int height = Data.length;
	int width = Data[0].length;
	double[][] result = new double[height][width];
	int L = nhood[0]*nhood[1];
	double[] local = new double[L];
	double temp;
	
	for (int m=0; m<height; m++)
	{
		for (int n=0; n<height; n++)
		{
			for (int k=0; k<L; k++)
			{				
				//temp=Data[n*height+m];
			}
		}
	}
	
	return result;
}


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