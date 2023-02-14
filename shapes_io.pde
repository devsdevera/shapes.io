
// Name: Emmannuel De Vera
// Username:  Deveremma
// StudentID:  300602434
// Project:  Tanks.io

//PImage bg;
PImage menu;
PImage over;
PImage paused;

float time = 0;
float totalXP;
boolean up, down, left, right;
int opponentCount = 0;

// Adjust the frameRate Accordingly to match computer

int frameR = 60;
float m = 1.0 / (frameR / 240.0);

float radian, radianX, radianY, hori, vert;
float cursorX, cursorY, displacementX, displacementY;

ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Bullet> dysfunctionalBullets = new ArrayList<Bullet>();

ArrayList<Particle> particles = new ArrayList<Particle>();
ArrayList<Particle> dysfunctionalParticles = new ArrayList<Particle>();

ArrayList<Square> squares = new ArrayList<Square>();
ArrayList<Pentagon> pentagons = new ArrayList<Pentagon>();
ArrayList<Hexagon> hexagons = new ArrayList<Hexagon>();
ArrayList<Opponent> opponents = new ArrayList<Opponent>();

ArrayList<Square> destroyedSquares = new ArrayList<Square>();
ArrayList<Pentagon> destroyedPentagons = new ArrayList<Pentagon>();
ArrayList<Hexagon> destroyedHexagons = new ArrayList<Hexagon>();
ArrayList<Opponent> destroyedOpponents = new ArrayList<Opponent>();

float squareRate, pentagonRate, hexagonRate;
float modulo;

String state = "menu";
boolean showChart = false;

// Global Objects

Protagonist p;
Chart c;


void admin(){
  
    squares.clear();
    pentagons.clear();
    hexagons.clear();
  
    opponents.clear();
    bullets.clear();
    particles.clear();
    opponentCount = 0;
    
    //totalXP = 0;
    
    c = new Chart(300, height * (1.0 / 4.0) - 50);
    p = new Protagonist(width / 2, height / 2, c);
    
    for (int i = 0; i < 3; i++ ) squares.add(new Square(int(random(0, width)), int(random(0, height)), squares.size()));
    for (int i = 0; i < 2; i++ ) pentagons.add(new Pentagon(int(random(0, width)), int(random(0, height)), pentagons.size()));
    for (int i = 0; i < 1; i++ ) hexagons.add(new Hexagon(int(random(0, width)), int(random(0, height)), hexagons.size()));
}

void setup(){ 
  if (m > 1) m -= 1;  // special 240 fps condition
  
  size(1260, 720);
  frameRate(frameR);
  noStroke();
  ellipseMode(CENTER);
  
  //bg = loadImage("2.png");
  menu = loadImage("menu.png");
  over = loadImage("over.png");
  paused = loadImage("paused.png");
  
  admin();
}


void draw(){
  
  // STATES
  
  if (state == ("menu")) background(menu);
  else if (state == "paused-j" || state == "paused-e") background(paused);
  else if (state == "dead-j" || state == "dead-e"){ 
    background(over); 
    fill(0); 
    text(totalXP, width / 2, height / 2 + 20);
  }
  else if (state == "gameplay-j" || state == "gameplay-e"){
    
    background(255);
     //background(255); image(bg, -(p.returnXpos() - (width / 2)), -(p.returnYpos() - (height / 2)));    // uncomment if you want slow fps
     
    //text(p.ePoints, 100, 100);
      
      fill(0);
      //text(m, 100, 100);
      time += (1.0 / frameR);
      
      if (p.returnHealth() <= 0) {
        if (state == "gameplay-j") state = "dead-j";
        else if(state == "gameplay-e") state = "dead-e";
      }
      
      // HEALTH REGENERATION OVERTIME
      if ((int) modulo < p.returnHealthRegen()) modulo ++; 
      else modulo = p.incrementHealth();
      
      
      // OPPONENT SPAWN && FIRE RATE
      
      // BulletSpeed  1,  BulletDamage  10.0, Bullet Distance  50,  movementSpeed  1, 
      //Range (range to get close to player) 300, Sight 500, MaxHealth  1000, Bullet Reload  0.4
      
      if(p.returnLevel() >= 15 && opponentCount == 1){opponents.add(new Opponent(width - 100, height - 100, 
      3, 7,  20, 40,   50, 100,   0.5, 0.5,  300, 600,  3000, 3000,   1000, 3000,   2, 2,  1)); opponentCount++;}
      
      if(p.returnLevel() == 5 && opponentCount == 0){opponents.add(new Opponent(100, 100, 
      1, 2,   20, 20,    40, 60,   1, 1.5,    300, 300,   500, 500,    1000, 3000,     0.5, 0.1,  1));opponentCount++;}
      
      if(p.returnLevel() >= 5 && opponentCount == 0){opponents.add(new Opponent(100, 100, 
      1, 2,   20, 5,    40, 60,   1, 1.5,    300, 300,   500, 500,    1000, 3000,     0.5, 0.1,  3));opponentCount++;}
      
      
      playerMovement();
      shapeGenerator();
    
      pBulletHits();
      
      for (Bullet b : bullets){
        if (sqrt(sq(p.returnXpos() - b.returnXpos()) + sq(p.returnYpos() - b.returnYpos())) <= 55 && b.protagonist == false){ 
          if (p.returnBulletHistory().contains(b)){} else {
            p.getBullet(b);
            p.shove(b.bulletDamage);
            particles.add(new Particle(p.returnXpos(), p.returnYpos(), p.returnColor(), 5));
          }
        }
      }
      
   
      // TEMPORARY BULLETS AND TEMPORARY EXPLOSION ANIMATION
      
      for (Particle g : particles) if (g.returnParticleDistance() >= 50)dysfunctionalParticles.add(g);
      
      destroyedObjects();
      
      // DISPLAY ALL THE OBJECTS CURRENTLY STILL THERE
     
      if (p.ePoints <= 0){
      
      pushMatrix();
      translate(-(p.returnXpos() - (width / 2)), -(p.returnYpos() - (height / 2)));  // THIS IS THE TRANSLATION TO MAKE UNIVERSE MOVE
      
      for (Bullet b : bullets)b.display();
      for (Square s : squares)s.display();
      for (Pentagon f : pentagons)f.display();
      for (Hexagon h : hexagons)h.display();
      for (Opponent o : opponents)o.display();
      
      p.display();
      for (Particle g : particles)g.display();
      
      popMatrix();
    }
    
    p.hud();
    c.display();
    
    fill(230);
    rect(20, 20, 10, 30);
    rect(35, 20, 10, 30);
    
  }
}

void shapeGenerator(){
  // RANDOM OBJECT GENERATOR
  
  if (int(random(0, 1200 * 0.3)) == 69){
    if (squares.size() <= 10){
      squares.add(new Square(int(random(0, width)), int(random(0, height)), squares.size()));
    }
  }
  if (int(random(0, 1200 * 0.3)) == 69){
    if (pentagons.size() <= 10){
      pentagons.add(new Pentagon(int(random(0, width)), int(random(0, height)), pentagons.size()));
    }
  }
  if (int(random(0, 1200 * 0.3)) == 69){
    if (hexagons.size() <= 10){
      hexagons.add(new Hexagon(int(random(0, width)), int(random(0, height)), hexagons.size()));
    }
  }
}

// PLAYER MOVEMENT FUNCTION - ACCELERATION
void playerMovement(){
  if (up == true) p.up();
  if (down == true) p.down();
  if (left == true) p.left();
  if (right == true) p.right();
  if (up == false) p.upFalse();
  if (down == false) p.downFalse();
  if (left == false) p.leftFalse();
  if (right == false) p.rightFalse(); 
}


void pBulletHits(){
  // WHEN PLAYER BULLETS HIT THE OBJECTS
  
  for (Square s : squares) s.getHealthSubtractor(p.returnBulletSubtractor());
  for (Pentagon f : pentagons) f.getHealthSubtractor(p.returnBulletSubtractor());
  for (Hexagon h : hexagons) h.getHealthSubtractor(p.returnBulletSubtractor());
  for (Opponent o : opponents) o.getHealthSubtractor(p.returnBulletSubtractor());
    
}


void destroyedObjects(){
  
  // REMOVE THE DESTROYED OBJECTS FROM THEIR ARRAYLIST
    
  for (Square s : destroyedSquares){
    particles.add(new Particle(s.returnXpos() + 15, s.returnYpos() + 15, s.returnColor(), 10));
    squares.remove(s); 
    if (s.protagonist) p.incrementXP(s.returnXP());
  }
  for (Pentagon f : destroyedPentagons){
    particles.add(new Particle(f.returnXpos(), f.returnYpos(), f.returnColor(), 10));
    pentagons.remove(f); 
    if (f.protagonist) p.incrementXP(f.returnXP());
  }
  for (Hexagon h : destroyedHexagons){
    particles.add(new Particle(h.returnXpos(), h.returnYpos(), h.returnColor(), 10));
    hexagons.remove(h); 
    if (h.protagonist) p.incrementXP(h.returnXP());
  }
  for (Opponent o : destroyedOpponents){
    particles.add(new Particle(o.returnX() + 15, o.returnY() + 15, o.returnColor(), 40));
    opponents.remove(o); 
    p.incrementXP(3000);
    
    if (int(random(1, 3)) == 1){    // 50/50 either sprayer or sniper class
      if (p.returnLevel() >= 10){
        opponents.add(new Opponent(int(random(0, width)), int(random(0, height)), 
        3, 5,  20, 40,   50, 100,   0, 0,  300, 100,  3000, 3000,   1000, 3000,   2, 2,  int(random(1, 5))));  // different types
      } else{
        opponents.add(new Opponent(int(random(0, width)), int(random(0, height)), 
        3, 5,  20, 40,   50, 100,   0, 0,  300, 100,  3000, 3000,   1000, 3000,   2, 2,  1));
      }
    }
    else {
      if (p.returnLevel() >= 10){
        opponents.add(new Opponent(100, 100, 
        1, 2,   20, 8,    40, 60,   1, 1.5,    300, 300,   500, 500,    1000, 3000,   0.5, 0.1,  int(random(1, 5))));
      } else{
        opponents.add(new Opponent(100, 100, 
        1, 2,   20, 8,    40, 60,   1, 1.5,    300, 300,   500, 500,    1000, 3000,   0.5, 0.1,  1));  // standard class if lower level
      }
    }
  }
  
  for (Particle g : dysfunctionalParticles)particles.remove(g);
  for (Bullet b : dysfunctionalBullets)bullets.remove(b);
  
  dysfunctionalBullets.clear();
  dysfunctionalParticles.clear();
  destroyedSquares.clear();
  destroyedPentagons.clear();
  destroyedHexagons.clear();
  destroyedOpponents.clear();
  
}


