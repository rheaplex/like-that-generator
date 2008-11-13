// Configuration constants

int min_objects = 4;
int max_objects = 24;

// In pixels

int canvas_width = 400;
int canvas_height = 400;

int min_object_x = -100;
int max_object_x = 100;
int min_object_y = -100;
int max_object_y = 100;

float min_object_start_t = 0.0;
float max_object_start_t = 0.5;

int min_object_size = 5;
int max_object_size = 200;

// In seconds

float min_duration = 1.0;
float max_duration = 10.0;


int num_objects;
Entity[] entities;
float rotation;
float end_of_current_sequence;


float RandomDuration ()
{
  return random (min_duration, max_duration) * 1000; 
}

void GenObjects ()
{
  rotation = random (PI / 2.0);
  
  num_objects = (int)random(min_objects, max_objects);
  
  entities = new Entity[num_objects]; 

  float start_growing = millis ();
  float growing_range = RandomDuration ();
  float stop_growing = start_growing + growing_range;
  float start_shrinking = stop_growing + RandomDuration ();
  float shrinking_range = RandomDuration ();
  float stop_shrinking = start_shrinking + shrinking_range;
  
  end_of_current_sequence = stop_shrinking;

  for (int i = 0; i < num_objects; i++) 
  {
	float t_factor = random (min_object_start_t, max_object_start_t);
        entities[i] = new Entity (
	 new Appearance (),
	 new Form (),
	 new Animation (
   	  random (min_object_x, max_object_x),
   	  random (min_object_y, max_object_y), 
   	  0.0, //random (min_object_z, max_object_z), 
   	  random (min_object_size, max_object_size), 
	  start_growing + (growing_range * t_factor),
	  stop_growing,
	  start_shrinking,
	  start_shrinking + (shrinking_range * t_factor)));
  }
}

void DrawObjects ()
{
  float now = millis ();
  if (now >= end_of_current_sequence)
  {
   GenObjects ();
  }
  for (int i = 0; i < num_objects; i++)
  {
    if (! entities[i].finished (now))
      entities[i].draw (now);
  } 
}

void draw ()
{
  background(255);
  if (MODE != P3D)
  {
     smooth ();
  }
  if ((MODE == P3D) || MODE == (OPENGL))
  {
	ambientLight (245, 245, 245);
  	directionalLight (50, 50, 50, 0, 1, -1);
	translate (canvas_width / 2.0, canvas_height / 2.0,
                   - (max (canvas_width, canvas_height) * 0.4));
  }
  else
  {
    translate (canvas_width / 2.0, canvas_height / 2.0);
  }
  noStroke ();
  DrawObjects ();   
}

void setup ()
{
  size(canvas_width, canvas_height, MODE); 
  frameRate(30);
  GenObjects ();
}
