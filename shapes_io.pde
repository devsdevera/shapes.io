
let menu;
let over;
let paused;

let time = 0;
let totalXP;
let up, down, left, right;
let opponentCount = 0;

// Adjust the frameRate Accordingly to match computer

let frameR = 60;
let m = 1.0 / (frameR / 240.0);

let radian, radianX, radianY, hori, vert;
let cursorX, cursorY, displacementX, displacementY;

let bullets = [];
let dysfunctionalBullets = [];

let particles = [];
let dysfunctionalParticles = [];

let squares = [];
let pentagons = [];
let hexagons = [];
let opponents = [];

let destroyedSquares = [];
let destroyedPentagons = [];
let destroyedHexagons = [];
let destroyedOpponents = [];

let squareRate, pentagonRate, hexagonRate;
let modulo;

let state = "menu";
let showChart = false;

// Global Objects

let p;
let c;

function admin() {
  squares = [];
  pentagons = [];
  hexagons = [];
  
  opponents = [];
  bullets = [];
  particles = [];
  opponentCount = 0;
  
  c = new Chart(300, height * (1.0 / 4.0) - 50);
  p = new Protagonist(width / 2, height / 2, c);
  
  for (let i = 0; i < 3; i++) squares.push(new Square(int(random(0, width)), int(random(0, height)), squares.length));
  for (let i = 0; i < 2; i++) pentagons.push(new Pentagon(int(random(0, width)), int(random(0, height)), pentagons.length));
  for (let i = 0; i < 1; i++) hexagons.push(new Hexagon(int(random(0, width)), int(random(0, height)), hexagons.length));
}

function setup() {
  if (m > 1) m -= 1; // special 240 fps condition

  createCanvas(1260, 720);
  frameRate(frameR);
  noStroke();
  ellipseMode(CENTER);

  //bg = loadImage("2.png");
  menu = loadImage("menu.png");
  over = loadImage("over.png");
  paused = loadImage("paused.png");

  admin();
}

function draw() {
  if (state == "menu") {
    background(menu);
  } else if (state == "paused-j" || state == "paused-e") {
    background(paused);
  } else if (state == "dead-j" || state == "dead-e") { 
    background(over); 
    fill(0); 
    text(totalXP, width / 2, height / 2 + 20);
  } else if (state == "gameplay-j" || state == "gameplay-e") {
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
    if (Math.floor(modulo) < p.returnHealthRegen()) {
      modulo ++;
    } else {
      modulo = p.incrementHealth();
    }
    // OPPONENT SPAWN && FIRE RATE
    // BulletSpeed  1,  BulletDamage  10.0, Bullet Distance  50,  movementSpeed  1, 
    // Range (range to get close to player) 300, Sight 500, MaxHealth  1000, Bullet Reload  0.4
    if (p.returnLevel() >= 15 && opponentCount == 1) {
      opponents.add(new Opponent(width - 100, height - 100, 3, 7, 20, 40, 50, 100, 0.5, 0.5, 300, 600, 3000, 3000, 1000, 3000, 2, 2, 1)); opponentCount++;
    }
    if (p.returnLevel() == 5 && opponentCount == 0) {
      opponents.add(new Opponent(100, 100, 1, 2, 20, 20, 40, 60, 1, 1.5, 300, 300, 500, 500, 1000, 3000, 0.5, 0.1, 1)); opponentCount++;
    }
    if (p.returnLevel() >= 5 && opponentCount == 0) {
      opponents.add(new Opponent(100, 100, 1, 2, 20, 5, 40, 60, 1, 1.5, 300, 300, 500, 500, 1000, 3000, 0.5, 0.1, 3)); opponentCount++;
    }
    playerMovement();
    shapeGenerator();
    pBulletHits();



    for (let b of bullets){
      if (sqrt(sq(p.returnXpos() - b.returnXpos()) + sq(p.returnYpos() - b.returnYpos())) <= 55 && b.protagonist == false){ 
        if (p.returnBulletHistory().includes(b)){} else {
          p.getBullet(b);
          p.shove(b.bulletDamage);
          particles.push(new Particle(p.returnXpos(), p.returnYpos(), p.returnColor(), 5));
        }
      }
    }
    
    // TEMPORARY BULLETS AND TEMPORARY EXPLOSION ANIMATION
    
    for (let g of particles) if (g.returnParticleDistance() >= 50)dysfunctionalParticles.push(g);
    
    destroyedObjects();
    
    // DISPLAY ALL THE OBJECTS CURRENTLY STILL THERE
    
    if (p.ePoints <= 0){
    
    push();
    translate(-(p.returnXpos() - (width / 2)), -(p.returnYpos() - (height / 2)));  // THIS IS THE TRANSLATION TO MAKE UNIVERSE MOVE
    
    for (let b of bullets)b.display();
    for (let s of squares)s.display();
    for (let f of pentagons)f.display();
    for (let h of hexagons)h.display();
    for (let o of opponents)o.display();
    
    p.display();
    for (let g of particles)g.display();
    
    pop();
    }
    
    p.hud();
    c.display();
    
    fill(230);
    rect(20, 20, 10, 30);
    rect(35, 20, 10, 30);
    
  }
}



function shapeGenerator() {
  // RANDOM OBJECT GENERATOR
  
  if (int(random(0, 1200 * 0.3)) == 69){
    if (squares.length <= 10){
      squares.push(new Square(int(random(0, width)), int(random(0, height)), squares.length));
    }
  }
  if (int(random(0, 1200 * 0.3)) == 69){
    if (pentagons.length <= 10){
      pentagons.push(new Pentagon(int(random(0, width)), int(random(0, height)), pentagons.length));
    }
  }
  if (int(random(0, 1200 * 0.3)) == 69){
    if (hexagons.length <= 10){
      hexagons.push(new Hexagon(int(random(0, width)), int(random(0, height)), hexagons.length));
    }
  }
}



// PLAYER MOVEMENT FUNCTION - ACCELERATION
function playerMovement() {
  if (up == true) p.up();
  if (down == true) p.down();
  if (left == true) p.left();
  if (right == true) p.right();
  if (up == false) p.upFalse();
  if (down == false) p.downFalse();
  if (left == false) p.leftFalse();
  if (right == false) p.rightFalse(); 
}

function pBulletHits() {
  // WHEN PLAYER BULLETS HIT THE OBJECTS
  
  for (let s of squares) s.getHealthSubtractor(p.returnBulletSubtractor());
  for (let f of pentagons) f.getHealthSubtractor(p.returnBulletSubtractor());
  for (let h of hexagons) h.getHealthSubtractor(p.returnBulletSubtractor());
  for (let o of opponents) o.getHealthSubtractor(p.returnBulletSubtractor());
}


