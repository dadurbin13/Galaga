ArrayList<Bullet> bullets;
ArrayList<Enemy> enemies;

Player player1;
Player player2;
PImage shipSprite;
boolean isPaused = false;
boolean[] keys = new boolean[256]; // Array to keep track of key states
int level = 1;

int scaleFactor = 2;
int playerWidth = 20 * scaleFactor;
int playerHeight = 20 * scaleFactor;
int enemyWidth = 40 * scaleFactor;
int enemyHeight = 20 * scaleFactor;
int bulletWidth = 2 * scaleFactor;
int bulletHeight = 10 * scaleFactor;
int playerSpeed = 5 * scaleFactor;
int bulletSpeed = 5 * scaleFactor;

void setup() {
  size(1600, 1200);
  shipSprite = loadImage("data/Ship_Sprite.png");
  player1 = new Player(width / 2 - 100, height - 60, color(255, 0, 0), shipSprite);
  player2 = new Player(width / 2 + 100, height - 60, color(0, 0, 255), shipSprite);
  bullets = new ArrayList<Bullet>();
  enemies = new ArrayList<Enemy>();
  startNewLevel(level);
}

void draw() {
  if (!isPaused) {
    gameLoop();
  } else {
    displayPauseScreen();
  }
}

void gameLoop() {
  background(0);

  // Check for player controls
  if (keys['a']) {
    player1.move(-playerSpeed);
  }
  if (keys['d']) {
    player1.move(playerSpeed);
  }
  if (keys[LEFT]) {
    player2.move(-playerSpeed);
  }
  if (keys[RIGHT]) {
    player2.move(playerSpeed);
  }

  // Update and display players
  player1.update();
  player1.display();
  player2.update();
  player2.display();

  // Update and display bullets
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.update();
    b.display();
    if (b.isOffScreen()) {
      bullets.remove(i);
    } else {
      // Check for collision with enemies
      for (int j = enemies.size() - 1; j >= 0; j--) {
        Enemy e = enemies.get(j);
        if (b.hits(e)) {
          e.hit(); // Enemy is hit instead of immediately removed
          bullets.remove(i);
          if (e.isDead()) {
            enemies.remove(j); // Only remove the enemy if it's dead
          }
          break;
        }
      }
    }
  }

  // Update and display enemies
  for (Enemy e : enemies) {
    e.update();
    e.display();
  }

  // Check if all enemies are destroyed and start a new level
  if (enemies.isEmpty()) {
    level++;
    startNewLevel(level);
  }
}

void displayPauseScreen() {
  fill(255);
  textAlign(CENTER);
  textSize(32);
  text("Paused", width / 2, height / 2);
}

void keyPressed() {
  if (key >= ' ' && key <= '~') { // If the key is a printable character
    keys[key] = true;
  } else {
    keys[keyCode] = true; // For non-character keys
  }

  if (isPaused && (key == 'p' || key == 'P')) {
    isPaused = false;
  } else if (key == 'p' || key == 'P') {
    isPaused = true;
  }

  // Player shooting controls
  if (key == 'w') {
    bullets.add(new Bullet(player1.x + playerWidth / 2, player1.y, -bulletSpeed));
  }
  if (key == CODED && keyCode == UP) {
    bullets.add(new Bullet(player2.x + playerWidth / 2, player2.y, -bulletSpeed));
  }
}

void keyReleased() {
  if (key >= ' ' && key <= '~') { // If the key is a printable character
    keys[key] = false;
  } else {
    keys[keyCode] = false; // For non-character keys
  }
}

void startNewLevel(int level) {
  enemies.clear(); // Clear the old enemies
  bullets.clear(); // Clear any remaining bullets

  // Adjust these values to change the spacing
  int spacingX = 60 * scaleFactor; // Double the horizontal spacing
  int spacingY = 40 * scaleFactor; // Double the vertical spacing

  // Create a new set of enemies with increased hit points and spacing
  for (int i = 0; i < level * 10; i++) { // Increase the number of enemies with each level
    // Double the spacing between enemies
    float x = (i % 10) * spacingX + spacingX; // Adjusted for horizontal spacing
    float y = (i / 10) * spacingY + spacingY; // Adjusted for vertical spacing
    int hp = 1 + level / 2; // Enemies' hit points increase with the level
    enemies.add(new Enemy(x, y, hp));
  }
}

class Player {
  float x;
  float y;
  color c;
  PImage sprite;
  
  Player(float tempX, float tempY, color tempC, PImage tempSprite) {
    x = tempX;
    y = tempY;
    c = tempC;
    sprite = tempSprite;
  }
  
  void update() {
    // Add constraints to keep players within the window
    x = constrain(x, 0, width - 20);
  }
  
  void display() {
    image(sprite, x, y, playerWidth, playerHeight); // Draw the image at the player's location
  }
  
  void move(float step) {
    x += step;
  }
}

class Bullet {
  float x;
  float y;
  float speed;

  Bullet(float tempX, float tempY, float tempSpeed) {
    x = tempX;
    y = tempY;
    speed = tempSpeed;
  }

  void update() {
    y += speed;
  }

  void display() {
    stroke(255);
    strokeWeight(bulletWidth); // Makes the bullet thicker
    line(x, y, x, y + bulletHeight);
  }

  boolean isOffScreen() {
    return y < 0 || y > height;
  }
  
  boolean hits(Enemy e) {
    // Check if the bullet's rectangle overlaps with the enemy's rectangle
    // The bullet's "hitbox" is from (x, y) to (x + bulletWidth, y + bulletHeight)
    // The enemy's "hitbox" is from (e.x, e.y) to (e.x + enemyWidth, e.y + enemyHeight)
    return (x < e.x + enemyWidth &&
            x + bulletWidth > e.x &&
            y < e.y + enemyHeight &&
            y + bulletHeight > e.y);
  }
}

class Enemy {
  float x, y;
  float w = 40, h = 20;
  int hitPoints; // New attribute to keep track of the enemy's strength

  Enemy(float tempX, float tempY, int hp) { // Constructor now takes hit points
    x = tempX;
    y = tempY;
    hitPoints = hp;
  }

  void update() {
    // Example of simple horizontal movement pattern
    x += sin(frameCount * 0.05) * 5; // Enemies will move side to side
    // You can make the movement pattern more complex if you wish
  }

  void display() {
    fill(255, 0, 0);
    rect(x, y, enemyWidth, enemyHeight);
  }

  void hit() { // Call this method when the enemy is hit by a bullet
    hitPoints--;
  }

  boolean isDead() { // Check if the enemy has run out of hit points
    return hitPoints <= 0;
  }
}
