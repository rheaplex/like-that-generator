// (:clashes "outline" "burst_3d" "cluster_3d" "grow_3d")

String MODE = P3D;

int KIND_COUNT = 3;

class Form
{
	float size;
	float x;
	float y;
	int kind;

	Form ()
	{
		kind = int (random (KIND_COUNT));
	}

	void draw ()
	{
		switch (kind)
		{
			case 0:
			     ellipseMode (CENTER);
	        	     ellipse (x, y, size, size);
			     break;
			case 1:
			     rectMode (CENTER);
	        	     rect (x, y, size, size);
			     break;
			case 2:
			     // Triangle
			     float halfSize = size / 2.0;
			     beginShape ();
			     vertex (-halfSize, halfSize);
			     vertex (0.0, -halfSize);
			     vertex (halfSize, halfSize);
			     endShape ();
			     break;
		}
	}
}