function destroyedObjects() {
  // REMOVE THE DESTROYED OBJECTS FROM THEIR ARRAYLIST
  for (let s of destroyedSquares) {
    particles.push(new Particle(s.returnXpos() + 15, s.returnYpos() + 15, s.returnColor(), 10));
    squares.splice(squares.indexOf(s), 1);
    if (s.protagonist) p.incrementXP(s.returnXP());
  }
  for (let f of destroyedPentagons) {
    particles.push(new Particle(f.returnXpos(), f.returnYpos(), f.returnColor(), 10));
    pentagons.splice(pentagons.indexOf(f), 1);
    if (f.protagonist) p.incrementXP(f.returnXP());
  }
  for (let h of destroyedHexagons) {
    particles.push(new Particle(h.returnXpos(), h.returnYpos(), h.returnColor(), 10));
    hexagons.splice(hexagons.indexOf(h), 1);
    if (h.protagonist) p.incrementXP(h.returnXP());
  }
  for (let o of destroyedOpponents) {
    particles.push(new Particle(o.returnX() + 15, o.returnY() + 15, o.returnColor(), 40));
    opponents.splice(opponents.indexOf(o), 1);
    p.incrementXP(3000);

    if (int(random(1, 3)) == 1) {    // 50/50 either sprayer or sniper class
      if (p.returnLevel() >= 10) {
        opponents.push(new Opponent(int(random(0, width)), int(random(0, height)),
          3, 5, 20, 40, 50, 100, 0, 0, 300, 100, 3000, 3000, 1000, 3000, 2, 2, int(random(1, 5))));  // different types
      } else {
        opponents.push(new Opponent(int(random(0, width)), int(random(0, height)),
          3, 5, 20, 40, 50, 100, 0, 0, 300, 100, 3000, 3000, 1000, 3000, 2, 2, 1));
      }
    } else {
      if (p.returnLevel() >= 10) {
        opponents.push(new Opponent(100, 100,
          1, 2, 20, 8, 40, 60, 1, 1.5, 300, 300, 500, 500, 1000, 3000, 0.5, 0.1, int(random(1, 5))));
      } else {
        opponents.push(new Opponent(100, 100,
          1, 2, 20, 8, 40, 60, 1, 1.5, 300, 300, 500, 500, 1000, 3000, 0.5, 0.1, 1));  // standard class if lower level
      }
    }
  }

  for (let g of dysfunctionalParticles) particles.splice(particles.indexOf(g), 1);
  for (let b of dysfunctionalBullets) bullets.splice(bullets.indexOf(b), 1);

  dysfunctionalBullets = [];
  dysfunctionalParticles = [];
  destroyedSquares = [];
  destroyedPentagons = [];
  destroyedHexagons = [];
  destroyedOpponents = [];
}





function upgradeStats(n) {
  return (cursorX > c.returnStatLeft() && cursorX < c.returnStatRight() && cursorY > c.returnStatTop() + n &&
    cursorY < c.returnStatBottom() + n && p.returnPoints() >= 1);
}

