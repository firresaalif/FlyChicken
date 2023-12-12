import processing.sound.*;

PImage backgroundImg;
PImage chickenImg;
PImage pipeTopImg;
PImage pipeBottomImg;
PImage getReadyImg;
PImage gameOverImg;
PImage pressStart;
PImage pressEnd;
PImage recentEnd;
PImage[] digitImages = new PImage[10]; // Array untuk menyimpan gambar digit 0-9
PImage scoreTextImage; // Variabel untuk menyimpan gambar teks "Score"
PImage recentTextImage; // Variabel untuk menyimpan gambar teks "Recent Score"

ArrayList<Pipe> pipes;
boolean gameOver;
boolean gameStarted = false;
boolean menuVisible = true;

int score;
int recentScore; // Variabel untuk recent score

SoundFile jumpSound;
SoundFile hitSound;
SoundFile winSound;
SoundFile pointSound;

float chickenY;
float chickenSpeed;
float gravity = 0.7;

void setup() {
  size(600, 600);
  backgroundImg = loadImage("background siang.jpg");
  chickenImg = loadImage("ayam.png");
  chickenY = height / 2;
  chickenSpeed = 0;
  pipes = new ArrayList<Pipe>();
  pipeTopImg = loadImage("pipe-green bot.png");
  pipeBottomImg = loadImage("pipe-green top.png");
  getReadyImg = loadImage("getready.png");
  gameOverImg = loadImage("gameover.png");
  scoreTextImage = loadImage("SCORE.png"); // Load gambar teks "Score"
  recentTextImage = loadImage("RECENT.png"); // Load gambar teks "Score"
  recentEnd = loadImage("endScore.png");
  pressStart = loadImage("pressStart.png");
  pressEnd = loadImage("pressEnd.png");
  digitImages[0] = loadImage("0.png");
  digitImages[1] = loadImage("1.png");
  digitImages[2] = loadImage("2.png");
  digitImages[3] = loadImage("3.png");
  digitImages[4] = loadImage("4.png");
  digitImages[5] = loadImage("5.png");
  digitImages[6] = loadImage("6.png");
  digitImages[7] = loadImage("7.png");
  digitImages[8] = loadImage("8.png");
  digitImages[9] = loadImage("9.png");

  gameOver = false;
  score = 0;
  recentScore = 0; // Inisialisasi recent score

  jumpSound = new SoundFile(this, "wing.wav");
  hitSound = new SoundFile(this, "hit.wav");
  winSound = new SoundFile(this, "win.wav");
  pointSound = new SoundFile(this, "point.wav");

  pipes.add(new Pipe());
}

