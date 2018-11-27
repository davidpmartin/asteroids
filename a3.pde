/**************************************************************
* File: a3.pde
* Description: Asteroids is a game about shooting asteroids, aliens and
*  getting a high score.
* Usage: Make sure to run in the processing environment on a 1080p screen
*  and press play
* Dependencies: Requires the Processing 'Sound' library
* Assets: Sound effect files were sourced free from several
   websites. See accompanying 'Asset References.txt' document for details.
**************************************************************/

/**************************************************************************
* Import Dependencies
**************************************************************************/
import processing.sound.*;
SoundFile sfx_alien, sfx_shoot, sfx_explosion, sfx_complete;
SoundFile sfx_powerup, sfx_gameover;

/**************************************************************************
* Declare Variables
**************************************************************************/
/* <----------------- Declare Variables ---------------------> */
int lives, state, score, highScore, level, asteroidCount, asteroidVerticesCount;
int particleCount, particleLife, particleSpeed, powerUpDur, powerUpTimer;
Ship ship;
ArrayList<Projectile> projectiles;
ArrayList<Asteroid> asteroids;
ArrayList<Particle> particles;
ArrayList<Alien> aliens;
boolean sUP=false, sDOWN=false, sRIGHT=false, sLEFT=false, sSHOOT = false;
float shipSpeed, shipDrag, shootCd, projSpeed, projLife, time = 0;

/**************************************************************************
* Setup & Draw Loop
**************************************************************************/

/**************************************************************************
* Function: setup()
* Parameters: None ()
* Returns: void
* Desc: Initial setup where screen size, pixelDensity, renderer and default
*  text align are set. Using P2D to counter frame rate issues with default
*  renderer. Load sound files, start background music loop and start game.
**************************************************************************/
void setup() {
  // Set screen properties
  size(1600, 900, P2D);
  pixelDensity(displayDensity());
  textAlign(CENTER); // Set default text align
  
  // Set sfx variables
  sfx_alien = new SoundFile(this, "alien.mp3");
  sfx_shoot = new SoundFile(this, "laser.mp3");
  sfx_explosion = new SoundFile(this, "explosion.mp3");
  sfx_complete = new SoundFile(this, "lvlcomplete.mp3");
  sfx_gameover = new SoundFile(this, "gameover.mp3");
  sfx_powerup = new SoundFile(this, "powerup.mp3");
  
  // Start bg music and start game
  startGame(10);
}

/**************************************************************************
* Function: draw()
* Parameters: None ()
* Returns: void
* Desc: Draw background and set stroke and fill. Display game text
*  depending on game state, and update game depending on game state.
**************************************************************************/
void draw() {
  background(0);
  stroke(0);
  fill(255);
  
  switch (state) {
    case 1:
      // New Game
      displayAsteroids();
      displayAliens();
      
      // On key press, run the start function
      if (keyPressed) {
        startGame(1);
        startLevel();
      }
      break;
    case 2:
      // Playing, reads input, updates ship position, and redraws to screen
      displayShip();
      displayProjectiles();
      displayAsteroids();
      displayParticles();
      displayAliens();
    
    // Once all aliens and asteroids are destroyed, show level complete
      if (asteroids.size() == 0 && aliens.size() == 0) {
        sfx_complete.play();
        sfx_complete.amp(0.6);
        state = 3;
      }
      break;
    case 3:
      // End Level
      displayShip();
      displayProjectiles();
      displayAsteroids();
      displayParticles();
      displayAliens();
    
      // Wait for SPACE key to be pressed to start next level
      if (keyPressed && key == ' ') {
        level += 1;
        state = 4;
        time = millis();
      }
      break;
    case 4:
      // Next Level
      // Wait 3 seconds, adjust difficulty variables and start the level
      if ((millis() - time) > 2000) {
        if (level > 1) {
          asteroidCount += 2;
        }
        startLevel();
      }
      break;
    case 5:
      // Game Over
      displayAsteroids();
      displayParticles();
      displayAliens();
      
      // Wait for SPACE key press before game restart
      if (keyPressed && key == ' ') {
        startGame(1);
        state = 4;
        time = millis();
      }
      break;
  }
  
  displayGameText();
}

