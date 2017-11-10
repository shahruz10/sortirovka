// List of shots
// Shots is an object we have defined that represents a single bullet
ArrayList<shot> shots = new ArrayList<shot>();
ArrayList<astroid> astroids = new ArrayList<astroid>();

// Settings - how many seconds between each new astroid (3 seconds = 3 * 60)
int astroid_rate = 2 * 60;
int astroid_count = 0;
// Size in pixel of nominal astroid
float ast_size = 10;
int ast_id = 1;
int score = 0;
float hitRate = 0;
int numShots = 0;
int ships = 3;

int pause = 0;

import processing.sound.*; 
SoundFile file;


// Run once
void setup () {
  
  file = new SoundFile(this, "mpt.mp3"); 
file.play();
  
  frameRate(60);
  size(500, 500);
  stroke(255);
  fill(255);
}

// Called 60 times per second
void draw()
{
  int i;
  // Find the angle from x=250, y=250 to the mouse
  float angle = atan2(mouseY - 250, mouseX - 250);

  if (pause==0) {

    // 1 new astroid every 5 seconds (60 fps * 4 sec)
    if (astroid_count--==0) {
      astroids.add(new astroid(random(0, TWO_PI), random(0.1, 2.5), random(0.5, 4), random(-0.1, 0.1), 
        random(-150, 150), random(-150, 150), ast_id++));
      // Increase rate just a little
      astroid_count = astroid_rate--;
    }

    // Clear screen, black
    background(1);

    // Go through all astroids (if any) and update their position
    for (i = 0; i<astroids.size(); i++) {
      astroid a = astroids.get(i);
      if (a.update()) {
        // Remove bullet, if outside screen
        astroids.remove(i);
      }
      // Detect collisions with Astroids by approximating ship with 4 circles
      // fill(160, 33, 100);  
      // ellipse(250, 250, 11, 11);
      // ellipse(13*cos(angle-PI)+250, 13*sin(angle-PI)+250, 17, 17);
      // ellipse(10*cos(angle)+250, 10*sin(angle)+250, 7, 7);
      // ellipse(18*cos(angle)+250, 18*sin(angle)+250, 2, 2);
      if (a.coll(250, 250, 6, -1) ||
        a.coll(13*cos(angle-PI)+250, 13*sin(angle-PI)+250, 9, -1) ||
        a.coll(10*cos(angle)+250, 10*sin(angle)+250, 4, -1) ||
        a.coll(18*cos(angle)+250, 18*sin(angle)+250, 1, -1)) {
        ships--;
        pause=3*60;
      }
    }

    // "pushMatrix" saves current viewpoint
    pushMatrix();
    // Set 250,250 as the new 0,0 
    translate(250, 250);
    // Rotate screen "angle" 
    rotate(angle);
    fill(255);
    // Draw a triangle (the ship)
    triangle(20, 0, -20, -10, -20, 10);
    // Bring back normal perspektive
    popMatrix();
  } else {
    // Pause is larger than 0
    // Clear screen, black
    background(0, 10);

    // Go through all astroids (if any) and update their position
    for (i = 0; i<astroids.size(); i++) {
      astroid a = astroids.get(i);
      a.incSpeed();
      if (a.update()) {
        // Remove bullet, if outside screen
        astroids.remove(i);
      }
    }
    if (ships == 0) {
      // Clear screen, black
      textAlign(CENTER);
      text("ХА ХА ТЫ ПРОИГРАЛ!", width/2, height/2);
      text("Нажимай любую кнопку, чтобы заново начать", width/2, 2*height/3);
      // 1 new astroid every 0.5 seconds (60 fps * 0.5 sec)
      // To make something happen while waiting 
      if (astroid_count--==0) {
        astroids.add(new astroid(random(0, TWO_PI), random(0.1, 2.0), random(0.5, 4), random(-0.1, 0.1), 
          random(-150, 150), random(-150, 150), ast_id++));
        // Increase rate just a little
        astroid_count = 30;
      }
      if (keyPressed == true) {
        score = 0;
        numShots = 0;
        ships = 3;
        astroid_rate = 3 * 60;
        astroid_count = 0;
        ast_id = 1;
        astroids = new ArrayList<astroid>();
      }
    } else {
      // Wait until astroids are gone
      if (astroids.size()==0) {
        pause=0;
      }
    }
  }
  // Go through all shots (if any) and update their position
  for (i = 0; i<shots.size(); i++) {
    shot s = shots.get(i);
    if (s.update()) {
      // Remove bullet, if outside screen or if hits astroid
      shots.remove(i);
    }
  }
  textAlign(LEFT);
  text("Очко   : " + score, 15, 15);
  text("Жизнь   : " + ships, 15, 30);
  text("Прогресс: " + int(100*score/float(numShots)) + "%", 15, 45);
}

