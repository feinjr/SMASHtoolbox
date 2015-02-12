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
	int[] domain = new int[2]; 
	double[][] result = new double[height][width];
	int left, right, above, below;
	int k; 
	int L, Lvalid; 
	double[] local;
	double temp;	
	// manage filter domain	
	domain[0]=nhood[0];
	if (nhood.length == 1) { domain[1]=nhood[0]; }
	else { domain[1] = nhood[1]; }
	if (domain[0]%2 ==1) // odd
	{
		above=(domain[0]-1)/2;
		below=above;
	}
	else // even
	{
		above=domain[0]/2;
		below=above-1;
	}
	if (domain[1]%2 ==1) // odd
	{
		right=(domain[1]-1)/2;
		left=right;
	}
	else // even
	{
		right=domain[1]/2;
		left=right-1;
	}	
	L=domain[0]*domain[1];
	local= new double[L];
	// apply filter	
	for (int m=0; m<height; m++)
	{
		for (int n=0; n<height; n++)
		{
			// extract local block
			k=0;
			for (int mk=(m-below); mk<=(m+above); mk++)
			{
				for (int nk=(n-left); nk<=(n+right); nk++)
				{
					try { local[k]=Data[mk][nk]; }
					catch (Exception e) {local[k]=Double.NaN;}
					k=k+1;
				}
			}
			// local statistics
			/*
			Arrays.sort(local);
			Lvalid=L;
			for (int kk=L-1; kk>0; kk--)
			{
				if (local[kk] != local[kk]) {continue;} // NaN entry					
				Lvalid=kk+1;
				break;			
			}
			if (Lvalid%2 ==1) {k=(Lvalid-1)/2;} // odd			
			else {k=Lvalid/2;} // even
			result[m][n]=local[k-1];			
			*/
			result[m][n]=1; // assignment for time testing
		}
	}
	return result;
}


}