/**************************************************************************
* Functions
**************************************************************************/

/**************************************************************************
* Function: startGame()
* Parameters: int a (number of asteroids to start game with)
* Returns: void
* Desc: Set initial values for a new game and spawn asteroids and aliens
**************************************************************************/
void startGame(int a) {
  // Adjustable values
  level = 1;
  lives = 3;
  score = 0;
  shipSpeed = 4;
  shipDrag = .99;
  shootCd = 400; // 0.4 seconds
  projSpeed = 9;
  projLife = 60 * 2; // 2 seconds
  asteroidCount = a;
  asteroidVerticesCount = 18;
  powerUpDur = 6000; // 6 seconds
  particleCount = 18;
  particleLife = 10;
  particleSpeed = 3;
  state = 1;
  projectiles = new ArrayList<Projectile>();
  asteroids = new ArrayList<Asteroid>();
  particles = new ArrayList<Particle>();
  aliens = new ArrayList<Alien>();
  spawnAsteroids();
  spawnAliens();
}

/**************************************************************************
* Function: startLevel()
* Parameters: None ()
* Returns: void
* Desc: Set initial values for a new level and spawn asteroids and aliens
**************************************************************************/
void startLevel() {
  ship = new Ship();
  asteroids.clear();
  projectiles.clear();
  particles.clear();
  aliens.clear();
  spawnAsteroids();
  spawnAliens();
  state = 2;
}

/**************************************************************************
* Function: spawnAsteroids()
* Parameters: None ()
* Returns: void
* Desc: Iterates asteroid ArrayList spawning them with a random location
*  and velocity 
**************************************************************************/
void spawnAsteroids() {
  for (int i = 0; i < asteroidCount; i++) {
    // Don't spawn an asteroid too close to ship spawn location
    float x = random(0,width);
    while (x > (width/2 - 100) && x < (width / 2) + 100)
      x = random(0, width);
    float y = random(0,height);
    while (y > (height/2 - 100) && y < (height / 2) + 100)
      y = random(0, height);
    PVector asteroidVelocity = new PVector(random(-2, 2), random(-2, 2));
    asteroids.add(new Asteroid(new PVector(x, y), asteroidVelocity, 1));
  }
}

/**************************************************************************
* Function: spawnAliens()
* Parameters: None ()
* Returns: void
* Desc: Iterates alien ArrayList spawning them with a random location
*  and velocity and play the alien sound effect.
**************************************************************************/
void spawnAliens() {
  for (int i = 0; i < asteroidCount / 3; i++) {
    // Don't spawn an alien too close to ship spawn location
    float x = random(0,width);
    while (x > (width/2 - 100) && x < (width / 2) + 100)
      x = random(0, width);
    float y = random(0,height);
    while (y > (height/2 - 100) && y < (height / 2) + 100)
      y = random(0, height);
    PVector alienVelocity = new PVector(random(-1, 1), random(-1, 1));
    aliens.add(new Alien(new PVector(x, y), alienVelocity));
    if (state != 1) {
      sfx_alien.play();
      sfx_alien.amp(0.6);
    }
  }
}

/**************************************************************************
* Function: spawnParticles()
* Parameters: PVector location (central point of particles)
* Returns: void
* Desc: Iterates particle ArrayList spawning from a central point for a
*  destruction effect
**************************************************************************/
void spawnParticles(PVector location) {
  float angleIncrement = TWO_PI / particleCount;
  for (int k = 0; k < particleCount; k++) {
    float angle = angleIncrement * k;
    PVector particleLocation = new PVector(location.x, location.y);
    PVector particleVelocity = new PVector(sin(angle), cos(angle));
    particleVelocity.mult(particleSpeed);
    particles.add(new Particle(particleLocation, particleVelocity));
  }
}

