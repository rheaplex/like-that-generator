class Appearance
{
	color colour;

	Appearance ()
	{
		switch (int (random (3)))
		{
			case 0:
			     colour = color (255, 0, 0, 240);
			     break;
			case 1:     
			     colour = color (255, 255, 0, 200);
			     break;
			case 2:     
  			     colour = color (0, 0, 255, 210);
			     break;
			case 3:     
  			     colour = color (0, 0, 0, 245); 
			     break;
		}
	}	

	void draw (Form f)
	{
		fill (colour);
		f.draw ();
	}
}