void draw() {
  image(backgroundImg, 0, 0, width, height);
  
  if (!gameStarted) { 
    textSize(32);
    fill(255);
    textAlign(CENTER);
    
    if (menuVisible) {
      image(getReadyImg, width/2 - getReadyImg.width/2, height/2 - getReadyImg.height/2 - 50);
      fill(255);
      textAlign(CENTER);
      textSize(32);
      image(pressStart,600 - pressStart.width - 80, 180);
    }
  } else {
    if (!gameOver) {
      for (int i = pipes.size() - 1; i >= 0; i--) {
        Pipe pipe = pipes.get(i);
        pipe.update();
        pipe.show();

        if (pipe.hits(chickenY) || pipe.hits(chickenY + 40)) {
          gameOver = true;
          hitSound.play();
        }

        if (pipe.passed()) {
          score++;
          pointSound.play();
        }
      }

      chickenSpeed += gravity;
      chickenY += chickenSpeed;
      image(chickenImg, 50, chickenY, 40, 40);

      textSize(32);
      fill(255);
      textAlign(RIGHT, TOP); // Posisi teks di pojok kanan atas
      image(scoreTextImage, 600 - scoreTextImage.width - 150, 5);

      displayScore(score, width - 20 - 100, 20); // Tampilkan angka skor

      
      // Menampilkan recent score juga selama permainan berlangsung
      image(recentTextImage, width - recentTextImage.width - 380, -27); // Tampilkan gambar recent score di pojok kanan atas
      
      int posX = width - recentTextImage.width - 150; // Tentukan posisi X untuk recent score
      int posY = 20; // Tentukan posisi Y untuk recent score
      int tempRecentScore = recentScore; // Buat variabel sementara untuk recent score

      while (tempRecentScore > 0 || posX > width - recentTextImage.width - 10) {
        int digit = tempRecentScore % 10; // Ambil digit terakhir dari recent score
        PImage digitImage = digitImages[digit]; // Ambil gambar digit yang sesuai

        int digitWidth = 25; // Lebar satu digit
        int digitHeight = 28; // Tinggi satu digit

        // Tampilkan gambar digit di posisi X dengan ukuran yang seragam
        image(digitImage, posX, posY, digitWidth, digitHeight);

        tempRecentScore /= 10; // Hapus digit terakhir dari recent score
        posX -= digitWidth; // Geser ke kiri untuk menampilkan digit berikutnya
      }

      if (frameCount % 100 == 0) {
        pipes.add(new Pipe());
      }
    } else {
      image(recentEnd, width / 2 - recentEnd.width / 2, height / 2 + 10);
      
      // Menampilkan skor akhir menggunakan gambar digit
      int tempScore = score; // Simpan skor ke variabel sementara
      int posX = width - recentTextImage.width - -10; // Atur posisi awal X
      int posY = height / 2 + 133; // Atur posisi Y

      // Tampilkan skor akhir menggunakan gambar digit
      while (tempScore > 0) {
        int digit = tempScore % 10; // Ambil digit terakhir dari skor
        PImage digitImage = digitImages[digit]; // Ambil gambar digit yang sesuai

        // Tampilkan gambar digit di posisi X dan Y yang telah ditentukan
        image(digitImage, posX, posY);

        tempScore /= 10; // Hapus digit terakhir dari skor
        posX -= digitImage.width; // Geser ke kiri untuk menampilkan digit berikutnya
      }

      // Jika skor adalah 0, tampilkan satu digit '0'
      if (score == 0) {
        image(digitImages[0], posX, posY);
      }

      
      image(pressEnd,600 - pressStart.width - 80, 160);

      image(gameOverImg, width / 2 - gameOverImg.width / 2, height / 2 - gameOverImg.height / 2 + 50);
    }
    
    
    
  }
}

void keyPressed() {
  if (key == ' ' && !gameOver) {
    if (!gameStarted) {
      gameStarted = true;
      menuVisible = false;
    } else {
      chickenSpeed = -10;
      jumpSound.play();
    }
  } else if (key == ' ' && gameOver) {
    resetGame();
  }
}

void displayScore(int scoreToDisplay, int x, int y) {
  int digitWidth = 25; // Lebar satu digit
  int digitHeight = 28; // Tinggi satu digit

  while (scoreToDisplay > 0) {
    int digit = scoreToDisplay % 10; // Ambil digit terakhir dari skor
    PImage digitImage = digitImages[digit]; // Ambil gambar digit yang sesuai

    // Tampilkan gambar digit di posisi x dengan ukuran yang seragam
    image(digitImage, x, y, digitWidth, digitHeight);

    scoreToDisplay /= 10; // Hapus digit terakhir dari skor
    x -= digitWidth; // Geser ke kiri untuk menampilkan digit berikutnya
  }
}


void resetGame() {
  pipes.clear();
  pipes.add(new Pipe());
  gameOver = false;
  recentScore = score; // Simpan recent score sebelum di-reset
  score = 0;
  chickenY = height / 2;
  chickenSpeed = 0;
}

class Pipe {
  float top;
  float bottom;
  float x;
  float w = 40;
  float speed = 2;
  boolean counted = false;
  Pipe() {
    top = random(height / 2);
    bottom = random(height / 2);
    x = width;
  }

  void update() {
    x -= speed;
  }

  void show() {
    image(pipeTopImg, x, 0, w, top);
    image(pipeBottomImg, x, height - bottom, w, bottom);
  }

  boolean hits(float chickenY) {
    if (chickenY < top || chickenY > height - bottom) {
      if (50 > x && 50 < x + w) {
        return true;
      }
    }
    return false;
  }

  boolean passed() {
    if (x + w < 50 && x + w > 45 && !counted) {
      counted = true;
      return true;
    }
    return false;
  }
}