/**************************************************************************
* Function: displayShip()
* Parameters: None ()
* Returns: void
* Desc: Updates ship position, fires and displays. If the ship has no
*  lives, play game over sound and change game state.
**************************************************************************/
void displayShip() {
  ship.move();
  ship.shoot();
  if (ship.update()) {
    sfx_gameover.play();
    sfx_gameover.rate(0.5);
    if (score > highScore) {
      highScore = score;
    }
    state = 5;
    return;
  }
  ship.display();
  ship.checkEdges();
}

/**************************************************************************
* Function: displayProjectiles()
* Parameters: None ()
* Returns: void
* Desc: Iterates projectiles, deletes if necessary, and displays
**************************************************************************/
void displayProjectiles() {
  // Iterates through projectiles objects array
  for (int i = projectiles.size() - 1; i >= 0; i--) {
    projectiles.get(i).checkEdges();
    // Remove from array if needed, or display
    if (projectiles.get(i).update())
      projectiles.remove(i);
    else
      projectiles.get(i).display();
  }
}

/**************************************************************************
* Function: displayAsteroids()
* Parameters: None ()
* Returns: void
* Desc: Iterates asteroids, deletes if necessary, and displays
**************************************************************************/
void displayAsteroids() {
  // Iterates through asteroids objects array
  for (int i = asteroids.size() - 1; i >= 0; i--) {
    asteroids.get(i).checkEdges();
    // Remove from array if needed, or display
    if (asteroids.get(i).update()) {
      sfx_explosion.play();
      asteroids.remove(i);
    } else {
      asteroids.get(i).display();
    }
  }
}

/**************************************************************************
* Function: displayParticles()
* Parameters: None ()
* Returns: void
* Desc: Iterates particles, deletes if necessary, and displays
**************************************************************************/
void displayParticles() {
  // Iterates through particles objects array
  for (int i = particles.size() - 1; i >= 0; i--) {
    particles.get(i).checkEdges();
    // Remove from array if needed, or display
    if (particles.get(i).update())
      particles.remove(i);
    else
      particles.get(i).display();
  }
}

/**************************************************************************
* Function: displayAliens()
* Parameters: None ()
* Returns: void
* Desc: Iterates aliens, deletes if necessary, and displays
**************************************************************************/
void displayAliens() {
  // Iterates through aliens objects array
  for (int i = aliens.size() - 1; i >= 0; i--) {
    aliens.get(i).checkEdges();
    // Remove from array if needed, or display
    if (aliens.get(i).update()) {
      sfx_explosion.play();
      togglePowerUp("on");
      aliens.remove(i);
    } else {
      aliens.get(i).display();
    }
  }
}

