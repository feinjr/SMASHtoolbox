// Cloud2Curve class
public class Cloud2Curve
{
	public double[][] x, y, theta;
	public double u,v;
	public double p,q;

  public Cloud2Curve()
  {      
      System.out.println("Creating Java object");	
      //name="Java test class";
  }
  public void define(double[][] X)
  {
  	x=X;
  	//y=Y;
  } 

/*  public double Add(double v)
  {
      value += v;
      return value;
  }
  public double Subtract(double v)
  {
      value = value - v;
      return value;
  }
  public double testSpeed(long Iterations)
  {
  	double temp=0;
  	for (double k=1; k<=Iterations; k=k+1)
  	{
  		temp=temp+1;
  	}
  	return temp;
  }
  */
}