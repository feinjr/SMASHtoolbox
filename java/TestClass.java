// This class is for testing MATLAB's Java interface
public class TestClass
{
  private double value;
  public String name;

  public TestClass()
  {
      value = 0;
      System.out.println("Creating Java object");	
      name="Java test class";
  }

  public double Add(double v)
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
}