/**************************************************************************
* Function: displayGameText()
* Parameters: None ()
* Returns: void
* Desc: Displays game text based on game state
**************************************************************************/
void displayGameText() {
  stroke(255);
  fill(255);
  switch (state) {
    case 1:
      // New Game
      textSize(60);
      text("Asteroids!", width/2, height/2 - 150);
      textSize(20);
      text("Press any key to start... ", width/2, height/2);
      textSize(17);
      text("Controls:", width/2, height/2 + 100);
      textSize(15);
      text("Control: Fire\nArrow Keys: Move", width/2, height/2 + 130);
      break;
    case 2:
      // Playing
      textAlign(RIGHT, BOTTOM);
      textSize(15);
      text("Level", width/2 - 70, 25);
      textSize(20);
      text(level, width/2 - 70, 50);
      
      textAlign(LEFT, BOTTOM);
      textSize(15);
      text("Lives", width/2 + 70, 25);
      
      textAlign(CENTER, BOTTOM);
      textSize(15);
      text("Score", width/2, 25);
      textSize(30);
      text(score, width/2, 60);
      
      for (int l = 0; l < lives; l++) {
        pushMatrix();
          translate(width/2 + 75 + (l * 15), 40);
          fill(0);
          strokeWeight(1);
          triangle(-5,5,5,5,0,-10);
        popMatrix();
      }
      break;
    case 3:
      // End Level
      textSize(24);
      String levelMsg = "Level " + level + " Complete";
      text(levelMsg, width/2, height/2);
      
      textSize(16);
      String contMsg = "Press Space to continue...";
      text(contMsg, width/2, height/2 + 35);
      break;
    case 4:
      // Next Level
      textSize(30);
      String nextLevelMsg = "Level " + level;
      text(nextLevelMsg, width/2, height/2);
      break;
    case 5:
      // Game Over
      textSize(40);
      String gameOverMsg = "Game Over";
      text(gameOverMsg, width/2, height/2 - textAscent()/2);
      
      //Final score msg
      textSize(20);
      String scoreMsg = "Final Score: " + score;
      text(scoreMsg, width/2, height/2 + textAscent()/2);
      
      // Highest score
      textSize(20);
      String hScoreMsg = "Highest Score: " + highScore;
      text(hScoreMsg, width/2, height/2 + 25 + textAscent()/2);
      
      // Replay
      textSize(16);
      String replayMsg = "Press Space to start again...";
      text(replayMsg, width/2, height/2 + 80);
      break;
  }
  
  // Reset Text Align
  textAlign(CENTER);
}

/**************************************************************************
* Function: togglePowerUp()
* Parameters: String state (state of power up)
* Returns: void
* Desc: Toggles state of power up
**************************************************************************/
void togglePowerUp(String state) {
  if (state == "on") {
    ship.cooldown = 200;
    ship.powerUpActive = true;
    powerUpTimer = millis();
    sfx_powerup.play();
    sfx_powerup.rate(0.5);
  } else if (state == "off") {
    ship.powerUpActive = false;
    ship.cooldown = shootCd;
  }
}

/**************************************************************************
* Function: keyPressed()
* Parameters: None ()
* Returns: void
* Desc: Handle keyPressed event
**************************************************************************/
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      sUP = true;
    } else if (keyCode == DOWN) {
      sDOWN = true;
    } else if (keyCode == RIGHT) {
      sRIGHT = true;
    } else if (keyCode == LEFT) {
      sLEFT = true;
    } else if (keyCode == CONTROL) {
      sSHOOT = true;
    }
  }
}

/**************************************************************************
* Function: keyReleased()
* Parameters: None ()
* Returns: void
* Desc: Handle keyReleased event
**************************************************************************/
void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) {
      sUP = false;
    } else if (keyCode == DOWN) {
      sDOWN = false;
    } else if (keyCode == RIGHT) {
      sRIGHT = false;
    } else if (keyCode == LEFT) {
      sLEFT = false;
    } else if (keyCode == CONTROL) {
      sSHOOT = false;
    }
  }
}

/**************************************************************************
* Classes
**************************************************************************/

/**************************************************************************
* Class: Ship
**************************************************************************/
class Ship extends OnScreenObject implements Visible, Collidable {
  /* Declare Ship object properties */
  PVector accel;
  float direction, drag, turnRate, timeLastShot, cooldown, invincibility;
  boolean powerUpActive;
  
  /************************************************************************
  * Function: Ship()
  * Parameters: None ()
  * Desc: Constructs ship object with default values
  ************************************************************************/
  Ship() {
    location = new PVector(width/2, height/2);
    accel = new PVector(0,0);
    velocity = new PVector(0,0);
    direction = 0;
    drag = shipDrag;
    radius = 5;
    turnRate = 0.07;
    timeLastShot = 0;
    cooldown = shootCd;
    powerUpActive = false;
    invincibility = 0;
  }
  
