// (:clashes "outline" "burst_2d" "cluster_2d" "grow_2d")

String MODE = P3D;

class Form
{
	float size;
	float x;
	float y;
	float z;

	Form ()
	{
	}

	void draw ()
	{
		pushMatrix ();
  		translate (x, y, z);
  		rotateX (- PI / 8.0);
  		rotateY (PI / 8.0);
  		box (size);
  		popMatrix ();
	}
}