boolean upgradeStats(int n){
  
  return(cursorX > c.returnStatLeft() && cursorX < c.returnStatRight() && cursorY > c.returnStatTop() + n && 
  cursorY < c.returnStatBottom() + n && p.returnPoints() >= 1);
  
}

void mouseReleased(){
  
  cursorX = mouseX;
  cursorY = mouseY;
  
  // FSM STATE TRANSITIONS FROM MOUSE RELEASED INPUTS
  
  if (state == "menu"){
    if (cursorX >= 195 && cursorX <= 604 && cursorY >= 226 && cursorY <= 619){    // refer to canva ruler
      state = "gameplay-j";
    }
    
    if (cursorX >= 647 && cursorX <= 1056 && cursorY >= 226 && cursorY <= 619){
      state = "gameplay-e";
      p.level = 30;
      p.ePoints = 30;
      c.showChart = true;
    }
  }
  else if (state == "paused-e"){
    if (cursorX >= 370 && cursorX <= 895 && cursorY >= 449 && cursorY <= 510) state = "gameplay-e";
    else if (cursorX >= 370 && cursorX <= 895 && cursorY >= 537 && cursorY <= 599) {state = "menu"; admin(); }
  }
  else if (state == "paused-j"){
    if (cursorX >= 370 && cursorX <= 895 && cursorY >= 449 && cursorY <= 510) state = "gameplay-j";
    else if (cursorX >= 370 && cursorX <= 895 && cursorY >= 537 && cursorY <= 599) {state = "menu"; admin(); }
  }
  else if (state == "dead-j"){
    admin();
    
    if (cursorX >= 370 && cursorX <= 895 && cursorY >= 449 && cursorY <= 510) state = "gameplay-j";
    else if (cursorX >= 370 && cursorX <= 895 && cursorY >= 537 && cursorY <= 599)state = "menu";
  }
  
  else if (state == "dead-e"){
     admin();
    
    if (cursorX >= 370 && cursorX <= 895 && cursorY >= 449 && cursorY <= 510){    // refer to canva ruler
      p.level = 30;
      p.ePoints = 30;
      state = "gameplay-e";
      c.showChart = true;
    }
    else if (cursorX >= 370 && cursorX <= 895 && cursorY >= 537 && cursorY <= 599) state = "menu";
  }
  else if (state == "gameplay-e" || state == "gameplay-j"){
    
    if (mouseButton == LEFT) {
      
      if (state == "gameplay-e"){
        if (cursorX >= 0 && cursorX <= 50 && cursorY >= 0 && cursorY <= 50) state = "paused-e";
      }
      if (state == "gameplay-j"){
        if (cursorX >= 0 && cursorX <= 50 && cursorY >= 0 && cursorY <= 50) state = "paused-j";
      }
    
      // SHOW AND HIDE THE UPGRADE CHART
      
      if (cursorX > c.returnTabLeft() && cursorX < c.returnTabRight() && 
      cursorY > c.returnTabTop() && cursorY < c.returnTabBottom() && c.returnShowChart() == true) c.hideChart();
      else if (cursorX > c.returnTabLeft() && cursorX < c.returnTabRight() && 
      cursorY > c.returnTabTop() && cursorY < c.returnTabBottom() && c.returnShowChart() == false)c.showChart(p.returnPoints());
      
      
      // UPGRADE THE STATS (COULD DO WHEN RELEASED)
      
      if (upgradeStats(10) && c.returnMaxHealthPoints() < 15){
        c.incrementMaxHealth();
        p.incrementMaxHealth();
        if (state == "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
      if (upgradeStats(44) && c.returnHealthRegenPoints() < 15){
        c.incrementHealthRegen();
        p.incrementHealthRegen();
        if (state == "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
      if (upgradeStats(78) && c.returnBulletSpeedPoints() < 15){
        c.incrementBulletSpeed();
        p.incrementBulletSpeed();
        if (state == "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
      if (upgradeStats(112) && c.returnBulletDamagePoints() < 15){
        c.incrementBulletDamage();
        p.incrementBulletDamage();
        if (state == "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
      if (upgradeStats(146) && c.returnBulletDistancePoints() < 15){
        c.incrementBulletDistance();
        p.incrementBulletDistance();
        if (state == "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
      if (upgradeStats(180) && c.returnBodyDamagePoints() < 15){
        c.incrementBodyDamage();
        p.incrementBodyDamage();
        if (state == "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
      if (upgradeStats(214) && c.returnMovementSpeedPoints() < 15){
        c.incrementMovementSpeed();
        p.incrementMovementSpeed();
        if (state == "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
    }
  }
}

void barrelAim(){
  cursorX = mouseX;
  cursorY = mouseY;
  
  // FIND THE X AND Y DISPLACEMENT
  
  if(cursorX < (width / 2)){
    displacementX = (width / 2) - cursorX;
  }else if(cursorX > (width / 2)){
    displacementX = cursorX - (width / 2);
  }
  if(cursorY < (height / 2)){
    displacementY = (height / 2) - cursorY;
  }else if(cursorY > (height / 2)){
    displacementY = cursorY - (height / 2);
  }
  // TURN THE RISE AND THE RUN INTO AN ANGLE IN RADIANS
  
  radianX = (displacementX * PI) / 180;
  radianY = (displacementY * PI) / 180;
  radian = atan(radianY / radianX);
  
  // ARCTAN IS USED TO FIND THE UNIVERSAL ANGLE IN RADIANS
  // RIGHT IS COS ANGLE IN RADIANS
  // UP IS SIN ANGLE IN RADIANS
  
  if (cursorX > (width / 2) && cursorY > (height / 2)){ hori = cos(radian);  vert = sin(radian);}                // RIGHT BOTTOM
  if (cursorX > (width / 2) && cursorY < (height / 2)){ hori = cos(radian);  vert = sin(radian + (PI));}         // RIGHT TOP
  if (cursorX < (width / 2) && cursorY > (height / 2)){ hori = cos(radian + (PI));  vert = sin(radian);}         // LEFT BOTTOM
  if (cursorX < (width / 2) && cursorY < (height / 2)){ hori = cos(radian + (PI));  vert = sin(radian + (PI));}  // LEFT TOP
  
  p.getHori(hori);
  p.getVert(vert);
  
}

void mousePressed(){
  
  // SHOOT A NEW BULLET IN DIRECTION OF BARREL
  
  bullets.add(new Bullet(60, p.returnX(), p.returnY(), p.returnHori(), 
  p.returnVert(), p.returnBulletSpeed(), p.returnBulletDamage(), p.returnBulletColor(), true));
  p.getHoriOpp(cos(acos(p.returnHori()) + PI));
  p.getVertOpp(sin(asin(p.returnVert()) + PI));
  
}

void mouseMoved(){
  // WHEN MOUSE IS MOVED, MOVE THE BARREL
  
  barrelAim();
}

void mouseDragged(){
  // WHEN MOUSE IS DRAGGED, MOVE THE BARREL
  
    barrelAim();
}

void keyPressed() {
  // SPATIAL MOVEMENT WASD
  
  if (key == 'w') up = true;
  if (key == 'a') left = true;
  if (key == 's') down = true;
  if (key == 'd') right = true;
}

void keyReleased() {
  // SPATIAL MOVEMENT WASD  
  
  if (key == 'w') up = false;
  if (key == 'a') left = false;
  if (key == 's') down = false;
  if (key == 'd') right = false;
}












class Bullet {
  
  float bulletAngle;
  float bulletSpeed;
  float bulletDamage;
  float bulletDistance;
  float bulletPenetration;
  
  float startX;
  float startY;
  float hori;
  float vert;
  
  float xpos;
  float ypos;
  color colour;
  
  float dist;
  
  boolean protagonist;
  
  
  // Contructor
  Bullet(float B, float X, float Y, float H, float V, float S, float D, color C, boolean P) {
    
    bulletAngle = B;
    startX = X;
    startY = Y;
    hori = H;
    vert = V;
    bulletSpeed = S * m;
    bulletDamage = D;
    colour = C;
    protagonist = P;
  }
  
  Bullet(float B, float X, float Y, float H, float V, float S, float D, color C, float BD, boolean P) {
    
    bulletAngle = B;
    startX = X;
    startY = Y;
    hori = H;
    vert = V;
    bulletSpeed = S * m;
    bulletDamage = D;
    colour = C;
    protagonist = P;
    
    dist = BD;
  }
  
  
  // Custom method for updating the variables
  void getHori(float H){hori = H;}
  void getVert(float V){vert = V;}
  
  
  // Custom method for returning Variables
  float returnXpos(){return xpos;}
  float returnYpos(){return ypos;}
  float returnBulletDamage(){ return bulletDamage;}
  float returnBulletDistance(){ return bulletDistance; }
  float returnHori() { return hori; }
  float returnVert() { return vert; }
  
  boolean returnProtagonist() { return protagonist; }
  
  
  // Custom method for drawing the object
  void display() {
    
    if (this.returnProtagonist() == true){
      if (this.returnBulletDistance() >= p.returnBulletDistance()) dysfunctionalBullets.add(this);
   }
   
   if (this.returnProtagonist() == false){
      if (this.returnBulletDistance() >= dist)dysfunctionalBullets.add(this);
    }
    
    // WHEN BULLET HITS A SQUARE
    
    for (Square s : squares){
      if (s.returnHit() == false && this.returnXpos() > s.returnXpos() &&
          this.returnXpos() < (s.returnXpos() + s.returnWidth()) &&
          this.returnYpos() > s.returnYpos() &&
          this.returnYpos() < (s.returnYpos() + s.returnWidth())){
        
        s.hit(bulletDamage, this.returnHori(), this.returnVert(), this.protagonist);
        particles.add(new Particle(s.returnXpos() + 15, s.returnYpos() + 15, s.returnColor(), 2));
      }
      if (s.returnHealth() <= 0)if (destroyedSquares.contains(s)){} else {destroyedSquares.add(s);}
    }
    
    // WHEN BULLET HITS A PENTAGON
    
    for (Pentagon f : pentagons){
      if (sqrt(sq(this.returnXpos() - f.returnXpos()) + sq(this.returnYpos() - f.returnYpos())) <= 25 && f.returnHit() == false){ 
        f.hit(bulletDamage, this.returnHori(), this.returnVert(), this.protagonist);
        particles.add(new Particle(f.returnXpos(), f.returnYpos(), f.returnColor(), 2));
      }
      if (f.returnHealth() <= 0)if (destroyedPentagons.contains(f)){} else {destroyedPentagons.add(f);}
    }
    
    // WHEN BULLET HITS A HEXAGON
    
    for (Hexagon h : hexagons){
      if (sqrt(sq(this.returnXpos() - h.returnXpos()) + sq(this.returnYpos() - h.returnYpos())) <= 25 && h.returnHit() == false){ 
        h.hit(bulletDamage, this.returnHori(), this.returnVert(), this.protagonist);
        particles.add(new Particle(h.returnXpos(), h.returnYpos(), h.returnColor(), 2));
      }
      if (h.returnHealth() <= 0)if (destroyedHexagons.contains(h)){} else {destroyedHexagons.add(h);}
    }
    
    // WHEN BULLET HITS AN OPPONENT
    
    for (Opponent o : opponents){
      if (sqrt(sq(o.returnX() - this.returnXpos()) + sq(o.returnY() - this.returnYpos())) <= 55 && this.protagonist == true){ 
        if (o.returnBulletHistory().contains(this)){} else {
          o.getBullet(this);
          o.shove(bulletDamage);
          particles.add(new Particle(o.returnX(), o.returnY(), o.returnColor(), 5));
        }
      }
      if (o.returnHealth() <= 0)if (destroyedOpponents.contains(o)){} else {destroyedOpponents.add(o);}
    }
    
    // MOVE THE BULLET IN THE ANGLE IT WAS SHOT AT
    
    xpos = (width / 2) + startX + (hori * bulletAngle);
    ypos = (height / 2)+ startY + (vert * bulletAngle);
    
    fill(20); ellipse(xpos, ypos + 5, 20, 20);
    bulletAngle += bulletSpeed;
    
    fill(colour); ellipse(xpos, ypos, 20, 20);
    fill(colour); ellipse(xpos, ypos, 20 - 7, 20 - 7);
    
    bulletAngle += bulletSpeed;
    bulletDistance += 1;
    
  }
}










class Chart {
  
  float rightX = 0;
  float topY = height * (3.0 / 4.0) - 80;
  
  boolean showChart;
  int points;
  
  float chartWidth;
  float chartHeight;
  float statHeight;
  float statWidth;
  
  float maxHealthPoints = 1;
  float healthRegenPoints = 1;
  float bulletSpeedPoints = 1;
  float bulletDamagePoints = 1;
  float bulletDistancePoints = 1;
  float movementSpeedPoints = 1;
  float bodyDamagePoints = 1;
  
  float tabLeft = 0;
  float tabRight = tabLeft + 10;
  float tabTop = topY;
  float tabBottom = topY + (height * (1.0 / 4.0) - 20);
  
  PFont font1;
  PFont font2;
  
  
  // Contructor
  Chart(float W, float H) {
    
    chartWidth = W;
    chartHeight = H + 100;
    tabBottom = tabTop + H;
    statHeight = H / 6.0;
    statWidth = W - 60;
    
  }
  
  void showChart(int P){ showChart = true; points = P;}
  void hideChart(){ showChart = !true;}
  
  
  void incrementMaxHealth(){ maxHealthPoints ++; }
  void incrementHealthRegen(){ healthRegenPoints ++; }
  void incrementBulletSpeed(){ bulletSpeedPoints ++; }
  void incrementBulletDamage(){ bulletDamagePoints ++; }
  void incrementBulletDistance(){ bulletDistancePoints ++; }
  void incrementBodyDamage(){ bodyDamagePoints ++; }
  void incrementMovementSpeed(){ movementSpeedPoints ++; }
  
  
  boolean returnShowChart(){ return showChart; }
  float returnTabLeft() { return tabLeft; }
  float returnTabRight() { return tabLeft + 20; }
  float returnTabTop() { return tabTop; }
  float returnTabBottom() { return tabBottom + 100; }
  float returnStatLeft(){ return rightX - chartWidth + 20; }
  float returnStatRight(){ return rightX - chartWidth + 20 + statWidth; }
  float returnStatTop(){ return topY + 0; }  // MUST INSERT THE HEIGHT VALUES REPLACE 0
  float returnStatBottom(){ return topY + statHeight + 0; }
  
  
  
  float returnMaxHealthPoints() { return maxHealthPoints; }
  float returnHealthRegenPoints() { return healthRegenPoints; }
  float returnBulletSpeedPoints() { return bulletSpeedPoints; }
  float returnBulletDamagePoints() { return bulletDamagePoints; }
  float returnBulletDistancePoints() { return bulletDistancePoints; }
  float returnMovementSpeedPoints() { return movementSpeedPoints; }
  float returnBodyDamagePoints() { return bodyDamagePoints; }
  
  
  void customFont(String text, float X, float Y, int outline, int fill){
    for(int x = -outline; x < outline; x++){
      for (int y = -3; y < 3; y++){
        text(text, X + x,  Y + y);
      }
    }
    fill(255);
    for(int x = -fill; x < fill; x++){
      for (int y = -1; y < 1; y++){
        text(text, X + x,  Y+ y);
      }
    }
  }
  
  void borderOutline(int y){
    rect(rightX - chartWidth + 20, topY + y, statWidth, statHeight);
    arc(rightX - chartWidth + 20, topY + y + statHeight / 2, statHeight, statHeight, HALF_PI, PI+HALF_PI);
    arc(rightX - chartWidth + 20 + statWidth, topY + y + statHeight / 2, statHeight, statHeight, -HALF_PI, HALF_PI);
  }
  
  void fillStats(int y, float x){
    rect(rightX - chartWidth + 20, topY + y + 4, ((statWidth) * (x / 15.0)), statHeight - 8);
    ellipse(rightX - chartWidth + 20, topY + y + 4 + ((statHeight - 8) / 2), statHeight - 8, statHeight - 8);
    ellipse(rightX - chartWidth + 20 + ((statWidth) * (x / 15.0)), topY + y + 4 + ((statHeight - 8) / 2), statHeight - 8, statHeight - 8);
  }
  
  void display() {
    
    fill(200, 200, 200, 200);
    rect(tabLeft, tabTop, 20, chartHeight);
    arc(tabLeft + 10, tabTop, 20, 20, PI, PI*2);
    arc(tabLeft + 10, tabTop + chartHeight, 20, 20, 0, PI);
    fill(0, 0, 0, 180);
    
    if (showChart == true) {
      if (rightX < (20 + chartWidth)){
        rightX += 2 * m;
        tabLeft += 2 * m;
      }
    } 
    if (showChart == false) {
      if (rightX > 0){
        rightX -= 2 * m;
        tabLeft -= 2 * m;
      }
    }
    // BORDER OUTLINE
    
    borderOutline(10);
    borderOutline(44);
    borderOutline(78);
    borderOutline(112);
    borderOutline(146);
    borderOutline(180);
    borderOutline(214);
    
    // FILL THE STATS
    
    fill(132,237,35);
    fillStats(10, maxHealthPoints);
    
    fill(63,223,199);
    fillStats(44, healthRegenPoints);
    
    fill(113,102,244);
    fillStats(78, bulletSpeedPoints);
    
    fill(255,39,89);
    fillStats(112, bulletDamagePoints);
    
    fill(255,184,78);
    fillStats(146, bulletDistancePoints);
    
    fill(255,67,181);
    fillStats(180, bodyDamagePoints);
    
    fill(203,240,15);
    fillStats(214, movementSpeedPoints);
    
    // ADD TEXTS
    
    textAlign(CENTER);
    //textFont(font1);
    textSize(16);
    fill(255);
    
    text("Maximum Health", rightX - chartWidth + 20 + statWidth / 2,  topY + 10 + statHeight / 2 + 4);
    text("Health Regen", rightX - chartWidth + 20 + statWidth / 2,  topY + 44 + statHeight / 2 + 4);
    text("Bullet Speed", rightX - chartWidth + 20 + statWidth / 2,  topY + 78 + statHeight / 2 + 4);
    text("Bullet Damage", rightX - chartWidth + 20 + statWidth / 2,  topY + 112 + statHeight / 2 + 4);
    text("Bullet Distance", rightX - chartWidth + 20 + statWidth / 2,  topY + 146 + statHeight / 2 + 4);
    text("Body Damage", rightX - chartWidth + 20 + statWidth / 2,  topY + 180 + statHeight / 2 + 4);
    text("Movement Speed", rightX - chartWidth + 20 + statWidth / 2,  topY + 214 + statHeight / 2 + 4);
    
    textSize(30);
    fill(0);
    
    for(float x = -3.3; x < 3.3; x++){
      for (float y = -3.3; y < 3.3; y++){
        text("Points :  " + p.returnPoints(), rightX - chartWidth + 20 + statWidth / 2 + x, topY + 10 + statHeight / 2 + 5 - 34 + y);
      }
    }
    fill(255);
    for(float x = -1.5; x < 1.5; x++){
      for (float y = -1.5; y < 1.5; y++){
        text("Points :  " + p.returnPoints(), rightX - chartWidth + 20 + statWidth / 2 + x, topY + 10 + statHeight / 2 + 5 - 34 + y);
        
      }
    }
  }
}


















class Hexagon {
  
  float maxHealth = 500;
  float health = 500;
  float healthDecrement = 500;
  float healthSubtractor = 1;
  
  int ID;
  int count;
  
  float bulletDamage;
  float damage = 50.0;
  float xp = 800;
  
  float driftX;
  float driftY;
  float drift = 0;
  float acceleration;
  
  float startX;
  float startY;
  
  float radian;
  float degrees;
  float xpos;
  float ypos;
  
  float squareWidth = 30;
  color outline = color(235, 150, 214);
  
  boolean hit = false;
  boolean shove = false;
  boolean showHealthBar = false;
  boolean protagonist;
  
  
  // Contructor
  Hexagon(float X, float Y, int N) {
    
    startX = X;
    startY = Y;
    ID = N;
    radian = radians(int(random(0, 360)));
    driftX = cos(radian);
    driftY = sin(radian);
    
    xpos = startX + (driftX * drift);
    ypos = startY + (driftY * drift);
    
  }
  
  // Custom method for updating the variables
  
  void getHori(float H){hori = H;}
  void getVert(float V){vert = V;}
  void getHealthSubtractor(float V){ healthSubtractor = V;}
  
  void hit(float DMG, float H, float V, boolean P){
    
    hit = true;
    bulletDamage = DMG;
    showHealthBar = true;
    protagonist = P;
    
    driftX = H;
    driftY = V;
    startX = xpos - (driftX * drift);
    startY = ypos - (driftY * drift);
  }
  
  void shove(float DMG, boolean P){
    shove = true;
    bulletDamage = DMG;
    showHealthBar = true;
    protagonist = P;
  }
  
  // Custom methods when Attributes increased
  void incrementMaxHealth(){ }
  void incrementHealthRegen(){ }
  void incrementBulletSpeed(){ }
  void incrementBulletDamage(){ healthSubtractor += 0.5; }
  void incrementBulletDistance(){ }
  void incrementMovementSpeed(){ }
  void incrementBodyDamage(){ }
  
  // Custom method for returning Variables
  float returnXpos(){return xpos;}
  float returnYpos(){return ypos;}
  float returnWidth(){return squareWidth;}
  float returnHealth(){return healthDecrement;}
  float returnDamage(){ return damage;}
  float returnXP(){return xp;}
  int returnID(){return ID;}
  color returnColor(){ return outline;}
  boolean returnHit(){ return hit; }
  
  
  // Custom method for Polygon Drawing (AT CENTER)
  void polygon(float x, float y, float radius, int npoints) {
    float angle = TWO_PI / npoints;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + cos(a) * radius;
      float sy = y + sin(a) * radius;
      vertex(sx, sy);
    }
    endShape(CLOSE);
}
  
  
  // Custom method for drawing the object
  void display() {
    
    xpos = startX + (driftX * drift);
    ypos = startY + (driftY * drift);
    
    // WHEN THE OPPONENTS SHOVE INTO HEXAGONS
    
    for (Opponent o : opponents){
      if (sqrt(sq(o.returnX() - this.returnXpos()) + sq(o.returnY() - this.returnYpos())) <= 60){ 
          this.getHealthSubtractor(100);
          this.shove(o.returnBodyDamage(), false); 
          this.getHealthSubtractor(100);
          o.shove(this.returnDamage());
          //particles.add(new Particle(p.returnXpos() + 15, p.returnYpos() + 15, p.returnColor(), 1));
        }
      if (this.returnHealth() <= 0) destroyedHexagons.add(this);
    }
    
    if (sqrt(sq(p.returnXpos() - this.returnXpos()) + sq(p.returnYpos() - this.returnYpos())) <= 60){ 
      this.getHealthSubtractor(100);
      this.shove(p.returnBodyDamage(), true); 
      p.shove(this.returnDamage());
      //particles.add(new Particle(p.returnXpos() + 15, p.returnYpos() + 15, p.returnColor(), 1));
    }
    if (this.returnHealth() <= 0) destroyedHexagons.add(this);
    
    
    pushMatrix();
    translate(xpos, ypos + 6);
    rotate(degrees(degrees));
    fill(60);    // SHADOW
    polygon(0, 0, squareWidth, 6);
    popMatrix();
    
    if (showHealthBar == true){
      
      // HEALTH BAR OUTLINE
      
      rect(xpos + 2 - 1 - (squareWidth / 2), ypos + 40 - 1, squareWidth + 2, 7);        // need the y -1 for the top outline,  7 height, 5, increment
      ellipse(xpos + 2 - (squareWidth / 2), ypos + 40 - 1 + 3.5, 7, 7);
      ellipse(xpos + 2 + squareWidth - (squareWidth / 2), ypos + 40 - 1 + 3.5, 7, 7);
      
      if (healthDecrement > health){  // DECREMENT THE HEALTHBAR
      
        fill(0, 255, 0);
        rect(xpos + 2 - (squareWidth / 2), ypos + 40, squareWidth * (healthDecrement / maxHealth), 5);
        ellipse(xpos + 2 - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
        ellipse(xpos + 2 + squareWidth * (healthDecrement / maxHealth) - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
        
        healthDecrement -= healthSubtractor * m;    // SOOO CLEAN!!
        
      } else{  // DO NOT MOVE HEALTH BAR
        fill(0, 255, 0);
        rect(xpos + 2 - (squareWidth / 2), ypos + 40, squareWidth * (health / maxHealth), 5);
        ellipse(xpos + 2 - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
        ellipse(xpos + 2 + squareWidth * (health / maxHealth) - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
      }
    }
    
    pushMatrix();
    translate(xpos, ypos);
    rotate(degrees(degrees));
    
    
    if (hit == false && shove == false){    // DRAW REGULAR SQUARE OBJECT
      fill(235, 150, 214);
      polygon(0, 0, squareWidth, 6);
      fill(255, 170, 234);
      polygon(0, 0, squareWidth * 0.8, 6);
    } 
    
    else {
      if (count == 0){
        if (hit == true){ 
          health -= bulletDamage; 
          acceleration += 0.01;
        }
        if (shove == true){
          health -= (bulletDamage * 1000); 
          acceleration += 0.08; 
          healthSubtractor = 50;
        }
      }
      if (count <= 10 / m){    // FLASH RED
        fill(235, 0, 0);   
        polygon(0, 0, squareWidth, 6);
        fill(255, 0, 0);
        polygon(0, 0, squareWidth * 0.8, 6);
      }
      if (count > 10 / m && count <= 20 / m){  // FLASH WHITE
        fill(235); 
        polygon(0, 0, squareWidth, 6);
        fill(2555);
        polygon(0, 0, squareWidth * 0.8, 6);
      }
      if (count < 20 / m){count ++;} 
      else {hit = false; count = 0;}  // END THE HIT STAGE
    }
    
    degrees += 0.00005 * m;
    drift += (0.05 + acceleration) * m;
    popMatrix();
    
  } 
}
















class Opponent {
  
  float maxHealth = 1000;
  float healthDecrement = 1000;
  float health = 1000;
  float healthSubtractor = 1.0;
  float damageTaken = 0;
  float bulletSubtractor = 1.0;
  float size = 80;
  
  int count = 0;
  color outline = color(225, 0, 0);
  color bulletColor = color(255, 0, 0);
  
  float bodyDamage = 20.0;
  float movementSpeed = 1;
  float bulletSpeed = 1;
  float bulletDamage = 10.0;
  float bulletDistance = 50;
  float bulletReload = 0.4;
  float range = 300;
  float sight = 500;
  
  int barrels;
  
  float fireRate;
  
  float startX;
  float startY;
  float dist;
  
  float hori = cos(0);
  float vert = sin(0);
  
  boolean shove;
  boolean showHealthBar;
  boolean showChart;
  boolean inRange;
  
  float a, b, d, e, r, rr, rl, rb, rf;
  float j, k, jr, kr, jl, kl, jb, kb, jf, kf;
  
  Chart c;
  ArrayList<Bullet> bulletsHit = new ArrayList<Bullet>();
  
  // Contructor
  Opponent(float X, float Y) {
    startX = X;
    startY = Y;
    
    bulletSpeed += (p.level * 0.05);
    bulletDamage += (p.level * 0.1);
    movementSpeed += (p.level * 0.01);
    range -= (p.level * 5);
    sight += (p.level * 20);
    maxHealth += (p.level * 100);
    healthDecrement += (p.level * 100);
    health += (p.level * 100);
    bulletReload -= (p.level * 0.005);
    
  }
  
  Opponent(float X, float Y, float BS, float BD, float D, float MS, float R, float S, float MH, float BR) {
    startX = X;
    startY = Y;
    
    bulletSpeed = BS + (p.level * 0.05);
    bulletDamage = abs(BD + (p.level * 0.1));
    bulletDistance = D;
    movementSpeed = MS + (p.level * 0.01);
    range = R - (p.level * 5);
    sight = S + (p.level * 20);
    maxHealth = MH + (p.level * 100);
    healthDecrement = MH + (p.level * 100);
    health = MH + (p.level * 100);
    bulletReload = BR - (p.level * 0.005);
    
  }
  
  
  
  Opponent(float X, float Y, float BS, float BS2, float BD, float BD2, float D, float D2, 
  float MS, float MS2, float R, float R2, float S, float S2, float MH, float MH2, float BR, float BR2, int B) {
    
    startX = X;
    startY = Y;
    bulletSpeed = BS + (p.level * (((BS2 - BS) / 30)));
    bulletDistance = D + (p.level * (((D2 - D) / 30)));
    movementSpeed = MS + (p.level * (((MS2 - MS) / 30)));
    range = R + (p.level * (((R2 - R) / 30)));
    sight = S + (p.level * (((S2 - S) / 30)));
    maxHealth = MH + (p.level * (((MH2 - MH) / 30)));
    healthDecrement = maxHealth;
    health = maxHealth;
    bulletReload = BR + (p.level * (((BR2 - BR) / 30)));
    
    barrels = B;
    
  }
  
  // Custom method for updating the variables
  
  void getHori(float H){hori = H;}
  void getVert(float V){vert = V;}
  
  void getShowChart(boolean S){ showChart = S; }
  void getBullet(Bullet B){ bulletsHit.add(B); }
  void getHealthSubtractor(float V){ healthSubtractor = V;}
  
  void shove(float DMG){
    shove = true;
    damageTaken = DMG;
    showHealthBar = true;
  }
  
  // Custom method for returning Variables
  
  float returnXpos(){return startX - (width / 2);}
  float returnYpos(){return startY - (height / 2);}
  float returnX(){return startX;}
  float returnY(){return startY;}
  float returnHori(){return j;}
  float returnVert(){return k;}
  float returnReload(){ return bulletReload; }
  
  float returnDist(){ return dist; }
  float returnSight(){ return sight; }
  
  boolean returnInRange(){return inRange;}
  ArrayList returnBulletHistory() {return bulletsHit;}
  
  float returnBulletSpeed(){ return bulletSpeed; }
  float returnBulletDistance(){ return bulletDistance; }
  float returnBulletDamage(){ return bulletDamage; }
  float returnBodyDamage(){ return bulletDamage; }
  float returnBulletSubtractor(){ return bulletSubtractor; }
  float returnHealth(){ return healthDecrement; }
  
  color returnColor(){ return outline;}
  color returnBulletColor() { return bulletColor; }
  
  
  // Custom method for drawing the object
  void display() {
    
    
    if ((int) fireRate < this.returnReload() * 60){
        fireRate ++; 
      } else{
        fireRate = 0;
        if (this.returnDist() < this.returnSight()){
          
          if (barrels == 1){
            bullets.add(new Bullet(60, this.returnXpos(), this.returnYpos(), -(this.returnHori()), -(this.returnVert()), 
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
          }
          
          else if (barrels == 2){
            bullets.add(new Bullet(60, this.returnXpos(), this.returnYpos(), -(this.returnHori()), -(this.returnVert()), 
          this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
          
            bullets.add(new Bullet(60, this.returnXpos(), this.returnYpos(), -jb, -kb, 
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
          }
          else if (barrels == 3){
            bullets.add(new Bullet(60, this.returnXpos(), this.returnYpos(), -(this.returnHori()), -(this.returnVert()), 
          this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
            
            bullets.add(new Bullet(60, this.returnXpos(), this.returnYpos(), -jr, -kr, 
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
            
            bullets.add(new Bullet(60, this.returnXpos(), this.returnYpos(), -jl, -kl, 
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
          }
          else if (barrels == 4){
            bullets.add(new Bullet(60, this.returnXpos(), this.returnYpos(), -jr, -kr, 
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
            
            bullets.add(new Bullet(60, this.returnXpos(), this.returnYpos(), -jl, -kl, 
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
            
            bullets.add(new Bullet(60, this.returnXpos(), this.returnYpos(), -jb, -kb, 
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
            
            bullets.add(new Bullet(60, this.returnXpos(), this.returnYpos(), -jf, -kf, 
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
          }
        }
      }
    
    
    if (showHealthBar == true){
      fill(0);
      // HEALTH BAR OUTLINE
      rect(startX + 2 - 1 - (size / 2), startY + 60 - 1, size + 2, 7);
      ellipse(startX + 2 - 1 - (size / 2), startY + 60 - 1 + 3.5, 5, 5);
      ellipse(startX + 2 - 1 + size + 2 - (size / 2), startY + 60 - 1 + 3.5, 7, 7);
      
      if (healthDecrement > health){  // DECREMENT THE HEALTHBAR
        fill(0, 255, 0);
        rect(startX + 2 - (size / 2), startY + 60, size * (healthDecrement / maxHealth), 5);
        ellipse(startX + 2 - (size / 2), startY + 60 + 2.5, 5, 5);
        ellipse(startX + 2 + size * (healthDecrement / maxHealth) - (size / 2), startY + 60 + 2.5, 5, 5);
      
        healthDecrement -= healthSubtractor * m;    // SOOO CLEAN!!
        
      } else{  // DO NOT MOVE HEALTH BAR
        fill(0, 255, 0);
        rect(startX + 2 - (size / 2), startY + 60, size * (health / maxHealth), 5);
        ellipse(startX + 2 - (size / 2), startY + 60 + 2.5, 5, 5);
        ellipse(startX - (size / 2) + 2 + (size * (health / maxHealth)), startY + 60 + 2.5, 5, 5);
      }
    }
    
    
  
    if(startX < p.returnXpos()){
      a = p.returnXpos() - startX;
    }else if(startX > p.returnXpos()){
      a = startX - p.returnXpos();
    }
    if(startY < p.returnYpos()){
      b = p.returnYpos() - startY;
    }else if(startY > p.returnYpos()){
      b = startY - p.returnYpos();
    }
    // TURN THE RISE AND THE RUN INTO AN ANGLE IN RADIANS
    
    e = (a * PI) / 180;
    d = (b * PI) / 180;
    
    r = atan(d / e);
    
    // ARCTAN IS USED TO FIND THE UNIVERSAL ANGLE IN RADIANS
    // RIGHT IS COS ANGLE IN RADIANS
    // UP IS SIN ANGLE IN RADIANS
    
    if (barrels == 1){ }
    
    else if (barrels == 2){ 
      rb = r + (radians(180));
    
    }
    else if (barrels == 3){ 
      rr = r + (radians(25));
      rl = r - (radians(25));
    }
    
    else if (barrels == 4){ 
      rr += radians(1);
      rl = rr + radians(90);
      rb = rr + radians(180);
      rf = rr + radians(270);
    }
    
    
    // IF 4, THEN DO NOT TRACK PLAYER, ONLY GO AROUND IN A CIRCLE AT  FAST PACE.
    
    if (startX > p.returnXpos() && startY > p.returnYpos()){  // RIGHT BOTTOM
      j = cos(r);  
      k = sin(r); 
      jr = cos(rr); 
      kr = sin(rr); 
      jl = cos(rl); 
      kl = sin(rl); 
      jb = cos(rb);
      kb = sin(rb);
      jf = cos(rf);
      kf = sin(rf);
    }
    
    if (startX > p.returnXpos() && startY < p.returnYpos()){  // RIGHT TOP
      j = cos(r);  
      k = sin(r + (PI)); 
      jr = cos(rr); 
      kr = sin(rr + (PI)); 
      jl = cos(rl); 
      kl = sin(rl + (PI)); 
      jb = cos(rb);
      kb = sin(rb + (PI));
      jf = cos(rf);
      kf = sin(rf + (PI));
    }
  
    if (startX < p.returnXpos() && startY > p.returnYpos()){  // LEFT BOTTOM
      j = cos(r + (PI));  
      k = sin(r);  
      jr = cos(rr + (PI)); 
      kr = sin(rr); 
      jl = cos(rl + (PI)); 
      kl = sin(rl); 
      jb = cos(rb + (PI));
      kb = sin(rb);
      jf = cos(rf + (PI));
      kf = sin(rf);
    }
    
    if (startX < p.returnXpos() && startY < p.returnYpos()){  // LEFT TOP
      j = cos(r + (PI));  
      k = sin(r + (PI));  
      jr = cos(rr + (PI)); 
      kr = sin(rr + (PI)); 
      jl = cos(rl + (PI)); 
      kl = sin(rl + (PI));  
      jb = cos(rb + (PI));
      kb = sin(rb + (PI));
      jf = cos(rf + (PI));
      kf = sin(rf + (PI));
    }
    
    
    // OPPONENT MOVEMENT AI

    dist = sqrt(sq(p.returnXpos() - startX) + sq(p.returnYpos() - startY));
    
    if (opponents.size() > 1){
      
      for (int i = 0; i < opponents.size(); i ++){
        
        if (opponents.get(i) == this){}  // don't do anything if it is this
        else{
          if (sqrt(sq(opponents.get(i).startX - startX) + sq(opponents.get(i).startY - startY)) <= 500){    // if the difference betweent the two are close
          
            if (dist < sqrt(sq(p.returnXpos() - opponents.get(i).startX) + sq(p.returnYpos() - opponents.get(i).startY))){ 
              if (dist >= range){ 
                startX -= j * movementSpeed * m;    // only the closest to the protagonist is allowed to move
                startY -= k * movementSpeed * m;
                inRange = false;                    // this way they are not stuck
              } else {
                inRange = true;
              }
            }else{    // it is made in the way that only this opponent will be able to move, I cannot make other opponent move. 
              
            }
                  // WORKING ON THIS ATM
          }
          else{
            if (dist >= range){ 
              startX -= j * movementSpeed * m;
              startY -= k * movementSpeed * m;    // otherwise if they are apart, continue to follow the protagonist. 
              inRange = false;
            } else {
              inRange = true;
            }
          }
        }
      }
    } else {
      if (dist >= range){ 
        startX -= j * movementSpeed * m;
        startY -= k * movementSpeed * m;    // otherwise if they are apart, continue to follow the protagonist. 
        inRange = false;
      } else {
        inRange = true;
      }
    }
    
    
    
    
    fill(20);
    ellipse(startX, startY + 5, 80, 80);
    
    if (barrels == 1){
      ellipse(startX - (60 * j), startY - (60 * k) + 5, 20, 20);
    }
    else if (barrels == 2){ 
      ellipse(startX - (60 * j), startY - (60 * k) + 5, 20, 20);
      ellipse(startX - (60 * jb), startY - (60 * kb) + 5, 20, 20);
    }
    else if (barrels == 3){ 
      ellipse(startX - (60 * j), startY - (60 * k) + 5, 20, 20);
      ellipse(startX - (60 * jr), startY - (60 * kr) + 5, 20, 20);
      ellipse(startX - (60 * jl), startY - (60 * kl) + 5, 20, 20);
    }
    else if (barrels == 4){
      ellipse(startX - (60 * jr), startY - (60 * kr) + 5, 20, 20);
      ellipse(startX - (60 * jl), startY - (60 * kl) + 5, 20, 20);
      ellipse(startX - (60 * jb), startY - (60 * kb) + 5, 20, 20);
      ellipse(startX - (60 * jf), startY - (60 * kf) + 5, 20, 20);
    }
    
    
    fill(215, 0, 0);
    ellipse(startX, startY, 80, 80);
    
    if (barrels == 1){
      ellipse(startX - (60 * j), startY - (60 * k), 20, 20);
    }  
    else if (barrels == 2){ 
      ellipse(startX - (60 * j), startY - (60 * k), 20, 20);
      ellipse(startX - (60 * jb), startY - (60 * kb), 20, 20);
    }
    else if (barrels == 3){ 
      ellipse(startX - (60 * j), startY - (60 * k), 20, 20);
      ellipse(startX - (60 * jr), startY - (60 * kr), 20, 20);
      ellipse(startX - (60 * jl), startY - (60 * kl), 20, 20);
    }
    else if (barrels == 4){
      ellipse(startX - (60 * jr), startY - (60 * kr), 20, 20);
      ellipse(startX - (60 * jl), startY - (60 * kl), 20, 20);
      ellipse(startX - (60 * jb), startY - (60 * kb), 20, 20);
      ellipse(startX - (60 * jf), startY - (60 * kf), 20, 20);
    }
    
    fill(255, 0, 0);
    ellipse(startX, startY, 70, 70);
    
    if (barrels == 1){
      ellipse(startX - (60 * j), startY - (60 * k), 15, 15);
    }
    else if (barrels == 2){ 
      ellipse(startX - (60 * j), startY - (60 * k), 15, 15);
      ellipse(startX - (60 * jb), startY - (60 * kb), 15, 15);
    }
    else if (barrels == 3){ 
      ellipse(startX - (60 * j), startY - (60 * k), 15, 15);
      ellipse(startX - (60 * jr), startY - (60 * kr), 15, 15);
      ellipse(startX - (60 * jl), startY - (60 * kl), 15, 15);
      
    }
    else if (barrels == 4){
      ellipse(startX - (60 * jr), startY - (60 * kr), 15, 15);
      ellipse(startX - (60 * jl), startY - (60 * kl), 15, 15);
      ellipse(startX - (60 * jb), startY - (60 * kb), 15, 15);
      ellipse(startX - (60 * jf), startY - (60 * kf), 15, 15);
    }
    
    if (shove == false){    // DRAW REGULAR SQUARE OBJECT
      fill(20);
      ellipse(startX, startY + 5, 80, 80);
      //ellipse(startX - (60 * j), startY - (60 * k) + 5, 20, 20);
      
      fill(215, 0, 0);
      ellipse(startX, startY, 80, 80);
      //ellipse(startX - (60 * j), startY - (60 * k), 20, 20);
      fill(255, 0, 0);
      ellipse(startX, startY, 70, 70);
      //ellipse(startX - (60 * j), startY - (60 * k), 15, 15);
    } 
    
    else {
      if (count == 0){
        if (shove == true){health -= damageTaken;}
      }
      if (count <= 10 / m){    // FLASH RED
        fill(215, 0, 0);
        ellipse(startX, startY, 80, 80);
        ellipse(startX - (60 * j), startY - (60 * k), 20, 20);
        fill(255, 0, 0);
        ellipse(startX, startY, 70, 70);
        ellipse(startX - (60 * j), startY - (60 * k), 15, 15);
      }
      if (count > 10 / m && count <= 20 / m){  // FLASH WHITE
        fill(235); 
        ellipse(startX, startY, 80, 80);
        ellipse(startX - (60 * j), startY - (60 * k), 20, 20);
        fill(255);
        ellipse(startX, startY, 70, 70);
        ellipse(startX - (60 * j), startY - (60 * k), 15, 15);
      }
      if (count < 20 / m){count ++;} else {shove = false; count = 0;}  // END THE HIT STAGE
    }
    
  }
}



  
  
  

class Particle {
  
  float ParticleDistance;
  color c;
  int num;
  
  float startX;
  float startY;
  
  ArrayList<Integer> sizes = new ArrayList<Integer>();
  ArrayList<Float> hori = new ArrayList<Float>();
  ArrayList<Float> vert = new ArrayList<Float>();
  
  
  // Contructor
  Particle(float X, float Y, color C, int N) {
    startX = X;
    startY = Y;
    c = C;
    num = N;
    
    for (int i = 0; i < num; i++){
      sizes.add(int(random(0, 10)));
      hori.add(cos(radians(int(random(0, 360)))));
      vert.add(cos(radians(int(random(0, 360)))));
    }
  }
  
  // Custom method for returning Variables
  float returnParticleDistance(){return ParticleDistance;}
  
  // Custom method for drawing the object
  void display() {
    for (int i = 0; i < sizes.size(); i++){
      
      fill(20, 20, 20, 255 - (ParticleDistance * 5));
      ellipse(startX + (hori.get(i) * ParticleDistance), startY + (vert.get(i) * ParticleDistance) + 3, sizes.get(i), sizes.get(i));
      fill(c);
      ellipse(startX + (hori.get(i) * ParticleDistance), startY + (vert.get(i) * ParticleDistance), sizes.get(i), sizes.get(i));
    }
    ParticleDistance += 1 * m;
  }
}










class Pentagon {
  
  float maxHealth = 300;
  float health = 300;
  float healthDecrement = 300;
  float healthSubtractor = 1;
  
  int ID;
  int count;
  
  float bulletDamage;
  float damage = 30.0;
  float xp = 500;
  
  float driftX;
  float driftY;
  float drift = 0;
  float acceleration;
  
  float startX;
  float startY;
  
  float radian;
  float degrees;
  float xpos;
  float ypos;
  
  float squareWidth = 30;
  color outline = color(66, 116, 179);
  
  boolean hit = false;
  boolean shove = false;
  boolean showHealthBar = false;
  boolean protagonist;
  
  
  // Contructor
  Pentagon(float X, float Y, int N) {
    startX = X;
    startY = Y;
    ID = N;
    
    radian = radians(int(random(0, 360)));
    driftX = cos(radian);
    driftY = sin(radian);
    
    xpos = startX + (driftX * drift);
    ypos = startY + (driftY * drift);
  }
  
  
  // Custom method for updating the variables
  void getHori(float H){hori = H;}
  void getVert(float V){vert = V;}
  void getHealthSubtractor(float V){ healthSubtractor = V;}
  
  void hit(float DMG, float H, float V, boolean P){
    hit = true;
    bulletDamage = DMG;
    showHealthBar = true;
    protagonist = P;
    
    driftX = H;
    driftY = V;
    startX = xpos - (driftX * drift);
    startY = ypos - (driftY * drift);
  }
  
  void shove(float DMG, boolean P){
    shove = true;
    bulletDamage = DMG;
    showHealthBar = true;
    protagonist = P;
  }
  
  // Custom methods when Attributes increased
  void incrementMaxHealth(){ }
  void incrementHealthRegen(){ }
  void incrementBulletSpeed(){ }
  void incrementBulletDamage(){ healthSubtractor  += 0.5; }
  void incrementBulletDistance(){ }
  void incrementMovementSpeed(){ }
  void incrementBodyDamage(){ }
  
  
  // Custom method for returning Variables
  float returnXpos(){return xpos;}
  float returnYpos(){return ypos;}
  float returnWidth(){return squareWidth;}
  float returnHealth(){return healthDecrement;}
  float returnDamage(){ return damage;}
  float returnXP(){return xp;}
  int returnID(){return ID;}
  color returnColor(){ return outline;}
  boolean returnHit(){ return hit; }
  
  
  
  // Custom method for drawing Polygon (At Center)
  void polygon(float x, float y, float radius, int npoints) {
    float angle = TWO_PI / npoints;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + cos(a) * radius;
      float sy = y + sin(a) * radius;
      vertex(sx, sy);
    }
    endShape(CLOSE);
}
  
  
  // Custom method for drawing the object
  void display() {
    
    xpos = startX + (driftX * drift);
    ypos = startY + (driftY * drift);
    
    
    for (Opponent o : opponents){
      if (sqrt(sq(o.returnX() - this.returnXpos()) + sq(o.returnY() - this.returnYpos())) <= 60){ 
        this.getHealthSubtractor(100);
        this.shove(o.returnBodyDamage(), false); 
        this.getHealthSubtractor(100);
        o.shove(this.returnDamage());
        //particles.add(new Particle(p.returnXpos() + 15, p.returnYpos() + 15, p.returnColor(), 1));
      }
      if (this.returnHealth() <= 0) destroyedPentagons.add(this);
    }
    
    if (sqrt(sq(p.returnXpos() - this.returnXpos()) + sq(p.returnYpos() - this.returnYpos())) <= 60){ 
      this.getHealthSubtractor(100);
      this.shove(p.returnBodyDamage(), true); 
      p.shove(this.returnDamage());
      //particles.add(new Particle(p.returnXpos() + 15, p.returnYpos() + 15, p.returnColor(), 1));
    }
    if (this.returnHealth() <= 0) destroyedPentagons.add(this);
    
    
    pushMatrix();
    translate(xpos, ypos + 6);
    rotate(degrees(degrees));
    fill(60);    // SHADOW
    polygon(0, 0, squareWidth, 5);
    popMatrix();
    
    if (showHealthBar == true){
      // HEALTH BAR OUTLINE
      
      rect(xpos + 2 - 1 - (squareWidth / 2), ypos + 40 - 1, squareWidth + 2, 7);        // need the y -1 for the top outline,  7 height, 5, increment
      ellipse(xpos + 2 - (squareWidth / 2), ypos + 40 - 1 + 3.5, 7, 7);
      ellipse(xpos + 2 + squareWidth - (squareWidth / 2), ypos + 40 - 1 + 3.5, 7, 7);
      
      if (healthDecrement > health) {  // DECREMENT THE HEALTHBAR
        fill(0, 255, 0);
        rect(xpos + 2 - (squareWidth / 2), ypos + 40, squareWidth * (healthDecrement / maxHealth), 5);
        ellipse(xpos + 2 - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
        ellipse(xpos + 2 + squareWidth * (healthDecrement / maxHealth) - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
      
        healthDecrement -= healthSubtractor * m;    // SOOO CLEAN!!
        
      } else {  // DO NOT MOVE HEALTH BAR
        fill(0, 255, 0);
        rect(xpos + 2 - (squareWidth / 2), ypos + 40, squareWidth * (health / maxHealth), 5);
        ellipse(xpos + 2 - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
        ellipse(xpos + 2 + squareWidth * (health / maxHealth) - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
      }
    }
    
    pushMatrix();
    translate(xpos, ypos);
    rotate(degrees(degrees));
    
    
    if (hit == false && shove == false){    // DRAW REGULAR SQUARE OBJECT
      fill(66, 116, 179);
      polygon(0, 0, squareWidth, 5);
      fill(86, 136, 199);
      polygon(0, 0, squareWidth * 0.8, 5);
    } 
    
    else {
      if (count == 0){
        if (hit == true){
          health -= bulletDamage; 
          acceleration += 0.02;
        }
        if (shove == true){
          health -= (bulletDamage * 1000); 
          acceleration += 0.08; 
          healthSubtractor = 50;
        }
      }
      if (count <= 10 / m){    // FLASH RED
        fill(235, 0, 0);   
        polygon(0, 0, squareWidth, 5);
        fill(255, 0, 0);
        polygon(0, 0, squareWidth * 0.8, 5);
      }
      if (count > 10 / m && count <= 20 / m){  // FLASH WHITE
        fill(235); 
        polygon(0, 0, squareWidth, 5);
        fill(255);
        polygon(0, 0, squareWidth * 0.8, 5);
      }
      if (count < 20 / m) count ++; 
      else {hit = false; count = 0;}  // END THE HIT STAGE
    }
    
    degrees += 0.00005  * m;
    drift += (0.05 + acceleration)  * m;
    
    popMatrix();
  } 
}

















class Protagonist {
  
  float barrel = 20;

  float healthRegen = 240.0 / m;
  float healing = 1.0;
  float maxHealth = 100;
  float healthDecrement = 100;
  float health = 100;
  float healthSubtractor = 1.0;
  float damageTaken = 0;
  float size = 80;
  
  float bulletSubtractor = 1.0;
  
  int count = 0;
  color outline = color(0, 180, 235);
  color bulletColor = color(0, 200, 255);//color(0, 255, 100);
  
  float bodyDamage = 20.0;
  float reload = 0.5;
  float movementSpeed = 1;
  
  float acceleration = 0.004;
  float velocityX = 0;
  float velocityY = 0;
  
  float bulletSpeed = 1;
  float bulletDamage = 30.0;
  float bulletDistance = 20;
  float recoil = 0.1;
  
  float xp = 0;
  float xpIncrement = 0;
  float xpAdder = 5.0;
  int level = 1;
  float levelRequirements = 1000;
  int points = 0;
  int ePoints = 0;
  
  float startX;
  float startY;
  float x;
  float y;
  float xpos;
  float ypos;
  
  float hori = cos(0);
  float vert = sin(0);
  float horiOpp;
  float vertOpp;
  
  boolean shove;
  boolean showHealthBar;
  boolean showChart;
  ArrayList<Bullet> bulletsHit = new ArrayList<Bullet>();
  
  Chart c;
  
  // Contructor
  Protagonist(float X, float Y, Chart C) {
    startX = X;
    startY = Y;
    c = C;
  }
  
  // Custom method for updating the variables
  void left() {   
    if (velocityX > (-1 * movementSpeed)){ velocityX -= acceleration  * m; }
    x += velocityX * m;}
    
  void right() {
    if (velocityX < movementSpeed){ velocityX += acceleration  * m; }
    x += velocityX * m;}

  void up() {
    if (velocityY > (-1 * movementSpeed)){ velocityY -= acceleration  * m; }
    y += velocityY * m;}
  
  void down() {
    if (velocityY < movementSpeed){ velocityY += acceleration  * m; }
    y += velocityY * m;}
 
 void leftFalse() {   
    if (velocityX < 0){ velocityX += acceleration  * m; }
    x += velocityX * m;}
    
  void rightFalse() {
    if (velocityX > 0){ velocityX -= acceleration  * m; }
    x += velocityX * m;}
  
  void upFalse() {
    if (velocityY < 0){ velocityY += acceleration  * m; }
    y += velocityY * m;}
    
  void downFalse() {
    if (velocityY > 0){ velocityY -= acceleration  * m; }
    y += velocityY * m;}
  
  
  void getHori(float H){hori = H;}
  void getVert(float V){vert = V;}
  void getHoriOpp(float H){horiOpp = H; velocityX += (H * recoil);}
  void getVertOpp(float V){vertOpp = V;  velocityY += (V * recoil);}
  void getShowChart(boolean S){ showChart = S; }
  void incrementXP(float XP){ xp += XP; totalXP += XP;}
  void getBullet(Bullet B){ bulletsHit.add(B); }
  
  
  void incrementMaxHealth(){ 
    if (ePoints <= 0) {points --;} 
    maxHealth += 30;  
    healthDecrement += 30; 
    health += 30; 
    if (points == 0 && ePoints == 0){ c.hideChart(); }
}
  
  void incrementHealthRegen(){ 
    if (ePoints <= 0) {points --;} 
    healthRegen -= 4; 
    healing += 0.1;  
    if (points == 0 && ePoints == 0){ c.hideChart(); }
}

  void incrementBulletSpeed(){ 
    if (ePoints <= 0) {points --;} 
    bulletSpeed += 0.1;  
    if (points == 0 && ePoints == 0){ c.hideChart(); }
}

  void incrementBulletDamage(){ 
    if (ePoints <= 0) {points --;} 
    bulletDamage += 5; 
    bulletSubtractor += 0.5;  
    if (points == 0 && ePoints == 0){ c.hideChart(); }
}

  void incrementBulletDistance(){ 
    if (ePoints <= 0) {points --;} 
    bulletDistance += 4;  
    if (points == 0 && ePoints == 0){ c.hideChart(); }
}

  void incrementMovementSpeed(){ 
    if (ePoints <= 0) {points --;} 
    movementSpeed += 0.04; 
    acceleration += 0.0001;   
    if (points == 0 && ePoints == 0){ c.hideChart(); }
}

  void incrementBodyDamage(){ 
    if (ePoints <= 0) {points --;} 
    bodyDamage += 10;  
    if (points == 0 && ePoints == 0){ c.hideChart(); }
}
  
  
  void shove(float DMG){
    shove = true;
    damageTaken = DMG;
    showHealthBar = true;
  }
  
  // Custom method for returning Variables
  
  float returnXpos(){return xpos;}
  float returnYpos(){return ypos;}
  float returnX(){return x;}
  float returnY(){return y;}
  float returnHori(){return hori;}
  float returnVert(){return vert;}
  
  float returnBulletSpeed(){ return bulletSpeed; }
  float returnBulletDistance(){ return bulletDistance; }
  float returnBulletDamage(){ return bulletDamage; }
  float returnBodyDamage(){ return bulletDamage; }
  float returnHealthRegen() { return healthRegen; }
  float returnBulletSubtractor(){ return bulletSubtractor; }
  float returnReload() { return reload; }
  
  float returnVelocityX() { return velocityX; }
  float returnVelocityY() { return velocityY; }
  
  int returnPoints() { return points + ePoints; }
  color returnColor(){ return outline;}
  color returnBulletColor() { return bulletColor; }
  ArrayList returnBulletHistory() {return bulletsHit;}
  int returnLevel() { return level; }
  float returnHealth(){return healthDecrement;}
  float incrementHealth(){ 
    
    if (health < maxHealth){ 
      if ((health + healing) > maxHealth) { 
        health += (maxHealth - health);
      } else {
      health += healing; }
    } 
    if (health >= maxHealth) {showHealthBar = false; health = maxHealth; }
    return 0;
    
  }
  
  
  // Custom method for drawing the object
  void display() {
    
    xpos = startX + x;
    ypos = startY + y;
    fill(50); ellipse(xpos, ypos + 5, size, size);    // SHADOW
    
    if (showHealthBar == true){
      
      // HEALTH BAR OUTLINE
      rect(xpos + 2 - 1 - (size / 2), ypos + 60 - 1, size + 2, 7);
      ellipse(xpos + 2 - 1 - (size / 2), ypos + 60 - 1 + 3.5, 5, 5);
      ellipse(xpos + 2 - 1 + size + 2 - (size / 2), ypos + 60 - 1 + 3.5, 7, 7);
      
      if (healthDecrement > health){  // DECREMENT THE HEALTHBAR
        fill(0, 255, 0);
        rect(xpos + 2 - (size / 2), ypos + 60, size * (healthDecrement / maxHealth), 5);
        ellipse(xpos + 2 - (size / 2), ypos + 60 + 2.5, 5, 5);
        ellipse(xpos + 2 + size * (healthDecrement / maxHealth) - (size / 2), ypos + 60 + 2.5, 5, 5);
      
        healthDecrement -= 0.2 * m;    // SOOO CLEAN!!
        
      } else{  // DO NOT MOVE HEALTH BAR
        fill(0, 255, 0);
        rect(xpos + 2 - (size / 2), ypos + 60, size * (health / maxHealth), 5);
        ellipse(xpos + 2 - (size / 2), ypos + 60 + 2.5, 5, 5);
        ellipse(xpos - (size / 2) + 2 + (size * (health / maxHealth)), ypos + 60 + 2.5, 5, 5);
      }
    }
    
    if (shove == false){    // DRAW REGULAR SQUARE OBJECT
    
      fill(0, 180, 235); ellipse(xpos, ypos, size, size);
      fill(0, 200, 255); ellipse(xpos, ypos, size - 12, size - 12);
      
      // AIMER
      fill(20); ellipse(xpos + (hori * 60), ypos  + (vert * 60) + 5, barrel * 1, barrel * 1);
      fill(0, 180, 235); ellipse(xpos + (hori * 60), ypos + (vert * 60), barrel * 1, barrel * 1);
      fill(0, 200, 255); ellipse(xpos + (hori * 60), ypos + (vert * 60), barrel * 1 - 6, barrel * 1 - 6);
    } 
    
    if (shove == true){
      
      if (count == 0){ health -= (damageTaken); } // REALLY COOL JUST ONE TIME HIT
      if (count <= 10 / m){    // FLASH RED
        
        fill(235, 0, 0); ellipse(xpos, ypos, size, size);
        fill(255, 0, 0); ellipse(xpos, ypos, size - 12, size - 12);
        
        // AIMER
        fill(20); ellipse(xpos + (hori * 60), ypos  + (vert * 60) + 5, barrel * 1, barrel * 1);
        fill(255, 0, 0); ellipse(xpos + (hori * 60), ypos + (vert * 60), barrel * 1, barrel * 1);
      }
      if (count > 10 / m && count <= 20 / m){  // FLASH WHITE
        
        fill(235); ellipse(xpos, ypos, size, size);
        fill(255); ellipse(xpos, ypos, size - 12, size - 12);
        
        // AIMER
        fill(20); ellipse(xpos + (hori * 60), ypos  + (vert * 60) + 5, barrel * 1, barrel * 1);
        fill(255); ellipse(xpos + (hori * 60), ypos + (vert * 60), barrel * 1, barrel * 1);
      }
      if (count < 20 / m){count ++;} else {shove = false; count = 0;}  // END THE HIT STAGE
    }
  }
  
  void hud(){
    
    // WHEN THE LEVEL UP BAR IS FULL, INCREASE LEVEL AND LEVEL REQUIREMENTS
    
    if (xpIncrement >= levelRequirements){ 
      level ++; points ++; 
      xp -= levelRequirements; 
      xpIncrement = 0; 
      xpAdder += 0.2; 
      levelRequirements += 250; 
      
      if (points >= 1)c.showChart(points);
    }
    
    // DRAW THE LEVEL UP BAR
    
    fill(50, 50, 50, 200);
    rect(width / 2 - 105, height - 50, 210, 30);    // BAR OUTLINE
    arc(width / 2 - 105, height - 50 + 15, 30, 30, HALF_PI, PI+HALF_PI);
    arc(width / 2 + 105, height - 50 + 15, 30, 30, -HALF_PI, HALF_PI);
    
    textSize(30);
    textAlign(CENTER);
    
    // DRAW THE LEVEL TEXT
    
    for(float x = -4; x < 4; x++){
      for (float y = -4; y < 4; y++)text("LEVEL  " + level, (width / 2)+x, height - 60 + y);
    }
    fill(255);
    for(float x = -2; x < 2; x++){
      for (float y = -2; y < 2; y++)text("LEVEL  " + level, (width / 2)+x, height - 60 + y);
    }
    
    // DRAW HOW MUCH EXP PLAYER HAS RELATIVE TO LEVEL BAR LENGTH
    
    if (xpIncrement < xp){
      ellipse(width / 2 - 105, height - 45 + 10, 20, 20);
      rect(width / 2 - 105, height - 45, (200.0 * (xpIncrement / levelRequirements)), 20);
      ellipse((width / 2) - 105 + (200.0 * (xpIncrement / levelRequirements)), height - 45 + 10, 20, 20);
      
      xpIncrement += xpAdder * m;    // SOOO CLEAN!!
      
    } else {
      rect(width / 2 - 105, height - 45, (200.0 * (xp / levelRequirements)), 20);
      ellipse(width / 2 - 105, height - 45 + 10, 20, 20);
      ellipse((width / 2) - 105 + (200.0 * (xp / levelRequirements)), height - 45 + 10, 20, 20);
    }
  }
}



// BONUS CODE

//void upRight() { x += sqrt(movementSpeed /2); y -= sqrt(movementSpeed / 1.2);}
  //void upLeft() { x -= sqrt(movementSpeed /2); y -= sqrt(movementSpeed / 1.2);}
  //void downRight() { x += sqrt(movementSpeed /2); y += sqrt(movementSpeed / 1.2);}
  //void downLeft() { x -= sqrt(movementSpeed /2); y += sqrt(movementSpeed / 1.2);}
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
 class Square {

  float maxHealth = 100;
  float health = 100;
  float healthDecrement = 100;
  float healthSubtractor = 1;
  
  int ID;
  int count;
  
  float bulletDamage;
  float damage = 10.0;
  float xp = 120;
  
  float driftX;
  float driftY;
  float drift = 0;
  float acceleration;
  
  float startX;
  float startY;
  
  float radian;
  float degrees;
  float xpos;
  float ypos;
  
  float squareWidth = 30;
  color outline = color(225, 225, 0);
  
  boolean hit = false;
  boolean shove = false;
  boolean showHealthBar = false;
  boolean protagonist;
  
  
  // Contructor
  Square(float X, float Y, int N) {
    startX = X;
    startY = Y;
    ID = N;
    
    radian = radians(int(random(0, 360)));
    driftX = cos(radian);
    driftY = sin(radian);
    
    xpos = startX + (driftX * drift);
    ypos = startY + (driftY * drift);
  }
  
  
  // Custom method for updating the variables
  void getHori(float H){hori = H;}
  void getVert(float V){vert = V;}
  void getHealthSubtractor(float V){ healthSubtractor = V;}
  
  void hit(float DMG, float H, float V, boolean P){
    hit = true;
    bulletDamage = DMG;
    showHealthBar = true;
    protagonist = P;
    
    driftX = H;
    driftY = V;
    startX = xpos - (driftX * drift);
    startY = ypos - (driftY * drift);
  }
  
  void shove(float DMG, boolean P){
    shove = true;
    bulletDamage = DMG;
    showHealthBar = true;
    protagonist = P;
  }
  
  // Custom methods when Attributes increased
  void incrementMaxHealth(){ }
  void incrementHealthRegen(){ }
  void incrementBulletSpeed(){ }
  void incrementBulletDamage(){ healthSubtractor += 0.5; }
  void incrementBulletDistance(){ }
  void incrementMovementSpeed(){ }
  void incrementBodyDamage(){ }
  
  // Custom method for returning Variables
  
  float returnXpos(){ return xpos;}
  float returnYpos(){ return ypos;}
  float returnWidth(){ return squareWidth;}
  float returnHealth(){ return healthDecrement;}
  float returnDamage(){ return damage;}
  float returnXP(){ return xp;}
  int returnID(){return ID;}
  color returnColor(){ return outline;}
  boolean returnHit(){ return hit; }
  
  
  // Custom method for drawing the object
  
  void display() {
    
    xpos = startX + (driftX * drift);
    ypos = startY + (driftY * drift);
    
    
    for (Opponent o : opponents){
      if (sqrt(sq(o.returnX() - this.returnXpos()) + sq(o.returnY() - this.returnYpos())) <= 60){ 
        this.getHealthSubtractor(100);
        this.shove(o.returnBodyDamage(), false); 
        this.getHealthSubtractor(100);
        o.shove(this.returnDamage());
        //particles.add(new Particle(p.returnXpos() + 15, p.returnYpos() + 15, p.returnColor(), 1));
      }
      if (this.returnHealth() <= 0) destroyedSquares.add(this);
    }
    
    if (sqrt(sq(p.returnXpos() - this.returnXpos()) + sq(p.returnYpos() - this.returnYpos())) <= 60){ 
      this.getHealthSubtractor(100);
      this.shove(p.returnBodyDamage(), true); 
      this.getHealthSubtractor(100);
      p.shove(this.returnDamage());
      //particles.add(new Particle(p.returnXpos() + 15, p.returnYpos() + 15, p.returnColor(), 1));
    }
    if (this.returnHealth() <= 0) destroyedSquares.add(this);
    
    
    
    pushMatrix();
    translate(xpos + 15, ypos + 21);
    rotate(degrees(degrees));
    fill(60);    // SHADOW
    rect(-15, -15, squareWidth, squareWidth);
    popMatrix();
    
    if (showHealthBar == true){
      
      // HEALTH BAR OUTLINE
      
      rect(xpos + 2 - 1, ypos + 40 - 1, squareWidth + 2, 7);        // need the y -1 for the top outline,  7 height, 5, increment
      ellipse(xpos + 2, ypos + 40 - 1 + 3.5, 7, 7);
      ellipse(xpos + 2 + squareWidth, ypos + 40 - 1 + 3.5, 7, 7);
      
      if (healthDecrement > health){  // DECREMENT THE HEALTHBAR
        fill(0, 255, 0);
        rect(xpos + 2, ypos + 40, squareWidth * (healthDecrement / maxHealth), 5);
        ellipse(xpos + 2, ypos + 40 + 2.5, 5, 5);
        ellipse(xpos + 2 + squareWidth * (healthDecrement / maxHealth), ypos + 40 + 2.5, 5, 5);
      
        healthDecrement -= healthSubtractor * m;    // SOOO CLEAN!!
        
      } else{  // DO NOT MOVE HEALTH BAR
        fill(0, 255, 0);
        rect(xpos + 2, ypos + 40, squareWidth * (health / maxHealth), 5);
        ellipse(xpos + 2, ypos + 40 + 2.5, 5, 5);
        ellipse(xpos + 2 + squareWidth * (health / maxHealth), ypos + 40 + 2.5, 5, 5);
      }
    }
    
    pushMatrix();
    translate(xpos + 15, ypos + 15);
    rotate(degrees(degrees));
    
    if (hit == false && shove == false){    // DRAW REGULAR SQUARE OBJECT
      fill(235, 220, 0);
      rect(-15, -15, squareWidth, squareWidth);
      fill(255, 240, 0);
      rect(-15 + (squareWidth * 0.15), -15 + (squareWidth * 0.15), squareWidth * 0.7, squareWidth * 0.7); 
    } 
    
    else {
      if (count == 0){
        if (hit == true){
          health -= bulletDamage; 
          acceleration += 0.03;
        }
        if (shove == true){
          health -= (bulletDamage * 100000); 
          acceleration += 0.08; 
          healthSubtractor = 5000;
        }
      }
      if (count <= 10 / m){    // FLASH RED
        fill(235, 0, 0);   
        rect(-15, -15, squareWidth, squareWidth); 
        fill(255, 0, 0);  
        rect(-15 + (squareWidth * 0.15), -15 + (squareWidth * 0.15), squareWidth * 0.7, squareWidth * 0.7);
      }
      if (count > 10 / m && count <= 20 / m){  // FLASH WHITE
        fill(235); 
        rect(-15, -15, squareWidth, squareWidth); 
        fill(255); 
        rect(-15 + (squareWidth * 0.15), -15 + (squareWidth * 0.15), squareWidth * 0.7, squareWidth * 0.7);
      }
      if (count < 20 / m) count ++; 
      else {hit = false; shove = false; count = 0;}  // END THE HIT STAGE
    }
    
    degrees += 0.0001  * m;
    drift += (0 + acceleration)  * m;
    
    popMatrix();
    
  } 
}