  /************************************************************************
  * Function: update()
  * Parameters: None ()
  * Returns: boolean
  * Desc: Updates ship lives, invincibility, velocity and location
  ************************************************************************/
  boolean update() {
    if (invincibility == 0) {
      if (lives <= 0)
        return true;
      for (int i = 0; i < asteroids.size(); i++) {
        Asteroid a = asteroids.get(i);
        if (a.collide(location, radius))
          if (die())
            return true;
      }
      for (int i = 0; i < aliens.size(); i++) {
        Alien a = aliens.get(i);
        if (a.collide(location, radius))
          if (die())
            return true;
      }
    } else {
      invincibility--;
    }
    // Updates velocity and applies max limit
    velocity.add(accel);
    velocity.mult(drag);
    velocity.limit(shipSpeed);
    
    // Updates location, resets acceleration to 0
    location.add(velocity);
    
    // Check power up status
    if (powerUpActive == true) {
      if (millis() - powerUpTimer > powerUpDur) {
        togglePowerUp("off");
      }
    }
    return false;
  }
  
  /************************************************************************
  * Function: display()
  * Parameters: None ()
  * Returns: void
  * Desc: Draws the ship to the screen
  ************************************************************************/
  void display() {
    // pushMatrix for easier coordinates & rotation
    pushMatrix();
      translate(location.x, location.y);
      rotate(direction);
      fill(0);
      strokeWeight(1);
      if (invincibility == 0)
        stroke(255);
      else
        stroke(255,255,255,(invincibility % 60) * (255 / 60));
      triangle(-radius,radius,radius,radius,0,-radius*2);
      
      // if the ship is accelerating draw a thruster
      if (accel.mag() != 0) {
        float colour = random(0,255);
        fill(colour, colour/2, 0);
        triangle(-2, 5, 2, 5, 0, 12);
      }
    popMatrix();
  }
  
  /************************************************************************
  * Function: collide()
  * Parameters: PVector l (location of object colliding with)
  *             float r (radius of object colliding with)
  * Returns: boolean
  * Desc: Detects collision between this object, and another object with
  *   radius r. Allows for temporary invincibility after respawn
  ************************************************************************/
  boolean collide(PVector l, float r) {
    if (invincibility == 0)
      if (dist(l.x, l.y, location.x, location.y) < radius + r)
        return true;
    return false;
  }
  
  /************************************************************************
  * Function: shoot()
  * Parameters: None ()
  * Returns: void
  * Desc: Shoots projectile if key to shoot held down, and cooldown has
  *   expired. Projectile is fired in the direction the ship is facing at a
  *   fixed velocity, with the ship velocity added
  ************************************************************************/
  void shoot() {
    if (sSHOOT) {
      // Uses the millis runtime timer to calculate if cooldown is met
      if (millis() - timeLastShot > cooldown) {
        // Creates new PVector properties with starting velocity
        PVector loc = new PVector(0,0);
        PVector vel = new PVector(0, projSpeed);
         
        // Adds ships velocity and location to PVectors
        loc.add(location);
        vel.rotate(direction + PI);
        vel.add(velocity);
        
        // Initializes Projectile instance in array
        projectiles.add(new Projectile(loc, vel, true));
        
        // Resets cooldown
        timeLastShot = millis();
        
        // Plays sfx
        sfx_shoot.play();
        sfx_shoot.amp(0.6);
      }
    }
  }
  
  /************************************************************************
  * Function: move()
  * Parameters: None ()
  * Returns: void
  * Desc: Handle input to accelerate or decelerate ship, or turn ship
  ************************************************************************/
  void move() {
    // Accelerates & changes direction based on user input
    if (sUP) {
      accel.x = 0.1 * sin(ship.direction);
      accel.y = -0.1 * cos(ship.direction);
    } else {
    accel.mult(0);
    }
    if (sDOWN) {
      accel.x = -0.1 * sin(ship.direction);
      accel.y = 0.1 * cos(ship.direction);
    }
    if (sRIGHT) {
      direction += turnRate;
    }
    if (sLEFT) {
      direction -= turnRate;
    }
  }
  