function mouseReleased() {
  cursorX = mouseX;
  cursorY = mouseY;

  // FSM STATE TRANSITIONS FROM MOUSE RELEASED INPUTS
  if (state === "menu") {
    if (cursorX >= 195 && cursorX <= 604 && cursorY >= 226 && cursorY <= 619) {
      state = "gameplay-j";
    }

    if (cursorX >= 647 && cursorX <= 1056 && cursorY >= 226 && cursorY <= 619) {
      state = "gameplay-e";
      p.level = 30;
      p.ePoints = 30;
      c.showChart = true;
    }
  } else if (state === "paused-e") {
    if (cursorX >= 370 && cursorX <= 895 && cursorY >= 449 && cursorY <= 510) state = "gameplay-e";
    else if (cursorX >= 370 && cursorX <= 895 && cursorY >= 537 && cursorY <= 599) {
      state = "menu";
      admin();
    }
  } else if (state === "paused-j") {
    if (cursorX >= 370 && cursorX <= 895 && cursorY >= 449 && cursorY <= 510) state = "gameplay-j";
    else if (cursorX >= 370 && cursorX <= 895 && cursorY >= 537 && cursorY <= 599) {
      state = "menu";
      admin();
    }
  } else if (state === "dead-j") {
    admin();

    if (cursorX >= 370 && cursorX <= 895 && cursorY >= 449 && cursorY <= 510) state = "gameplay-j";
    else if (cursorX >= 370 && cursorX <= 895 && cursorY >= 537 && cursorY <= 599) state = "menu";
  } else if (state === "dead-e") {
    admin();

    if (cursorX >= 370 && cursorX <= 895 && cursorY >= 449 && cursorY <= 510) {
      p.level = 30;
      p.ePoints = 30;
      state = "gameplay-e";
      c.showChart = true;
    } else if (cursorX >= 370 && cursorX <= 895 && cursorY >= 537 && cursorY <= 599) state = "menu";
  }
  else if (state === "gameplay-e" || state === "gameplay-j"){
    if (mouseButton === LEFT) {
  
      if (state === "gameplay-e"){
        if (cursorX >= 0 && cursorX <= 50 && cursorY >= 0 && cursorY <= 50) state = "paused-e";
      }
      if (state === "gameplay-j"){
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
        if (state === "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
      if (upgradeStats(44) && c.returnHealthRegenPoints() < 15){
        c.incrementHealthRegen();
        p.incrementHealthRegen();
        if (state === "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
      if (upgradeStats(78) && c.returnBulletSpeedPoints() < 15){
        c.incrementBulletSpeed();
        p.incrementBulletSpeed();
        if (state === "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
      if (upgradeStats(112) && c.returnBulletDamagePoints() < 15){
        c.incrementBulletDamage();
        p.incrementBulletDamage();
        if (state === "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
      if (upgradeStats(146) && c.returnBulletDistancePoints() < 15){
        c.incrementBulletDistance();
        p.incrementBulletDistance();
        if (state === "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
      if (upgradeStats(180) && c.returnBodyDamagePoints() < 15){
        c.incrementBodyDamage();
        p.incrementBodyDamage();
        if (state === "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
      if (upgradeStats(214) && c.returnMovementSpeedPoints() < 15){
        c.incrementMovementSpeed();
        p.incrementMovementSpeed();
        if (state === "gameplay-e" && p.ePoints > 0) p.ePoints -= 1;
      }
    }
  }
}



function barrelAim() {
  cursorX = mouseX;
  cursorY = mouseY;
  
  // FIND THE X AND Y DISPLACEMENT
  
  if (cursorX < (width / 2)) {
    displacementX = (width / 2) - cursorX;
  } else if (cursorX > (width / 2)) {
    displacementX = cursorX - (width / 2);
  }
  if (cursorY < (height / 2)) {
    displacementY = (height / 2) - cursorY;
  } else if (cursorY > (height / 2)) {
    displacementY = cursorY - (height / 2);
  }
  
  // TURN THE RISE AND THE RUN INTO AN ANGLE IN RADIANS
  
  radianX = (displacementX * PI) / 180;
  radianY = (displacementY * PI) / 180;
  radian = atan(radianY / radianX);
  
  // ARCTAN IS USED TO FIND THE UNIVERSAL ANGLE IN RADIANS
  // RIGHT IS COS ANGLE IN RADIANS
  // UP IS SIN ANGLE IN RADIANS
  
  if (cursorX > (width / 2) && cursorY > (height / 2)) { 
    hori = cos(radian);  
    vert = sin(radian);
  } // RIGHT BOTTOM
  if (cursorX > (width / 2) && cursorY < (height / 2)) { 
    hori = cos(radian);  
    vert = sin(radian + (PI));
  } // RIGHT TOP
  if (cursorX < (width / 2) && cursorY > (height / 2)) { 
    hori = cos(radian + (PI));  
    vert = sin(radian);
  } // LEFT BOTTOM
  if (cursorX < (width / 2) && cursorY < (height / 2)) { 
    hori = cos(radian + (PI));  
    vert = sin(radian + (PI));
  } // LEFT TOP
  
  p.getHori(hori);
  p.getVert(vert);
}


function mousePressed() {
  // SHOOT A NEW BULLET IN DIRECTION OF BARREL
  bullets.push(new Bullet(60, p.returnX(), p.returnY(), p.returnHori(), 
  p.returnVert(), p.returnBulletSpeed(), p.returnBulletDamage(), p.returnBulletColor(), true));
  p.getHoriOpp(cos(acos(p.returnHori()) + PI));
  p.getVertOpp(sin(asin(p.returnVert()) + PI));
}

function mouseMoved() {
  // WHEN MOUSE IS MOVED, MOVE THE BARREL
  barrelAim();
}

function mouseDragged() {
  // WHEN MOUSE IS DRAGGED, MOVE THE BARREL
  barrelAim();
}

function keyPressed() {
  // SPATIAL MOVEMENT WASD  
  if (key === 'w') up = true;
  if (key === 'a') left = true;
  if (key === 's') down = true;
  if (key === 'd') right = true;
}

function keyReleased() {
  // SPATIAL MOVEMENT WASD  
  if (key === 'w') up = false;
  if (key === 'a') left = false;
  if (key === 's') down = false;
  if (key === 'd') right = false;
}

class Bullet {

  constructor(B, X, Y, H, V, S, D, C, P) {
    this.bulletAngle = B;
    this.startX = X;
    this.startY = Y;
    this.hori = H;
    this.vert = V;
    this.bulletSpeed = S * m;
    this.bulletDamage = D;
    this.colour = C;
    this.protagonist = P;
  }

  constructor(B, X, Y, H, V, S, D, C, BD, P) {
    this.bulletAngle = B;
    this.startX = X;
    this.startY = Y;
    this.hori = H;
    this.vert = V;
    this.bulletSpeed = S * m;
    this.bulletDamage = D;
    this.colour = C;
    this.protagonist = P;
    this.dist = BD;
  }

  // Custom method for updating the variables
  getHori(H) {
    this.hori = H;
  }
  
  getVert(V) {
    this.vert = V;
  }
  
  // Custom method for returning Variables
  returnXpos() {
    return this.xpos;
  }
  
  returnYpos() {
    return this.ypos;
  }
  
  returnBulletDamage() {
    return this.bulletDamage;
  }
  
  returnBulletDistance() {
    return this.bulletDistance;
  }
  
  returnHori() {
    return this.hori;
  }
  
  returnVert() {
    return this.vert;
  }
  
  returnProtagonist() {
    return this.protagonist;
  }
  
  function display() {
    if (this.returnProtagonist() == true){
      if (this.returnBulletDistance() >= p.returnBulletDistance()) dysfunctionalBullets.add(this);
    }
    
    if (this.returnProtagonist() == false){
        if (this.returnBulletDistance() >= dist)dysfunctionalBullets.add(this);
    }
    
    // WHEN BULLET HITS A SQUARE
    
    for (let s of squares){
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
    
    for (let f of pentagons){
        if (sqrt(sq(this.returnXpos() - f.returnXpos()) + sq(this.returnYpos() - f.returnYpos())) <= 25 && f.returnHit() == false){ 
            f.hit(bulletDamage, this.returnHori(), this.returnVert(), this.protagonist);
            particles.add(new Particle(f.returnXpos(), f.returnYpos(), f.returnColor(), 2));
        }
        if (f.returnHealth() <= 0)if (destroyedPentagons.contains(f)){} else {destroyedPentagons.add(f);}
    }
    
    // WHEN BULLET HITS A HEXAGON
    
    for (let h of hexagons){
        if (sqrt(sq(this.returnXpos() - h.returnXpos()) + sq(this.returnYpos() - h.returnYpos())) <= 25 && h.returnHit() == false){ 
            h.hit(bulletDamage, this.returnHori(), this.returnVert(), this.protagonist);
            particles.add(new Particle(h.returnXpos(), h.returnYpos(), h.returnColor(), 2));
        }
        if (h.returnHealth() <= 0)if (destroyedHexagons.contains(h)){} else {destroyedHexagons.add(h);}
    }
    
    // WHEN BULLET HITS AN OPPONENT
    
    for (let o of opponents){
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
    
    fill(20);
    ellipse(xpos, ypos + 5, 20, 20);
    bulletAngle += bulletSpeed;
    
    fill(colour);
    ellipse(xpos, ypos, 20, 20);
    fill(colour);
    ellipse(xpos, ypos, 20 - 7, 20 - 7);
    
    bulletAngle += bulletSpeed;
    bulletDistance += 1;
  }
}






class Chart {
  
  constructor(W, H) {
    this.rightX = 0;
    this.topY = height * (3.0 / 4.0) - 80;
    
    this.showChart;
    this.points;
    
    this.chartWidth = W;
    this.chartHeight = H + 100;
    this.statHeight = H / 6.0;
    this.statWidth = W - 60;
    
    this.maxHealthPoints = 1;
    this.healthRegenPoints = 1;
    this.bulletSpeedPoints = 1;
    this.bulletDamagePoints = 1;
    this.bulletDistancePoints = 1;
    this.movementSpeedPoints = 1;
    this.bodyDamagePoints = 1;
    
    this.tabLeft = 0;
    this.tabRight = this.tabLeft + 10;
    this.tabTop = this.topY;
    this.tabBottom = this.topY + (height * (1.0 / 4.0) - 20);
    
    this.font1;
    this.font2;
  }
  
  showChart(P){ showChart = true; points = P;}
  hideChart(){ showChart = !true;}
  
  
  incrementMaxHealth(){ maxHealthPoints ++; }
  incrementHealthRegen(){ healthRegenPoints ++; }
  incrementBulletSpeed(){ bulletSpeedPoints ++; }
  incrementBulletDamage(){ bulletDamagePoints ++; }
  incrementBulletDistance(){ bulletDistancePoints ++; }
  incrementBodyDamage(){ bodyDamagePoints ++; }
  incrementMovementSpeed(){ movementSpeedPoints ++; }
  
  function returnShowChart() { return showChart; }
  function returnTabLeft() { return tabLeft; }
  function returnTabRight() { returnTabLeft() + 20; }
  function returnTabTop() { return tabTop; }
  function returnTabBottom() { returnTabTop() + 100; }
  function returnStatLeft(){ return rightX - chartWidth + 20; }
  function returnStatRight(){ return rightX - chartWidth + 20 + statWidth; }
  function returnStatTop(){ return topY + 0; }  // MUST INSERT THE HEIGHT VALUES REPLACE 0
  function returnStatBottom(){ return topY + statHeight + 0; }
  
  function returnMaxHealthPoints() { return maxHealthPoints; }
  function returnHealthRegenPoints() { return healthRegenPoints; }
  function returnBulletSpeedPoints() { return bulletSpeedPoints; }
  function returnBulletDamagePoints() { return bulletDamagePoints; }
  function returnBulletDistancePoints() { return bulletDistancePoints; }
  function returnMovementSpeedPoints() { return movementSpeedPoints; }
  function returnBodyDamagePoints() { return bodyDamagePoints; }
  
  function customFont(text, X, Y, outline, fill){
    for(let x = -outline; x < outline; x++){
      for (let y = -3; y < 3; y++){
        text(text, X + x,  Y + y);
      }
    }
    fill(255);
    for(let x = -fill; x < fill; x++){
      for (let y = -1; y < 1; y++){
        text(text, X + x,  Y+ y);
      }
    }
  }
  
  function borderOutline(y){
    rect(rightX - chartWidth + 20, topY + y, statWidth, statHeight);
    arc(rightX - chartWidth + 20, topY + y + statHeight / 2, statHeight, statHeight, HALF_PI, PI+HALF_PI);
    arc(rightX - chartWidth + 20 + statWidth, topY + y + statHeight / 2, statHeight, statHeight, -HALF_PI, HALF_PI);
  }
  
  function fillStats(y, x){
    rect(rightX - chartWidth + 20, topY + y + 4, ((statWidth) * (x / 15.0)), statHeight - 8);
    ellipse(rightX - chartWidth + 20, topY + y + 4 + ((statHeight - 8) / 2), statHeight - 8, statHeight - 8);
    ellipse(rightX - chartWidth + 20 + ((statWidth) * (x / 15.0)), topY + y + 4 + ((statHeight - 8) / 2), statHeight - 8, statHeight - 8);
  }
  
  function display() {
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
    
    for(let x = -3.3; x < 3.3; x++){
      for (let y = -3.3; y < 3.3; y++){
        text("Points :  " + p.returnPoints(), rightX - chartWidth + 20 + statWidth / 2 + x, topY + 10 + statHeight / 2 + 5 - 34 + y);
      }
    }
    
    fill(255);
    for(let x = -1.5; x < 1.5; x++){
      for (let y = -1.5; y < 1.5; y++){
        text("Points :  " + p.returnPoints(), rightX - chartWidth + 20 + statWidth / 2 + x, topY + 10 + statHeight / 2 + 5 - 34 + y);
      }
    }
  }
}








class Hexagon {
  
  constructor(X, Y, N) {
    this.maxHealth = 500;
    this.health = 500;
    this.healthDecrement = 500;
    this.healthSubtractor = 1;
    this.ID = N;
    this.count = 0;
    this.bulletDamage = 0;
    this.damage = 50.0;
    this.xp = 800;
    this.driftX = 0;
    this.driftY = 0;
    this.drift = 0;
    this.acceleration = 0;
    this.startX = X;
    this.startY = Y;
    this.radian = radians(int(random(0, 360)));
    this.degrees = 0;
    this.xpos = 0;
    this.ypos = 0;
    this.squareWidth = 30;
    this.outline = color(235, 150, 214);
    this.hit = false;
    this.shove = false;
    this.showHealthBar = false;
    this.protagonist = false;
    
    this.driftX = cos(this.radian);
    this.driftY = sin(this.radian);
    this.xpos = this.startX + (this.driftX * this.drift);
    this.ypos = this.startY + (this.driftY * this.drift);
  }
  
  getHori(H) {
    this.hori = H;
  }
  
  getVert(V) {
    this.vert = V;
  }
  
  getHealthSubtractor(V) {
    this.healthSubtractor = V;
  }
  
  hit(DMG, H, V, P) {
    this.hit = true;
    this.bulletDamage = DMG;
    this.showHealthBar = true;
    this.protagonist = P;
    this.driftX = H;
    this.driftY = V;
    this.startX = this.xpos - (this.driftX * this.drift);
    this.startY = this.ypos - (this.driftY * this.drift);
  }
  
  
  function shove(DMG, P) {
    shoveBool = true;
    bulletDamage = DMG;
    showHealthBar = true;
    protagonist = P;
  }
  
  // Custom methods when Attributes increased
  function incrementMaxHealth() { }
  function incrementHealthRegen() { }
  function incrementBulletSpeed() { }
  function incrementBulletDamage() { healthSubtractor += 0.5; }
  function incrementBulletDistance() { }
  function incrementMovementSpeed() { }
  function incrementBodyDamage() { }
  
  // Custom method for returning Variables
  function returnXpos() { return xpos; }
  function returnYpos() { return ypos; }
  function returnWidth() { return squareWidth; }
  function returnHealth() { return healthDecrement; }
  function returnDamage() { return damage; }
  function returnXP() { return xp; }
  function returnID() { return ID; }
  function returnColor() { return outline; }
  function returnHit() { return hit; }
  
  
  // Custom method for Polygon Drawing (AT CENTER)
  function polygon(x, y, radius, npoints) {
    let angle = TWO_PI / npoints;
    beginShape();
    for (let a = 0; a < TWO_PI; a += angle) {
      let sx = x + cos(a) * radius;
      let sy = y + sin(a) * radius;
      vertex(sx, sy);
    }
    endShape(CLOSE);
  }
  
  
  // Custom method for drawing the object
  function display() {
  
    xpos = startX + (driftX * drift);
    ypos = startY + (driftY * drift);
  
    // WHEN THE OPPONENTS SHOVE INTO HEXAGONS
  
    for (let o of opponents) {
      if (sqrt(sq(o.returnX() - this.returnXpos()) + sq(o.returnY() - this.returnYpos())) <= 60) {
        this.getHealthSubtractor(100);
        shove(o.returnBodyDamage(), false);
        this.getHealthSubtractor(100);
        o.shove(this.returnDamage());
        //particles.add(new Particle(p.returnXpos() + 15, p.returnYpos() + 15, p.returnColor(), 1));
      }
      if (this.returnHealth() <= 0) destroyedHexagons.add(this);
    }
  
    if (sqrt(sq(p.returnXpos() - this.returnXpos()) + sq(p.returnYpos() - this.returnYpos())) <= 60) {
      this.getHealthSubtractor(100);
      shove(p.returnBodyDamage(), true);
      p.shove(this.returnDamage());
      //particles.add(new Particle(p.returnXpos() + 15, p.returnYpos() + 15, p.returnColor(), 1));
    }
    if (this.returnHealth() <= 0) destroyedHexagons.add(this);
    
    
    push();
    translate(xpos, ypos + 6);
    rotate(degrees(degrees));
    fill(60);    // SHADOW
    polygon(0, 0, squareWidth, 6);
    pop();
    
    if (showHealthBar == true){
      // HEALTH BAR OUTLINE
      rect(xpos + 2 - 1 - (squareWidth / 2), ypos + 40 - 1, squareWidth + 2, 7); // need the y -1 for the top outline,  7 height, 5, increment
      ellipse(xpos + 2 - (squareWidth / 2), ypos + 40 - 1 + 3.5, 7, 7);
      ellipse(xpos + 2 + squareWidth - (squareWidth / 2), ypos + 40 - 1 + 3.5, 7, 7);
    
      if (healthDecrement > health){ // DECREMENT THE HEALTHBAR
        fill(0, 255, 0);
        rect(xpos + 2 - (squareWidth / 2), ypos + 40, squareWidth * (healthDecrement / maxHealth), 5);
        ellipse(xpos + 2 - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
        ellipse(xpos + 2 + squareWidth * (healthDecrement / maxHealth) - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
        healthDecrement -= healthSubtractor * m; // SOOO CLEAN!!
      } else{ // DO NOT MOVE HEALTH BAR
        fill(0, 255, 0);
        rect(xpos + 2 - (squareWidth / 2), ypos + 40, squareWidth * (health / maxHealth), 5);
        ellipse(xpos + 2 - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
        ellipse(xpos + 2 + squareWidth * (health / maxHealth) - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
      }
    }
    
    push();
    translate(xpos, ypos);
    rotate(degrees(degrees));
    
    if (hit == false && shove == false){ // DRAW REGULAR SQUARE OBJECT
      fill(235, 150, 214);
      polygon(0, 0, squareWidth, 6);
      fill(255, 170, 234);
      polygon(0, 0, squareWidth * 0.8, 6);
    } else {
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
      if (count <= 10 / m){ // FLASH RED
        fill(235, 0, 0);   
        polygon(0, 0, squareWidth, 6);
        fill(255, 0, 0);
        polygon(0, 0, squareWidth * 0.8, 6);
      }
      if (count > 10 / m && count <= 20 / m){  // FLASH WHITE
        fill(235); 
        polygon(0, 0, squareWidth, 6);
        fill(255);
        polygon(0, 0, squareWidth * 0.8, 6);
      }
      if (count < 20 / m){count ++;} 
      else {hit = false; count = 0;}  // END THE HIT STAGE
    }
    
    degrees += 0.00005 * m;
    drift += (0.05 + acceleration) * m;
    pop();
  }
}
      
      
  
class Opponent {
  
  constructor(X, Y) {
    this.maxHealth = 1000;
    this.healthDecrement = 1000;
    this.health = 1000;
    this.healthSubtractor = 1.0;
    this.damageTaken = 0;
    this.bulletSubtractor = 1.0;
    this.size = 80;
  
    this.count = 0;
    this.outline = color(225, 0, 0);
    this.bulletColor = color(255, 0, 0);
  
    this.bodyDamage = 20.0;
    this.movementSpeed = 1;
    this.bulletSpeed = 1;
    this.bulletDamage = 10.0;
    this.bulletDistance = 50;
    this.bulletReload = 0.4;
    this.range = 300;
    this.sight = 500;
  
    this.barrels = 0;
  
    this.fireRate = 0;
  
    this.startX = X;
    this.startY = Y;
    this.dist = 0;
  
    this.hori = cos(0);
    this.vert = sin(0);
  
    this.shove = false;
    this.showHealthBar = false;
    this.showChart = false;
    this.inRange = false;
  
    this.a = 0; 
    this.b = 0;
    this.d = 0; 
    this.e = 0; 
    this.r = 0; 
    this.rr = 0; 
    this.rl = 0; 
    this.rb = 0; 
    this.rf = 0;
    this.j = 0; 
    this.k = 0; 
    this.jr = 0; 
    this.kr = 0; 
    this.jl = 0; 
    this.kl = 0; 
    this.jb = 0; 
    this.kb = 0; 
    this.jf = 0; 
    this.kf = 0;
  
    this.c = new Chart();
    this.bulletsHit = [];
  
    this.bulletSpeed += (p.level * 0.05);
    this.bulletDamage += (p.level * 0.1);
    this.movementSpeed += (p.level * 0.01);
    this.range -= (p.level * 5);
    this.sight += (p.level * 20);
    this.maxHealth += (p.level * 100);
    this.healthDecrement += (p.level * 100);
    this.health += (p.level * 100);
    this.bulletReload -= (p.level * 0.005);
  }
  
  constructor(X, Y, BS, BD, D, MS, R, S, MH, BR) {
    this.startX = X;
    this.startY = Y;
    
    this.bulletSpeed = BS + (p.level * 0.05);
    this.bulletDamage = abs(BD + (p.level * 0.1));
    this.bulletDistance = D;
    this.movementSpeed = MS + (p.level * 0.01);
    this.range = R - (p.level * 5);
    this.sight = S + (p.level * 20);
    this.maxHealth = MH + (p.level * 100);
    this.healthDecrement = MH + (p.level * 100);
    this.health = MH + (p.level * 100);
    this.bulletReload = BR - (p.level * 0.005);
    
  }
  constructor(X, Y, BS, BS2, BD, BD2, D, D2, MS, MS2, R, R2, S, S2, MH, MH2, BR, BR2, B) {
    this.startX = X;
    this.startY = Y;
    this.bulletSpeed = BS + (level * (((BS2 - BS) / 30)));
    this.bulletDistance = D + (level * (((D2 - D) / 30)));
    this.movementSpeed = MS + (level * (((MS2 - MS) / 30)));
    this.range = R + (level * (((R2 - R) / 30)));
    this.sight = S + (level * (((S2 - S) / 30)));
    this.maxHealth = MH + (level * (((MH2 - MH) / 30)));
    this.healthDecrement = this.maxHealth;
    this.health = this.maxHealth;
    this.bulletReload = BR + (level * (((BR2 - BR) / 30)));
    this.barrels = B;
  }
  
  // Custom method for updating the variables
  
  getHori(H){hori = H;}
  getVert(V){vert = V;}
  
  getShowChart(S){ showChart = S; }
  getBullet(B){ bulletsHit.add(B); }
  getHealthSubtractor(V){ healthSubtractor = V;}
  
  shove(DMG){
    shove = true;
    damageTaken = DMG;
    showHealthBar = true;
  }
  
  // Custom method for returning Variables
  
  returnXpos(){return startX - (width / 2);}
  returnYpos(){return startY - (height / 2);}
  returnX(){return startX;}
  returnY(){return startY;}
  returnHori(){return j;}
  returnVert(){return k;}
  returnReload(){ return bulletReload; }
  
  returnDist(){ return dist; }
  returnSight(){ return sight; }
  
  returnInRange(){return inRange;}
  returnBulletHistory() {return bulletsHit;}
  
  returnBulletSpeed(){ return bulletSpeed; }
  returnBulletDistance(){ return bulletDistance; }
  returnBulletDamage(){ return bulletDamage; }
  returnBodyDamage(){ return bulletDamage; }
  returnBulletSubtractor(){ return bulletSubtractor; }
  returnHealth(){ return healthDecrement; }
  
  returnColor(){ return outline;}
  returnBulletColor() { return bulletColor; }
  
  
  
  
  function display() {

    if (floor(fireRate) < this.returnReload() * 60) {
      fireRate++;
    } else {
      fireRate = 0;
      if (this.returnDist() < this.returnSight()) {
  
        if (barrels == 1) {
          bullets.push(new Bullet(60, this.returnXpos(), this.returnYpos(), -(this.returnHori()), -(this.returnVert()),
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
        } else if (barrels == 2) {
          bullets.push(new Bullet(60, this.returnXpos(), this.returnYpos(), -(this.returnHori()), -(this.returnVert()),
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
  
          bullets.push(new Bullet(60, this.returnXpos(), this.returnYpos(), -jb, -kb,
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
        } else if (barrels == 3) {
          bullets.push(new Bullet(60, this.returnXpos(), this.returnYpos(), -(this.returnHori()), -(this.returnVert()),
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
  
          bullets.push(new Bullet(60, this.returnXpos(), this.returnYpos(), -jr, -kr,
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
  
          bullets.push(new Bullet(60, this.returnXpos(), this.returnYpos(), -jl, -kl,
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
        } else if (barrels == 4) {
          bullets.push(new Bullet(60, this.returnXpos(), this.returnYpos(), -jr, -kr,
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
  
          bullets.push(new Bullet(60, this.returnXpos(), this.returnYpos(), -jl, -kl,
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
  
          bullets.push(new Bullet(60, this.returnXpos(), this.returnYpos(), -jb, -kb,
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
  
          bullets.push(new Bullet(60, this.returnXpos(), this.returnYpos(), -jf, -kf,
            this.returnBulletSpeed(), this.returnBulletDamage(), this.returnBulletColor(), bulletDistance, false));
        }
      }
    }
    
    
    
    if (showHealthBar === true) {
      fill(0);
      // HEALTH BAR OUTLINE
      rect(startX + 2 - 1 - (size / 2), startY + 60 - 1, size + 2, 7);
      ellipse(startX + 2 - 1 - (size / 2), startY + 60 - 1 + 3.5, 5, 5);
      ellipse(startX + 2 - 1 + size + 2 - (size / 2), startY + 60 - 1 + 3.5, 7, 7);
    
      if (healthDecrement > health) { // DECREMENT THE HEALTHBAR
        fill(0, 255, 0);
        rect(startX + 2 - (size / 2), startY + 60, size * (healthDecrement / maxHealth), 5);
        ellipse(startX + 2 - (size / 2), startY + 60 + 2.5, 5, 5);
        ellipse(startX + 2 + size * (healthDecrement / maxHealth) - (size / 2), startY + 60 + 2.5, 5, 5);
    
        healthDecrement -= healthSubtractor * m; // SOOO CLEAN!!
    
      } else { // DO NOT MOVE HEALTH BAR
        fill(0, 255, 0);
        rect(startX + 2 - (size / 2), startY + 60, size * (health / maxHealth), 5);
        ellipse(startX + 2 - (size / 2), startY + 60 + 2.5, 5, 5);
        ellipse(startX - (size / 2) + 2 + (size * (health / maxHealth)), startY + 60 + 2.5, 5, 5);
      }
    }
    
    if (startX < p.returnXpos()) {
      a = p.returnXpos() - startX;
    } else if (startX > p.returnXpos()) {
      a = startX - p.returnXpos();
    }
    if (startY < p.returnYpos()) {
      b = p.returnYpos() - startY;
    } else if (startY > p.returnYpos()) {
      b = startY - p.returnYpos();
    }
    // TURN THE RISE AND THE RUN INTO AN ANGLE IN RADIANS
    
    e = (a * PI) / 180;
    d = (b * PI) / 180;
    
    r = atan(d / e);
    
    // ARCTAN IS USED TO FIND THE UNIVERSAL ANGLE IN RADIANS
    // RIGHT IS COS ANGLE IN RADIANS
    // UP IS SIN ANGLE IN RADIANS
    
    if (barrels == 1) { }
    else if (barrels == 2) {
      rb = r + (radians(180));
    }
    else if (barrels == 3) {
      rr = r + (radians(25));
      rl = r - (radians(25));
    }
    else if (barrels == 4) {
      rr += radians(1);
      rl = rr + radians(90);
      rb = rr + radians(180);
      rf = rr + radians(270);
    }
    
    
    // IF 4, THEN DO NOT TRACK PLAYER, ONLY GO AROUND IN A CIRCLE AT FAST PACE.

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
    
    if (opponents.length > 1) {

      for (let i = 0; i < opponents.length; i++) {
    
        if (opponents[i] == this) { } // don't do anything if it is this
        else {
          if (sqrt(sq(opponents[i].startX - startX) + sq(opponents[i].startY - startY)) <= 500) { // if the difference betweent the two are close
    
            if (dist < sqrt(sq(p.returnXpos() - opponents[i].startX) + sq(p.returnYpos() - opponents[i].startY))) {
              if (dist >= range) {
                startX -= j * movementSpeed * m; // only the closest to the protagonist is allowed to move
                startY -= k * movementSpeed * m;
                inRange = false; // this way they are not stuck
              } else {
                inRange = true;
              }
            } else { // it is made in the way that only this opponent will be able to move, I cannot make other opponent move. 
    
            }
            // WORKING ON THIS ATM
          } else {
            if (dist >= range) {
              startX -= j * movementSpeed * m;
              startY -= k * movementSpeed * m; // otherwise if they are apart, continue to follow the protagonist. 
              inRange = false;
            } else {
              inRange = true;
            }
          }
        }
      }
    } else {
      if (dist >= range) {
        startX -= j * movementSpeed * m;
        startY -= k * movementSpeed * m; // otherwise if they are apart, continue to follow the protagonist. 
        inRange = false;
      } else {
        inRange = true;
      }
    }
    
    fill(20);
    ellipse(startX, startY + 5, 80, 80);
    
    if (barrels == 1) {
      ellipse(startX - (60 * j), startY - (60 * k) + 5, 20, 20);
    } else if (barrels == 2) {
      ellipse(startX - (60 * j), startY - (60 * k) + 5, 20, 20);
      ellipse(startX - (60 * jb), startY - (60 * kb) + 5, 20, 20);
    } else if (barrels == 3) {
      ellipse(startX - (60 * j), startY - (60 * k) + 5, 20, 20);
      ellipse(startX - (60 * jr), startY - (60 * kr) + 5, 20, 20);
      ellipse(startX - (60 * jl), startY - (60 * kl) + 5, 20, 20);
    } else if (barrels == 4) {
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

  constructor(X, Y, C, N) {
    this.startX = X;
    this.startY = Y;
    this.c = C;
    this.num = N;

    this.sizes = [];
    this.hori = [];
    this.vert = [];

    for (let i = 0; i < this.num; i++) {
      this.sizes.push(int(random(0, 10)));
      this.hori.push(cos(radians(int(random(0, 360)))));
      this.vert.push(cos(radians(int(random(0, 360)))));
    }
    
    this.ParticleDistance = 0;
  }

  returnParticleDistance() {
    return this.ParticleDistance;
  }

  display() {
    for (let i = 0; i < this.sizes.length; i++) {
      fill(20, 20, 20, 255 - (this.ParticleDistance * 5));
      ellipse(this.startX + (this.hori[i] * this.ParticleDistance), this.startY + (this.vert[i] * this.ParticleDistance) + 3, this.sizes[i], this.sizes[i]);
      fill(this.c);
      ellipse(this.startX + (this.hori[i] * this.ParticleDistance), this.startY + (this.vert[i] * this.ParticleDistance), this.sizes[i], this.sizes[i]);
    }
    this.ParticleDistance += 1 * m;
  }
}
    
    
    
    
    
class Pentagon {
  
  constructor(X, Y, N) {
    this.maxHealth = 300;
    this.health = 300;
    this.healthDecrement = 300;
    this.healthSubtractor = 1;
    
    this.ID = N;
    
    this.count = 0;
    this.bulletDamage = 0;
    this.damage = 30.0;
    this.xp = 500;
    this.driftX = 0;
    this.driftY = 0;
    this.drift = 0;
    this.acceleration = 0;
    
    this.startX = X;
    this.startY = Y;
    
    this.radian = radians(int(random(0, 360)));
    
    this.degrees = 0;
    this.xpos = 0;
    this.ypos = 0;
    this.squareWidth = 30;
    this.outline = color(66, 116, 179);
    this.hit = false;
    this.shove = false;
    this.showHealthBar = false;
    this.protagonist = false;
    
    this.driftX = cos(this.radian);
    this.driftY = sin(this.radian);
    this.xpos = this.startX + (this.driftX * this.drift);
    this.ypos = this.startY + (this.driftY * this.drift);
  }
  
  
  // Custom method for updating the variables
  function getHori(H) { hori = H; }
  function getVert(V) { vert = V; }
  function getHealthSubtractor(V) { healthSubtractor = V; }
  
  function hit(DMG, H, V, P) {
    hit = true;
    bulletDamage = DMG;
    showHealthBar = true;
    protagonist = P;
  
    driftX = H;
    driftY = V;
    startX = xpos - (driftX * drift);
    startY = ypos - (driftY * drift);
  }
  
  function shove(DMG, P) {
    shove = true;
    bulletDamage = DMG;
    showHealthBar = true;
    protagonist = P;
  }
  
  // Custom methods when Attributes increased
  function incrementMaxHealth() { }
  function incrementHealthRegen() { }
  function incrementBulletSpeed() { }
  function incrementBulletDamage() { healthSubtractor += 0.5; }
  function incrementBulletDistance() { }
  function incrementMovementSpeed() { }
  function incrementBodyDamage() { }
  
  // Custom method for returning Variables
  function returnXpos() { return xpos; }
  function returnYpos() { return ypos; }
  function returnWidth() { return squareWidth; }
  function returnHealth() { return healthDecrement; }
  function returnDamage() { return damage; }
  function returnXP() { return xp; }
  function returnID() { return ID; }
  function returnColor() { return outline; }
  function returnHit() { return hit; }
  
  // Custom method for drawing Polygon (At Center)
  function polygon(x, y, radius, npoints) {
    const angle = TWO_PI / npoints;
    beginShape();
    for (let a = 0; a < TWO_PI; a += angle) {
      const sx = x + cos(a) * radius;
      const sy = y + sin(a) * radius;
      vertex(sx, sy);
    }
    endShape(CLOSE);
  }
  
  
  function display() {
    xpos = startX + (driftX * drift);
    ypos = startY + (driftY * drift);
  
    for (let o of opponents) {
      if (sqrt(sq(o.returnX() - this.returnXpos()) + sq(o.returnY() - this.returnYpos())) <= 60) {
        this.getHealthSubtractor(100);
        this.shove(o.returnBodyDamage(), false);
        this.getHealthSubtractor(100);
        o.shove(this.returnDamage());
        //particles.add(new Particle(p.returnXpos() + 15, p.returnYpos() + 15, p.returnColor(), 1));
      }
      if (this.returnHealth() <= 0) destroyedPentagons.add(this);
    }
  
    if (sqrt(sq(p.returnXpos() - this.returnXpos()) + sq(p.returnYpos() - this.returnYpos())) <= 60) {
      this.getHealthSubtractor(100);
      this.shove(p.returnBodyDamage(), true);
      p.shove(this.returnDamage());
      //particles.add(new Particle(p.returnXpos() + 15, p.returnYpos() + 15, p.returnColor(), 1));
    }
    if (this.returnHealth() <= 0) destroyedPentagons.add(this);
  
    push();
    translate(xpos, ypos + 6);
    rotate(degrees(degrees));
    fill(60); // SHADOW
    polygon(0, 0, squareWidth, 5);
    pop();
  
    if (showHealthBar == true) {
      // HEALTH BAR OUTLINE
  
      rect(xpos + 2 - 1 - (squareWidth / 2), ypos + 40 - 1, squareWidth + 2, 7); // need the y -1 for the top outline,  7 height, 5, increment
      ellipse(xpos + 2 - (squareWidth / 2), ypos + 40 - 1 + 3.5, 7, 7);
      ellipse(xpos + 2 + squareWidth - (squareWidth / 2), ypos + 40 - 1 + 3.5, 7, 7);
  
      if (healthDecrement > health) {
        // DECREMENT THE HEALTHBAR
        fill(0, 255, 0);
        rect(xpos + 2 - (squareWidth / 2), ypos + 40, squareWidth * (healthDecrement / maxHealth), 5);
        ellipse(xpos + 2 - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
        ellipse(xpos + 2 + squareWidth * (healthDecrement / maxHealth) - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
  
        healthDecrement -= healthSubtractor * m; // SOOO CLEAN!!
  
      } else {
        // DO NOT MOVE HEALTH BAR
        fill(0, 255, 0);
        rect(xpos + 2 - (squareWidth / 2), ypos + 40, squareWidth * (health / maxHealth), 5);
        ellipse(xpos + 2 - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
        ellipse(xpos + 2 + squareWidth * (health / maxHealth) - (squareWidth / 2), ypos + 40 + 2.5, 5, 5);
      }
    }
    
    push();
    translate(xpos, ypos);
    rotate(radians(degrees));
    
    
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
    
    pop();
  }
}

    



class Protagonist {
  
  constructor(X, Y, C) {
    this.barrel = 20;
  
    this.healthRegen = 240.0 / m;
    this.healing = 1.0;
    this.maxHealth = 100;
    this.healthDecrement = 100;
    this.health = 100;
    this.healthSubtractor = 1.0;
    this.damageTaken = 0;
    this.size = 80;
  
    this.bulletSubtractor = 1.0;
  
    this.count = 0;
    this.outline = color(0, 180, 235);
    this.bulletColor = color(0, 200, 255);
  
    this.bodyDamage = 20.0;
    this.reload = 0.5;
    this.movementSpeed = 1;
  
    this.acceleration = 0.004;
    this.velocityX = 0;
    this.velocityY = 0;
  
    this.bulletSpeed = 1;
    this.bulletDamage = 30.0;
    this.bulletDistance = 20;
    this.recoil = 0.1;
  
    this.xp = 0;
    this.xpIncrement = 0;
    this.xpAdder = 5.0;
    this.level = 1;
    this.levelRequirements = 1000;
    this.points = 0;
    this.ePoints = 0;
  
    this.startX = X;
    this.startY = Y;
    this.x = X;
    this.y = Y;
    this.xpos = X;
    this.ypos = Y;
  
    this.hori = cos(0);
    this.vert = sin(0);
    this.horiOpp;
    this.vertOpp;
  
    this.shove = false;
    this.showHealthBar = false;
    this.showChart = false;
    this.bulletsHit = [];
  
    this.c = C;
  }
  
  // Custom method for updating the variables
  function left() {   
    if (velocityX > (-1 * movementSpeed)) { 
      velocityX -= acceleration * m; 
    }
    x += velocityX * m;
  }
      
  function right() {
    if (velocityX < movementSpeed) { 
      velocityX += acceleration * m; 
    }
    x += velocityX * m;
  }
  
  function up() {
    if (velocityY > (-1 * movementSpeed)) { 
      velocityY -= acceleration * m; 
    }
    y += velocityY * m;
  }
    
  function down() {
    if (velocityY < movementSpeed) { 
      velocityY += acceleration * m; 
    }
    y += velocityY * m;
  }
   
  function leftFalse() {   
    if (velocityX < 0) { 
      velocityX += acceleration * m; 
    }
    x += velocityX * m;
  }
      
  function rightFalse() {
    if (velocityX > 0) { 
      velocityX -= acceleration * m; 
    }
    x += velocityX * m;
  }
    
  function upFalse() {
    if (velocityY < 0) { 
      velocityY += acceleration * m; 
    }
    y += velocityY * m;
  }
      
  function downFalse() {
    if (velocityY > 0) { 
      velocityY -= acceleration * m; 
    }
    y += velocityY * m;
  }
    
  function getHori(H) { 
    hori = H; 
  }
  
  function getVert(V) { 
    vert = V; 
  }
  
  function getHoriOpp(H) { 
    horiOpp = H; 
    velocityX += (H * recoil);
  }
  
  function getVertOpp(V) { 
    vertOpp = V;  
    velocityY += (V * recoil);
  }
  
  function getShowChart(S) { 
    showChart = S; 
  }
  
  function incrementXP(XP) { 
    xp += XP; 
    totalXP += XP;
  }
  
  function getBullet(B) { 
    bulletsHit.add(B); 
  }
  
  function incrementMaxHealth() { 
    if (ePoints <= 0) { 
      points--; 
    } 
    maxHealth += 30;  
    healthDecrement += 30; 
    health += 30; 
    if (points == 0 && ePoints == 0) { 
      c.hideChart(); 
    }
  }
    
  function incrementHealthRegen() { 
    if (ePoints <= 0) { 
      points--; 
    } 
    healthRegen -= 4; 
    healing += 0.1;  
    if (points == 0 && ePoints == 0) { 
      c.hideChart(); 
    }
  }
  
  function incrementBulletSpeed() { 
    if (ePoints <= 0) { 
      points--; 
    } 
    bulletSpeed += 0.1;  
    if (points == 0 && ePoints == 0) { 
      c.hideChart(); 
    }
  }
  
  function incrementBulletDamage() { 
    if (ePoints <= 0) { 
      points--; 
    } 
    bulletDamage += 5; 
    bulletSubtractor += 0.5;  
    if (points == 0 && ePoints == 0) { 
      c.hideChart(); 
    }
  }
  
  function incrementBulletDistance() { 
    if (ePoints <= 0) { points--; } 
    bulletDistance += 4;  
    if (points == 0 && ePoints == 0) { c.hideChart(); }
  }
  
  function incrementMovementSpeed() { 
    if (ePoints <= 0) { points--; } 
    movementSpeed += 0.04; 
    acceleration += 0.0001;   
    if (points == 0 && ePoints == 0) { c.hideChart(); }
  }
  
  function incrementBodyDamage() { 
    if (ePoints <= 0) { points--; } 
    bodyDamage += 10;  
    if (points == 0 && ePoints == 0) { c.hideChart(); }
  }
  
  function shove(DMG) {
    shove = true;
    damageTaken = DMG;
    showHealthBar = true;
  }
  
  // Custom method for returning variables
  function returnXpos() { return xpos; }
  function returnYpos() { return ypos; }
  function returnX() { return x; }
  function returnY() { return y; }
  function returnHori() { return hori; }
  function returnVert() { return vert; }
  
  function returnBulletSpeed() { return bulletSpeed; }
  function returnBulletDistance() { return bulletDistance; }
  function returnBulletDamage() { return bulletDamage; }
  function returnBodyDamage() { return bulletDamage; }
  function returnHealthRegen() { return healthRegen; }
  function returnBulletSubtractor() { return bulletSubtractor; }
  function returnReload() { return reload; }
  
  function returnVelocityX() { return velocityX; }
  function returnVelocityY() { return velocityY; }
  
  function returnPoints() { return points + ePoints; }
  function returnColor() { return outline; }
  function returnBulletColor() { return bulletColor; }
  function returnBulletHistory() { return bulletsHit; }
  function returnLevel() { return level; }
  function returnHealth() { return healthDecrement; }
  
  function incrementHealth() { 
    if (health < maxHealth) { 
      if ((health + healing) > maxHealth) { 
        health += (maxHealth - health);
      } else {
        health += healing; 
      }
    } 
    if (health >= maxHealth) { 
      showHealthBar = false; 
      health = maxHealth; 
    }
    return 0; 
  }
  
  
  // Custom method for drawing the object
  function display() {
  
    xpos = startX + x;
    ypos = startY + y;
    fill(50);
    ellipse(xpos, ypos + 5, size, size);    // SHADOW
  
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
  
      fill(0, 180, 235);
      ellipse(xpos, ypos, size, size);
      fill(0, 200, 255);
      ellipse(xpos, ypos, size - 12, size - 12);
  
      // AIMER
      fill(20);
      ellipse(xpos + (hori * 60), ypos + (vert * 60) + 5, barrel * 1, barrel * 1);
      fill(0, 180, 235);
      ellipse(xpos + (hori * 60), ypos + (vert * 60), barrel * 1, barrel * 1);
      fill(0, 200, 255);
      ellipse(xpos + (hori * 60), ypos + (vert * 60), barrel * 1 - 6, barrel * 1 - 6);
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
    
  function hud(){
    // WHEN THE LEVEL UP BAR IS FULL, INCREASE LEVEL AND LEVEL REQUIREMENTS
    if (xpIncrement >= levelRequirements){ 
      level ++; points ++; 
      xp -= levelRequirements; 
      xpIncrement = 0; 
      xpAdder += 0.2; 
      levelRequirements += 250; 
      
      if (points >= 1) c.showChart(points);
    }
    
    fill(50, 50, 50, 200);
    rect(width / 2 - 105, height - 50, 210, 30); // BAR OUTLINE
    arc(width / 2 - 105, height - 50 + 15, 30, 30, HALF_PI, PI + HALF_PI);
    arc(width / 2 + 105, height - 50 + 15, 30, 30, -HALF_PI, HALF_PI);
  
    textSize(30);
    textAlign(CENTER);
  
    // DRAW THE LEVEL TEXT
    for (let x = -4; x < 4; x++) {
      for (let y = -4; y < 4; y++) {
        text("LEVEL  " + level, (width / 2) + x, height - 60 + y);
      }
    }
    fill(255);
    for (let x = -2; x < 2; x++) {
      for (let y = -2; y < 2; y++) {
        text("LEVEL  " + level, (width / 2) + x, height - 60 + y);
      }
    }
  
    // DRAW HOW MUCH EXP PLAYER HAS RELATIVE TO LEVEL BAR LENGTH
    if (xpIncrement < xp) {
      ellipse(width / 2 - 105, height - 45 + 10, 20, 20);
      rect(
        width / 2 - 105,
        height - 45,
        200.0 * (xpIncrement / levelRequirements),
        20
      );
      ellipse(
        width / 2 - 105 + 200.0 * (xpIncrement / levelRequirements),
        height - 45 + 10,
        20,
        20
      );
  
      xpIncrement += xpAdder * m; // SOOO CLEAN!!
    } else {
      rect(width / 2 - 105, height - 45, 200.0 * (xp / levelRequirements), 20);
      ellipse(width / 2 - 105, height - 45 + 10, 20, 20);
      ellipse(
        width / 2 - 105 + 200.0 * (xp / levelRequirements),
        height - 45 + 10,
        20,
        20
      );
    }
  }
}
  
  // BONUS CODE
  /*
  function upRight() {
    x += sqrt(movementSpeed / 2);
    y -= sqrt(movementSpeed / 1.2);
  }
  function upLeft() {
    x -= sqrt(movementSpeed / 2);
    y -= sqrt(movementSpeed / 1.2);
  }
  function downRight() {
    x += sqrt(movementSpeed / 2);
    y += sqrt(movementSpeed / 1.2);
  }
  function downLeft() {
    x -= sqrt(movementSpeed / 2);
    y += sqrt(movementSpeed / 1.2);
  }
  */





    
    
    
class Square {
  
  constructor(X, Y, N) {
    this.maxHealth = 100;
    this.health = 100;
    this.healthDecrement = 100;
    this.healthSubtractor = 1;
    this.ID = N;
    this.count = 0;
    this.bulletDamage = 0;
    this.damage = 10.0;
    this.xp = 120;
    this.driftX = 0;
    this.driftY = 0;
    this.drift = 0;
    this.acceleration = 0;
    this.startX = X;
    this.startY = Y;
    this.radian = radians(int(random(0, 360)));
    this.degrees = 0;
    this.xpos = this.startX + (this.driftX * this.drift);
    this.ypos = this.startY + (this.driftY * this.drift);
    this.squareWidth = 30;
    this.outline = color(225, 225, 0);
    this.hit = false;
    this.shove = false;
    this.showHealthBar = false;
    this.protagonist = false;
  }
  
  // Custom method for updating the variables
  getHori(H){hori = H;}
  getVert(V){vert = V;}
  getHealthSubtractor(V){ healthSubtractor = V;}
  
  hit(DMG, H, V, P){
    hit = true;
    bulletDamage = DMG;
    showHealthBar = true;
    protagonist = P;
    
    driftX = H;
    driftY = V;
    startX = xpos - (driftX * drift);
    startY = ypos - (driftY * drift);
  }
  
  shove(DMG, P){
    shove = true;
    bulletDamage = DMG;
    showHealthBar = true;
    protagonist = P;
  }
  
  // Custom methods when Attributes increased
  incrementMaxHealth(){ }
  incrementHealthRegen(){ }
  incrementBulletSpeed(){ }
  incrementBulletDamage(){ healthSubtractor += 0.5; }
  incrementBulletDistance(){ }
  incrementMovementSpeed(){ }
  incrementBodyDamage(){ }
  
  // Custom method for returning Variables
  
  returnXpos(){ return xpos;}
  returnYpos(){ return ypos;}
  returnWidth(){ return squareWidth;}
  returnHealth(){ return healthDecrement;}
  returnDamage(){ return damage;}
  returnXP(){ return xp;}
  returnID(){return ID;}
  returnColor(){ return outline;}
  returnHit(){ return hit; }
  
  
  // Custom method for drawing the object
  
  function display() {
    
    xpos = startX + (driftX * drift);
    ypos = startY + (driftY * drift);
    
    for (let o of opponents){
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
    
    push();
    translate(xpos + 15, ypos + 21);
    rotate(radians(degrees));
    fill(60);    // SHADOW
    rect(-15, -15, squareWidth, squareWidth);
    pop();
    
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
    
    push();
    translate(xpos + 15, ypos + 15);
    rotate(radians(degrees));
    
    if (hit == false && shove == false) {    // DRAW REGULAR SQUARE OBJECT
      fill(235, 220, 0);
      rect(-15, -15, squareWidth, squareWidth);
      fill(255, 240, 0);
      rect(-15 + (squareWidth * 0.15), -15 + (squareWidth * 0.15), squareWidth * 0.7, squareWidth * 0.7);
    } else {
      if (count == 0) {
        if (hit == true) {
          health -= bulletDamage;
          acceleration += 0.03;
        }
        if (shove == true) {
          health -= (bulletDamage * 100000);
          acceleration += 0.08;
          healthSubtractor = 5000;
        }
      }
      if (count <= 10 / m) {    // FLASH RED
        fill(235, 0, 0);
        rect(-15, -15, squareWidth, squareWidth);
        fill(255, 0, 0);
        rect(-15 + (squareWidth * 0.15), -15 + (squareWidth * 0.15), squareWidth * 0.7, squareWidth * 0.7);
      }
      if (count > 10 / m && count <= 20 / m) {  // FLASH WHITE
        fill(235);
        rect(-15, -15, squareWidth, squareWidth);
        fill(255);
        rect(-15 + (squareWidth * 0.15), -15 + (squareWidth * 0.15), squareWidth * 0.7, squareWidth * 0.7);
      }
      if (count < 20 / m) count++;
      else {hit = false; shove = false; count = 0;}  // END THE HIT STAGE
    }
    
    degrees += 0.0001  * m;
    drift += (0 + acceleration)  * m;
    
    pop();
  }
}
    
    
    
