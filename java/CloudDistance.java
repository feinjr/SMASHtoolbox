import java.util.Arrays;

public class CloudDistance
{
private int M,N; // M: number of clouds, N: points per cloud
public double[][] DataX,DataY; // cloud position data [MxN]
public double[][] VectorU,VectorV; // direction limit data [Mx2]
private int L; // L: number of segments (at least one less than number of curve points)
public double[][] Curve; // curve data [Lx2]
public double[][] Segment; // segment [(L-1)x4]
public double[][] Distance2,XIntersection,YIntersection; // intersection data [MxN]

// constructor
public CloudDistance()
{      
	System.out.println("Creating Java object");		
}
	
// calculate method
public void calculate()
{
	double X,Y; // cloud point
	double ux,uy,vx,vy; // limit vectors
	double P,Q,R,S; // segment positions
	double PR,QS; // segment distances
	double gx,gy,hx,hy; // segment vectors	
	double cross_gu,cross_gv,cross_hu,cross_hv; // cross product z-components
	boolean g_inside,h_inside,u_inside,v_inside; // vector inside testing
	double gamma,xgamma,ygamma,Lxgamma,Lygamma,L2gamma; // current intersection variables
	double L2,Xint,Yint; // intersection variables
	initialize(); // test inputs and set up outputs
	for (int m=0; m<M; m++) // m: cloud index
	{
		// direction limit vectors (externally normalized)
		ux=VectorU[m][0];
		uy=VectorU[m][1];
		vx=VectorV[m][0];
		vy=VectorV[m][1];
/*		for (int n=0; n<N; n++) // n: point index
		{
			// cloud point
			X=DataX[m][n];
			Y=DataY[m][n];
			L2=Double.POSITIVE_INFINITY;
			xint=Double.NaN;
			yint=Double.NaN;
			for (int k=0; k<(L-1); k++) // k: segment index
			{							
				// segment positions
				P=Segment[k][0];
				Q=Segment[k][1];
				R=Segment[k][2];
				S=Segment[k][3];		
				// segment directions (not normalized)
				gx=P-X;
				gy=Q-Y;
				hx=R-X;
				hy=S-Y;
				// reconcile segment with limit vectors			
				cross_gu=gx*uy-gy*ux;
				cross_gv=gx*vy-gy*vx;
				cross_hu=hx*uy-hy*ux;
				cross_hv=hx*vy-hy*vx;				
				g_inside=(cross_gu*cross_gv<=0);
				h_inside=(cross_hu*cross_hv<=0);
				u_inside=(cross_gu*cross_hu<=0);  
				v_inside=(cross_gv*cross_hv<=0);				
				if (!g_inside && !h_inside && !u_inside && !v_inside) // direction limits prevent segment intersection
				{
				//System.out.println("Cloud " + m + " Point " + n + " Segment " + k + " Case 2");
					continue; 
				}
//								for (int orient=1; orient<=2; orient++)
//				{
//				ux=-ux;
//				uy=-uy;					
				if (u_inside && v_inside) // revise segment to match both limit vectors
				{
				System.out.println("Cloud " + m + " Point " + n + " Segment " + k + " Case 3");
					PR=R-P;
					QS=S-Q;	
					gamma=((X-P)*vy-(Y-Q)*vx)/(PR*vy-QS*vx);
					R=P+gamma*PR;
					S=Q+gamma*QS;	
					PR=R-P;
					QS=S-Q;
					gamma=((X-P)*uy-(Y-Q)*ux)/(PR*uy-QS*ux);	
					P=P+gamma*PR;
					Q=Q+gamma*QS;	
				}
				else if (u_inside || v_inside) // revise segment to match one limit vector
				{
				System.out.println("Cloud " + m + " Point " + n + " Segment " + k + " Case 4");
					PR=R-P;
					QS=S-Q;
					gamma=0;
					if (u_inside)
					{
						gamma=((X-P)*uy-(Y-Q)*ux)/(PR*uy-QS*ux);
					}
					else if (v_inside)
					{
						gamma=((X-P)*vy-(Y-Q)*vx)/(PR*vy-QS*vx);
					}					
					if (g_inside)
					{
						R=P+gamma*PR;
						S=Q+gamma*QS;
					}
					else
					{
						P=P+gamma*PR;
						Q=Q+gamma*QS;
					}
				}																																			
				// calculate shortest distance between point and line segment
				PR=R-P;
				QS=S-Q;				
				gamma=((X-P)*PR+(Y-Q)*QS)/(PR*PR+QS*QS);
				//System.out.println("gamma=" + gamma);
				if (gamma<0)
				{
					gamma=0;
				}
				else if (gamma>1)
				{
					gamma=1;
				}
				xgamma=P+gamma*PR;
				Lxgamma=xgamma-X;
				ygamma=Q+gamma*QS;
				Lygamma=ygamma-Y;
				L2gamma=Lxgamma*Lxgamma+Lygamma*Lygamma;
				// compare to previous results
				if (L2gamma<L2)
				{					
					L2=L2gamma;
					xint=xgamma;
					yint=ygamma;
				}
			}
			// store results
			Distance2[m][n]=L2;
			XIntersection[m][n]=xint;
			YIntersection[m][n]=yint;
		}
*/
	}
}

// initialize method
public void initialize()
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

// point2segment method: find nearest intersection between point (X,Y) and line segment PQ within limited direction range
// Result=point2segment(Point,Segment,Direction);
// Result: [L2 Xint Yint]
// Point: [X Y]
// Segment: [XP YP XQ YQ]
// Direction: [ux uy vx vy] (normalized)
public static double[] point2segment(double[] Point, double[] Segment, double[] Direction)
{
	double[] Result=new double[3]; // [L_2 x_intersect y_intersect]
	double X=Point[0], Y=Point[1];
	double XP=Segment[0], YP=Segment[1], XQ=Segment[2], YQ=Segment[3]; // segment positions
	double XPref=XP,YPref=YP; // reference position
	double ux=Direction[0], uy=Direction[1], vx=Direction[2], vy=Direction[3]; // limit vectors
	double[] GammaArray=new double[4]; // [gamma_P gamma_Q gamma_u gamma_v
	double gamma; // temporary value
	double gx,gy,hx,hy; // point to segment vectors
	double sx,sy; // segment vector
	double alpha,beta; // vector decomposition factors
	double L2,Xint,Yint; // intersection variables
	// calculate vector components
	gx=XP-X;
	gy=YP-Y;
	hx=XQ-X;
	hy=YQ-Y;
	sx=XQ-XP;
	sy=YQ-YP;
	// determine if segment points are inside allowed region	
	
	
	
	crossA=ux*gy-uy*gx;
	crossB=vx*gy-vy*gx;	
	if ((crossA*crossB<=0)) {GammaArray[0]=0;}
	else {GammaArray[0]=Double.NaN;}
	crossA=ux*hy-uy*hx;
	crossB=vx*hy-vy*hx;	
	System.out.println("crossA="+crossA);
	System.out.println("crossB="+crossB);
	if ((crossA*crossB<=0)) {GammaArray[1]=1;}
	else {GammaArray[1]=Double.NaN;}
	// look for boundary-segment intersections 				
	gamma=((X-XP)*uy-(Y-YP)*ux)/(sx*uy-sy*ux);
	if ((gamma>=0) & (gamma<=1)){GammaArray[2]=gamma;}
	else {GammaArray[2]=Double.NaN;}	
	gamma=((X-XP)*vy-(Y-YP)*vx)/(sx*vy-sy*vx);
	if ((gamma>=0) & (gamma<=1)){GammaArray[3]=gamma;}
	else {GammaArray[3]=Double.NaN;}	
	for (int k=0; k<4; k++)
		{System.out.println(GammaArray[k]);}	
	Arrays.sort(GammaArray);	
	// process allowed line segments
	Result[0]=Double.POSITIVE_INFINITY; // L2
	Result[1]=Double.NaN; // xint
	Result[2]=Double.NaN; // yint
	for (int k=0; k<4; k=k+2)
	{
		if (Double.isNaN(GammaArray[k])) {break;}
		XP=XPref+GammaArray[k]*sx;
		YP=YPref+GammaArray[k]*sy;
		XQ=XPref+GammaArray[k+1]*sx;
		YQ=YPref+GammaArray[k+1]*sy;					
		gamma=((XQ-XP)*(X-XP)+(YQ-YP)*(Y-YP))/((XQ-XP)*(XQ-XP)+(YQ-YP)*(YQ-YP));
		//if (gamma<GammaArray[k]) {gamma=GammaArray[k];}
		//else if (gamma>GammaArray[k+1]) {gamma=GammaArray[k+1];}
		Xint=XPref+gamma*sx;
		Yint=YPref+gamma*sy;
		L2=(X-Xint)*(X-Xint)+(Y-Yint)*(Y-Yint);
		if (L2<Result[0])
		{
			Result[0]=L2;
			Result[1]=Xint;
			Result[2]=Yint;
		}	
	}		
	return Result;
}

}