  /************************************************************************
  * Function: die()
  * Parameters: None ()
  * Returns: boolean
  * Desc: Handles ship destruction and returns true if out of lives
  ************************************************************************/
  boolean die() {
    lives--;
    spawnParticles(location);
    sfx_explosion.play();
    if (lives == 0) {
      return true;
    } else {
      location = new PVector(width/2, height/2);
      accel = new PVector(0,0);
      velocity = new PVector(0,0);
      invincibility = 3 * 60;
    }
    return false;
  }
}

/**************************************************************************
* Class: Asteroid
**************************************************************************/
class Asteroid extends OnScreenObject implements Visible, Collidable {
  /* Declare Asteroid object properties */
  PShape asteroid;
  PVector[] vertices;
  float spin;
  int type, rotation;
  boolean active;
  
  /************************************************************************
  * Function: Asteroid()
  * Parameters: PVector l (location of the asteroid)
  *             PVector v (velocity of the asteroid)
  *             int t (asteroid type which changes radius)
  * Desc: Constructs asteroid object with default values in a random shape
  *   based off a radius and number of vertices
  ************************************************************************/
  Asteroid(PVector l, PVector v, int t) {
    location = l;
    velocity = v;
    type = t;
    rotation = 0;
    active = true;
    spin = random(-2,2);
    if (t == 1)
      radius = 30;
    else if (type == 2)
      radius = 20;
    else
      radius = 10;
    vertices = new PVector[asteroidVerticesCount];
    asteroid = createShape();
    asteroid.beginShape();
    asteroid.strokeWeight(1);
    asteroid.stroke(255);
    asteroid.fill(0);
    float angleIncrement = TWO_PI / asteroidVerticesCount;
    for(int i = 0; i < asteroidVerticesCount; i++) {
      float angle = angleIncrement * i;
      float r = radius;
      if (i % 3 == 0)
        r += random(-(radius / 2), radius / 8);
      vertices[i] = new PVector(r * sin(angle),r * cos(angle));
      asteroid.vertex(vertices[i].x, vertices[i].y);
    }
    asteroid.vertex(vertices[0].x, vertices[0].y);
    asteroid.endShape();
  }
  
  /************************************************************************
  * Function: update()
  * Parameters: None ()
  * Returns: boolean
  * Desc: Updates asteroid location if active, otherwise is removed
  ************************************************************************/
  boolean update() {
    if (!active)
      return true;
    // Update location
    location.add(velocity);
    return false;
  }

  /************************************************************************
  * Function: display()
  * Parameters: None ()
  * Returns: void
  * Desc: Draws the asteroid to the screen
  ************************************************************************/
  void display() {
    pushMatrix();
      translate(location.x, location.y);
      rotate(radians(rotation += spin));
      fill(0,0,0,0);
      strokeWeight(1);
      shape(asteroid);
    popMatrix();
  }
  
  /************************************************************************
  * Function: collide()
  * Parameters: PVector l (location of object colliding with)
  *             float r (radius of object colliding with)
  * Returns: boolean
  * Desc: Detects collision between this object, and another object with
  *   radius r.
  ************************************************************************/
  boolean collide(PVector l, float r) {
    if (dist(l.x, l.y, location.x, location.y) < radius + r)
      return true;
    return false;
  }
}

/**************************************************************************
* Class: Alien
**************************************************************************/
class Alien extends OnScreenObject implements Visible, Collidable {
  /* Declare Alien object properties */
  PShape alien;
  int rotation;
  float timeLastShot, cooldown;
  boolean active;
  
