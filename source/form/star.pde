// (:clashes "outline" "burst_3d" "cluster_3d" "grow_3d")

String MODE = P3D;

class Form
{
	float size;
	float x;
	float y;

	Form ()
	{
	}

	void draw ()
	{
		pushMatrix ();
		translate (x, y);
		beginShape ();
		for (int i = 0; i < 5; i++)
		{
			float theta = (TWO_PI / 10.0) * (i *2);
			vertex (0.0 - (size / 4.0) * sin (theta), 
			        0.0 + (size / 4.0) * cos (theta));
			theta += (TWO_PI / 10.0);
			vertex (0.0 - (size / 2.0) * sin (theta), 
			        0.0 + (size / 2.0) * cos (theta));
		}
		endShape ();
		popMatrix ();
	}
}