// When left mouse button is pressed, create a new shot
void mousePressed() {
  if (pause==0) {
    // Only add shots when in action
    if (mouseButton == LEFT) {
      float angle = atan2(mouseY - 250, mouseX - 250);
      shots.add(new shot(angle, 4));
      numShots++;
    }
    if (mouseButton == RIGHT) {
      astroids.add(new astroid(random(0, TWO_PI), random(0.1, 2.0), random(0.5, 4), random(-0.1, 0.1), 
        random(-80, 80), random(-80, 80), ast_id++));
    }
  }
}

// Class definition for the shot
class shot {
  // A shot has x,y, and speed in x,y. All float for smooth movement
  float angle, speed;
  float x, y, x_speed, y_speed;

  // Constructor  
  shot(float _angle, float _speed) {
    angle = _angle;
    speed = _speed;
    x_speed = speed*cos(angle);
    y_speed = speed*sin(angle);
    x = width/2+20*cos(angle);
    y = height/2+20*sin(angle);
  }

  // Update position, return true when out of screen
  boolean update() {
    int i;
    x = x + x_speed;
    y = y + y_speed;

    // Draw bullet
    ellipse (x, y, 3, 3);

    // Check for collisions
    // Go through all astroids (if any)
    for (i = 0; i<astroids.size(); i++) {
      astroid a = astroids.get(i);
      if (a.coll(x, y, 3, -1)) {
        score++;
        ast_id++;
        astroids.remove(i);
        //Remove bullet
        return true;
      }
    }
    // End, check if outside screen
    if (x<0 || x>width || y<0 || y>height) {
      return true;
    } else {
      return false;
    }
  }
}



// Class definition for the shot
class astroid {
  // An astroid angle, speed, size, rotation
  float angle, speed, size, rotSpeed;
  float position;
  float rotation;
  float xoff, yoff;
  float x, y;
  PShape s;  // The PShape object - Keeps the astroid shape
  float i;
  int id;


  // Constructor  
  astroid(float _angle, float _speed, float _size, float _rotSpeed, float _xoff, float _yoff, int _id) {
    angle = _angle;
    speed = _speed;
    size = _size;
    rotSpeed = _rotSpeed;
    xoff = _xoff;
    yoff = _yoff;
    id = _id;
    if (xoff<1000) {
      x = 250+500*cos(angle)+xoff;
      y = 250+500*sin(angle)+yoff;
    } else {
      x = _xoff-2000;
      y = _yoff-2000;
    }
    rotation = 0; 
    // Generate the shape of the astroid - Some variations for all
    s = createShape();
    s.beginShape();
    s.fill(255, 255, 100);
    s.noStroke();
    for (i=0; i<TWO_PI; i=i+PI/(random(4, 11))) {
      s.vertex(random(ast_size*0.8, ast_size*1.2)*cos(i), random(ast_size*0.8, ast_size*1.2)*sin(i));
    }
    s.endShape(CLOSE);
  }

  // Increases the speed. Used in the end of the game to clear screen of astroids
  void incSpeed() {
    speed = speed * 1.02;
  }

  // Update position, return true when out of screen
  boolean update() {
    int i;
    x = x - cos(angle)*speed;
    y = y - sin(angle)*speed;
    rotation = rotation + rotSpeed; 

    // Check for astroid vs astroid collision
    for (i = 0; i<astroids.size(); i++) {
      astroid a = astroids.get(i);
      if ((a != this) && (a.coll(x, y, ast_size*size, id))) {
        if (size > 1) {
          astroids.add(new astroid(angle-random(PI/5, PI/7), speed+random(0, speed/2), size/2, rotSpeed, 2000+x, 2000+y, id));
          astroids.add(new astroid(angle+random(PI/5, PI/7), speed+random(0, speed/2), size/2, rotSpeed, 2000+x, 2000+y, id));    
          ast_id++;
        }
        astroids.remove(i);
      }
    }

    pushMatrix();
    // Set position as the new 0,0 
    translate(x, y);
    // Rotate screen "angle" 
    rotate(rotation);
    // Draw astroid
    scale(size);
    shape(s, 0, 0);
    // Bring back normal perspektive
    popMatrix();

    if (x<-300 || x>800 || y<-300 || y>800) {
      return true;
    } else {
      return false;
    }
  }

  //
  boolean coll(float _x, float _y, float _size, int _id) {
    float dist;

    dist = sqrt ((x-_x)*(x-_x) + (y-_y)*(y-_y));

    // Check if distance is shorter than astroid size and other objects size
    if ((dist<(_size+ast_size*size)) && (id!=_id)) {
      // Collision, 
      if (_id>0) id = _id;
      if (size > 1) {
        // If the astroid was "large" generate two new fragments
        astroids.add(new astroid(angle-random(PI/5, PI/7), speed+random(0, speed/2), size/2, rotSpeed, 2000+x, 2000+y, id));
        astroids.add(new astroid(angle+random(PI/5, PI/7), speed+random(0, speed/2), size/2, rotSpeed, 2000+x, 2000+y, id));
      }
      return true;
    } else { 
      return false;
    }
  }
}