  /************************************************************************
  * Function: Alien()
  * Parameters: PVector l (location of the alien)
  *             PVector v (velocity of the alien)
  * Desc: Constructs alien object at location with velocity with a generic
  *   shape for all objects.
  ************************************************************************/
  Alien(PVector l, PVector v) {
    location = l;
    velocity = v;
    radius = 10;
    rotation = 0;
    active = true;
    timeLastShot = 0;
    cooldown = shootCd;
    alien = createShape();
    alien.beginShape();
    alien.strokeWeight(1);
    alien.stroke(255);
    alien.fill(0);
    alien.vertex(15,0);
    alien.vertex(5,5);
    alien.vertex(-5,5);
    alien.vertex(-15,0);
    alien.vertex(-6,-5);
    alien.vertex(6,-5);
    alien.vertex(-6,-5);
    alien.vertex(-3,-10);
    alien.vertex(3,-10);
    alien.vertex(6,-5);
    alien.vertex(15,0);
    alien.vertex(-15,0);
    alien.vertex(15,0);
    alien.endShape();
  }
  
  /************************************************************************
  * Function: update()
  * Parameters: None ()
  * Returns: boolean
  * Desc: Updates alien location if alive, otherwise is removed. Also
  *   handles firing towards player
  ************************************************************************/
  boolean update() {
    if (!active)
      return true;
    // Uses the millis runtime timer to calculate if cooldown is met
    if (millis() - timeLastShot > cooldown) {
      // Creates new PVector properties with starting velocity
      PVector loc = new PVector(location.x, location.y);
      PVector vel = new PVector(0, projSpeed);
       
      // Adds alien velocity and location to PVectors
      vel.add(velocity);
      if (ship != null) {
        float y = ship.location.y - loc.y;
        float x = ship.location.x - loc.x;
        float angle = atan2(y, x);
        vel.rotate(angle - radians(90));
      }
      
      // Initializes Projectile instance in array
      Projectile alienShot = new Projectile(loc, vel, false);
      projectiles.add(alienShot);
      
      // Resets cooldown
      timeLastShot = millis();
    }
    // Update location
    location.add(velocity);
    return false;
  }

  /************************************************************************
  * Function: display()
  * Parameters: None ()
  * Returns: void
  * Desc: Draws the alien to the screen
  ************************************************************************/
  void display() {
    pushMatrix();
      translate(location.x, location.y);
      rotate(radians(rotation));
      fill(0);
      strokeWeight(1);
      shape(alien);
    popMatrix();
  }
  
  /************************************************************************
  * Function: collide()
  * Parameters: PVector l (location of object colliding with)
  *             float r (radius of object colliding with)
  * Returns: boolean
  * Desc: Detects collision between this object, and another object with
  *   radius r.
  ************************************************************************/
  boolean collide(PVector l, float r) {
    if (dist(l.x, l.y, location.x, location.y) < radius + r)
      return true;
    return false;
  }
}

/**************************************************************************
* Class: Projectile
**************************************************************************/
class Projectile extends OnScreenObject implements Visible {
  /* Declare Projectile object properties */
  float timer, maxAge;
  boolean canDestroyPlayer = false;
  boolean canDestroyAsteroid = true;
  boolean canDestroyAlien = true;
  
  /************************************************************************
  * Function: Projectile()
  * Parameters: PVector l (location of the projectile)
  *             PVector v (velocity of the projectile)
  *             boolean friendly (whether the projectile can harm the
  *                     player or harm asteroids and aliens)
  * Desc: Constructs projectile object with default values
  ************************************************************************/
  Projectile(PVector l, PVector v, boolean friendly) {
    location = l;
    velocity = v;
    radius = 1;
    timer = 0;
    maxAge = projLife;
    if (!friendly) {
      canDestroyPlayer = true;
      canDestroyAsteroid = false;
      canDestroyAlien = false;
    }
  }
  
