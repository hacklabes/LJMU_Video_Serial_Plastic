import processing.video.*;
import processing.serial.*;

String movieFiles[] = {
  "movie0.mp4", 
  "movie1.mp4", 
  "movie2.mp4", 
  "movie3.mp4", 
  "movie4.mp4"
};
boolean[] isPlaying;
Movie[] mMovies;

Serial mPort;


void setup() {
  size(640, 480);
  smooth();
  background(0);

  for (String s : Serial.list ()) {
    if (s.contains("tty") && s.contains("usbmodem")) {
      mPort = new Serial(this, s, 57600);
      println(s);
      break;
    }
  }

  isPlaying = new boolean[movieFiles.length];
  mMovies = new Movie[movieFiles.length];

  for (int i=0; i<movieFiles.length; i++) {
    mMovies[i] = new Movie(this, dataPath(movieFiles[i]));
    mMovies[i].jump(mMovies[i].duration());
    isPlaying[i] = !(abs(mMovies[i].time() - mMovies[i].duration()) < 0.1);
  }
}

void draw() {
  for (int i=0; i<movieFiles.length; i++) {
    if (mMovies[i].available()) {
      mMovies[i].read();
    }
  }

  int triggeredIndex = movieFiles.length;
  while (mPort.available () >= 3) {
    // check for message header (0xDEAD)
    int h = mPort.read();
    boolean sawFirstHeaderByte = false;
    while (h == 0xDE) {
      h = mPort.read();
      sawFirstHeaderByte = true;
    }
    if ((h == 0xAD) && (sawFirstHeaderByte)) {
      triggeredIndex = mPort.read();
      if (abs(mMovies[triggeredIndex].time() - mMovies[triggeredIndex].duration()) < 0.1) {
        mMovies[triggeredIndex].jump(0);
        mMovies[triggeredIndex].play();
      }
      println(triggeredIndex+" was triggered");
    }
  }

  int numPlaying = 0;
  for (int i=0; i<movieFiles.length; i++) {
    isPlaying[i] = !(abs(mMovies[i].time() - mMovies[i].duration()) < 0.1);
    numPlaying += (isPlaying[i])?1:0;
  }

  if (numPlaying == 0) {
    fill(0, 4);
    noStroke();
    rect(0, 0, width, height);
  } else {
    background(0);
    for (int i=0; i<movieFiles.length; i++) {
      if (isPlaying[i]) {
        tint(255, 255/numPlaying);
        image(mMovies[i], 0, 0);
      }
    }
  }
}


