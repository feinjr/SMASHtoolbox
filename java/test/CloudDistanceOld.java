// CloudDistance class (for use with MATLAB)
public class CloudDistanceOld
{
protected boolean OutputReady=false; 
protected int NumberClouds=0, CloudSize=0; // cloud array sizes
protected double[][] XCloud, YCloud;
protected int DirectionSize=0; // direction array size
protected double[][] DirectionX, DirectionY;
protected double[][] Distance2, XIntersect, YIntersect; 
protected int CurveSize=0; // curve array size
protected double[] XCurve, YCurve; 

// constructor
	public CloudDistanceOld()
	{      
	System.out.println("Creating Java object");	  	  
	}
// summarize method
	public void summarize()
	{
		System.out.println("Object summary:");
		if ((NumberClouds==0) || (CloudSize==0))
		{
			System.out.println("\tNo clouds defined");
		}
		else
		{
			System.out.println("\t" + NumberClouds + " clouds defined with " + CloudSize + " points per cloud");
		}
		if (DirectionSize==0)
		{
			System.out.println("\tNo directions defined");
		}
		else
		{
			System.out.println("\tUp to " + DirectionSize + " directions defined per cloud");
		}
		{
		}
		if (CurveSize==0)
		{
			System.out.println("\tNo curve points defined");
		}
		else
		{
			System.out.println("\t" + CurveSize + " curve points defined");
		}
		if (OutputReady)
		{
			System.out.println("\tCloud-curve intersections found");
		}
		else
		{
			System.out.println("\tCloud-curve intersections not found");
		}
	}
// defineCloud method
	public void defineCloud(double[][] x, double[][] y)
	{
	if ((x.length != y.length) || (x[0].length != y[0].length))
	{
		System.out.println("ERROR: incompatible cloud arrays");
		return;
	} 
	NumberClouds=x.length;
	CloudSize=x[0].length;	
	XCloud=x;
	YCloud=y;	
	Distance2=new double[NumberClouds][CloudSize];
	XIntersect=new double[NumberClouds][CloudSize];
	YIntersect=new double[NumberClouds][CloudSize];
	OutputReady=false;
	if ((DirectionSize>0) && (DirectionX.length != NumberClouds))
	{
		DirectionX=null;
		DirectionY=null;
	}
	}	
// defineDirections method
	public void defineDirection(double[][] wx, double[][] wy)
	{
		if (NumberClouds==0)
		{
			System.out.println("ERROR: cloud not defined yet");
			return;
		}
		else if (wx.length != wy.length)
		{
			System.out.println("ERROR: incompatible direction arrays");
			return;
		}
		else if (wx.length!=NumberClouds)
		{
			System.out.println("ERROR: direction arrays not compatible with cloud array");
			return;
		}
		DirectionSize=wx[0].length;
		DirectionX=wx;
		DirectionY=wy;
		OutputReady=false;
	}
// defineCurve method
	public void defineCurve(double[] x, double[] y)
	{
	if (x.length != y.length)
	{
		System.out.println("ERROR: incompatible curve arrays");
		return;
	}
	CurveSize=x.length;
	XCurve=x;
	YCurve=y;
	OutputReady=false;	
	}	
// findNearestAllowedIntersection method  
  public void findNearestAllowedIntersection()
  {
  	double X,Y; // cloud point
  	double wx,wy; // allowed direction components
  	double pA,pB,qA,qB; // curve segment boundaries 	
  	double Dp,Dq,Dx,Dy; 
  	double uxA,uxB,vyA,vyB; // segment boundary directions
	double L,gamma,x,y; // segment intersection
	double L2,L2new,xnew,ynew;
	//double A,B,C,D; // generic variables
  	if ((NumberClouds==0) || (CloudSize==0) || (DirectionSize==0))
  	{
  		System.out.println("ERROR: input not ready");
  		return;
  	}
  	System.out.println("Determining nearest allowed intersections");
  	for (int cloud=0; cloud<NumberClouds; ++cloud)
  	{
  		for (int point=0; point<CloudSize; ++point)
  		{
  			L2=Double.POSITIVE_INFINITY;
  			X=XCloud[cloud][point];
  			Y=YCloud[cloud][point];
  			xnew=XCurve[0];
  			ynew=YCurve[0];
  			for (int segment=0; segment<(CurveSize-1); ++segment)
  			{
  				pA=XCurve[segment];
  				pB=XCurve[segment+1];
  				if (isnan(pA) || isnan(pB))
  				{
  					continue;
  				}  	
  				Dp=pB-pA;
  				qA=YCurve[segment];  
  				qB=YCurve[segment+1];
  				if (isnan(qA) || isnan(qB))
  				{
  					continue;
  				}  				
  				Dq=qB-qA;
  				for (int direction=0; direction<DirectionSize; ++direction)
  				{  					 				
  					wx=DirectionX[cloud][direction];
  					wy=DirectionY[cloud][direction];
  					Dx=X-pA;
  					Dy=Y-qA;
  					gamma=(Dx*wy-Dy*wx)/(Dp*wy-Dq*wx);  					
  					if ((gamma>=0) && (gamma<=1))
  					{  	  									
	  					L=(Dy*Dp-Dx*Dq)/(Dq*wx-Dp*wy);
  						L2new=L*L;  					  						
  						if (L2new < L2)
  						{  	  			  														
  							L2=L2new;
  							xnew=X+L*wx;
  							ynew=Y+L*wy;  						
  						}   					  											
  					}  					 					 					  					
  				}
  			} 			
  			Distance2[cloud][point]=L2;
  			XIntersect[cloud][point]=xnew;
  			YIntersect[cloud][point]=ynew;  			
 			  		
  		}
  	}  	  	
  	OutputReady=true;
  } 
  // findNearestIntersection method  
  public void findNearestIntersection()
  {
  	double X,Y; // cloud point
  	double pA,pB,qA,qB; // curve segment boundaries 	
  	double Dp,Dq,Dx,Dy; 
  	double uxA,uxB,vyA,vyB; // segment boundary directions
	double L,gamma,x,y; // segment intersection
	double L2,L2new,xnew,ynew;
	//double A,B,C,D; // generic variables
  	if ((NumberClouds==0) || (CloudSize==0))
  	{
  		System.out.println("ERROR: input not ready");
  		return;
  	}
  	System.out.println("Determining nearest intersections");
  	for (int cloud=0; cloud<NumberClouds; ++cloud)
  	{
  		for (int point=0; point<CloudSize; ++point)
  		{
  			L2=Double.POSITIVE_INFINITY;
  			X=XCloud[cloud][point];
  			Y=YCloud[cloud][point];
  			xnew=XCurve[0];
  			ynew=YCurve[0];
  			for (int segment=0; segment<(CurveSize-1); ++segment)
  			{
  				pA=XCurve[segment];
  				pB=XCurve[segment+1];
  				if (isnan(pA) || isnan(pB))
  				{
  					continue;
  				}  	
  				Dp=pB-pA;
  				qA=YCurve[segment];  
  				qB=YCurve[segment+1];
  				if (isnan(qA) || isnan(qB))
  				{
  					continue;
  				}  				
  				Dq=qB-qA;
  				gamma=((X-pA)*Dp+(Y-qA)*Dq)/(Dp*Dp+Dq*Dq);
  				if (gamma<0)
  				{
  					gamma=0;
  				}
  				else if (gamma>1)
  				{
  					gamma=1;
  				}
  				pB=pA+gamma*Dp;
  				qB=qA+gamma*Dq;
  				L2new=(X-pB)*(X-pB)+(Y-qB)*(Y-qB);
  				if (L2new<L2)
  				{
  					L2=L2new;
  					xnew=pB;
  					ynew=qB;
  				}  				  				  				
  			} 			
  			Distance2[cloud][point]=L2;
  			XIntersect[cloud][point]=xnew;
  			YIntersect[cloud][point]=ynew;  			 			  		
  		}
  	}  	  	
  	OutputReady=true;
  } 
// get methods
	public double[][] getDistance2()
	{
	if (!OutputReady)
	{
		System.out.println("Output not ready");
		return null;
	}
	return Distance2;
	}   
	public double[][] getXIntersect()
	{
	if (!OutputReady)
	{
		System.out.println("Output not ready");
		return null;	
	}
	return XIntersect;
	}   
	public double[][] getYIntersect()
	{
	if (!OutputReady)
	{
		System.out.println("Output not ready");
		return null;
	}
	return YIntersect;
	}   
// static methods
	public static boolean isnan(double arg)
	{
		if (arg!=arg)
		{
			return true;
		}
		else
		{
			return false;
		}		
	}
}