  /************************************************************************
  * Function: update()
  * Parameters: None ()
  * Returns: boolean
  * Desc: Updates projectile lifetime, checks for collision with objects
  *   and updates location. If collision occurs, projectile is removed
  ************************************************************************/
  boolean update() {
    // Update projectile properties
    timer++;
    
    // Return true if expired
    if (timer >= maxAge) {
      return true;
    }
    if (canDestroyAsteroid) {
      for (int i = 0; i < asteroids.size(); i++) {
        Asteroid a = asteroids.get(i);
        if (a.collide(location, radius)) {
          a.active = false;
          if (a.type < 3) {
            PVector impactVelocity = PVector.mult(velocity, 0.2);
            int childAsteroids = 2;
            int type = a.type + 1;
            for (int j = 1 ; j <= childAsteroids; j++) {
              PVector childVelocity = new PVector(a.velocity.x, a.velocity.y);
              childVelocity.rotate(radians(j * (360 / childAsteroids) - 90));
              childVelocity.add(impactVelocity);
              PVector childLocation = new PVector(a.location.x, a.location.y);
              asteroids.add(new Asteroid(childLocation, childVelocity, type));
            }
          }
          spawnParticles(a.location);
          score += 1;
          return true;
        }
      }
    }
    if (canDestroyAlien) {
      for (int k = 0; k < aliens.size(); k++) {
        Alien a = aliens.get(k);
        if (a.collide(location, radius)) {
          a.active = false;
          spawnParticles(a.location);
          score += 5;
          return true;
        }
      }
    }
    if (canDestroyPlayer) {
      if (ship != null) {
        if (ship.collide(location, radius)) {
          ship.die();
          return true;
        }
      }
    }
    // Update location
    location.add(velocity);
    return false;
  }
  
  /************************************************************************
  * Function: display()
  * Parameters: None ()
  * Returns: void
  * Desc: Draws the projectile to the screen
  ************************************************************************/
  void display() {
    fill(255,255,255);
    ellipse(location.x, location.y, radius*2, radius*2);
  }
}

/**************************************************************************
* Class: Particle
**************************************************************************/
class Particle extends OnScreenObject implements Visible {
  /* Declare Particle object properties */
  float timer, maxAge;
  
  /************************************************************************
  * Function: Particle()
  * Parameters: PVector l (location of the particle)
  *             PVector v (velocity of the particle)
  * Desc: Constructs particle object at location with velocity which will
  *   expire after particleLife
  ************************************************************************/
  Particle(PVector l, PVector v) {
    radius = 0.5;
    location = l;
    velocity = v;
    timer = 0;
    maxAge = particleLife;
  }
  
  /************************************************************************
  * Function: update()
  * Parameters: None ()
  * Returns: boolean
  * Desc: Updates particle location if alive, otherwise is removed
  ************************************************************************/
  boolean update() {
    // Update particle life
    timer++;
    
    // Return true if expired
    if (timer >= maxAge) {
      return true;
    }
    // Update location
    location.add(velocity);
    return false;
  }
  
  /************************************************************************
  * Function: display()
  * Parameters: None ()
  * Returns: void
  * Desc: Draws the particle to the screen
  ************************************************************************/
  void display() {
    stroke(255);
    fill(255);
    ellipse(location.x, location.y, radius*2, radius*2);
  }
}

/**************************************************************************
* Class: OnScreenObject
* Desc: Used for all objects that move past the window borders
**************************************************************************/
class OnScreenObject {
  PVector location, velocity;
  float radius;
  
  /************************************************************************
  * Function: checkEdges()
  * Parameters: None ()
  * Returns: void
  * Desc: Checks object positions and move past window edges
  ************************************************************************/
  void checkEdges() {
    // Wraps object within screen space
     if (location.x > width) {
       location.x = 0;
     }
     if (location.x < 0) {
       location.x = width;
     }
     if (location.y > height) {
       location.y = 0;
     }
     if (location.y < 0) {
       location.y = height;
     }
  }
}

/**************************************************************************
* Interfaces
**************************************************************************/

/**************************************************************************
* Interface: Visible
* Desc: Used on visible game objects (all objects that aren't text) that
*   require position updating and displaying
**************************************************************************/
interface Visible {
  boolean update();
  void display();
}

/**************************************************************************
* Interface: Collidable
* Desc: Used on collidable objects like ship, alien and asteroid that
*   require collision detection
**************************************************************************/
interface Collidable {
  boolean collide(PVector l, float r);
}
