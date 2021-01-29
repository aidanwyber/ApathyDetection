import gab.opencv.*;
import processing.video.*;

//Movie video;
Capture video;
OpenCV opencv;


boolean saveFrames = false;
int savedFrameCount = 0;

int maxPts = 200;
int minNContours = 50;

ArrayList<PVector> plocs = new ArrayList<PVector>();
ArrayList<PVector> plocsSmoothed = new ArrayList<PVector>();


void setup() {
  size(1280, 720);
  //  video = new Movie(this, "street.mov");
  println(Capture.list());
  video = new Capture(this, width, height);
  opencv = new OpenCV(this, width, height);

  opencv.startBackgroundSubtraction(5, 3, 0.5);

  //  video.loop();
  video.start();
  noLoop();
}

void draw() {
  /////////////////////////////////////////////
  // do anything here????
}

void captureEvent(Capture c) {
  c.read();

  image(video, 0, 0);  
  opencv.loadImage(video);

  opencv.updateBackground();

  opencv.dilate();
  opencv.erode();

println(opencv.findContours ().size());
  if (opencv.findContours ().size() > minNContours) {

    noFill();
    stroke(255, 0, 0);
    strokeWeight(3);

    int amtTot = 0;
    PVector avTot = new PVector(0, 0);
    for (Contour contour : opencv.findContours ()) {
      //    contour.draw();
      strokeWeight(2);
      stroke(255, 0, 0);
      beginShape();
      PVector avCont = new PVector(0, 0);
      int amtCont = 0;
      for (PVector point : contour.getPoints ()) {
        vertex(point.x, point.y);
        avCont.add(point);
        amtTot++;
        //        amtCont++;
      }
      endShape();
      //      avCont.div(amtCont);
      //      amtTot++;

      strokeWeight(10);
      stroke(0, 255, 255);
      point(avCont.x, avCont.y);
      avTot.add(avCont);
    }
    avTot.div(amtTot);
    stroke(255, 255, 0);
    point(avTot.x, avTot.y);

    plocs.add(avTot);
  } else if (plocs.size() > 0) {
    plocs.add(plocs.get(plocs.size()-1));
  }
  if (plocs.size() > maxPts) {
    plocs.remove(0);
  }

  strokeWeight(2);
  stroke(255, 255, 0);
  float totDist = 0;
  for (int i = plocs.size ()-1; i >= 1; i--) {
    PVector a = plocs.get(i);
    PVector b = plocs.get(i - 1);
    line(a.x, a.y, b.x, b.y);
    totDist += dist(a.x, a.y, b.x, b.y);
  }
  textSize(20);
  text(totDist / frameRate, 10, 20);

  ///// SMOOTH
  plocsSmoothed.clear();
  strokeWeight(2);
  stroke(0, 255, 0);
  beginShape();
  for (int i = plocs.size ()-1; i >= 1; i--) {
    PVector a = plocs.get(i).get();
    PVector b = plocs.get(i - 1).get();
    a.add(b);
    a.div(2);
    plocsSmoothed.add(a);
    vertex(a.x, a.y);
  }
  endShape(OPEN);

  redraw();
  
  if (saveFrames) {
    saveFrame("frames/"+SSID+"####.jpg"); 
  }
}


import gifAnimation.*;
GifMaker gifExport;
boolean exportGif = false;
int SSID = (int) random(9999999);
boolean playing = true;
boolean savePDF = false;

void keyPressed() {
  switch (key) {
  case ' ':
    playing = !playing;
    break;
  case 's':
    saveFrame("output/"+SSID+"####.jpg"); 
    println("Saved PNG");
    break;
  case 'g':
    if (!exportGif) {
      gifExport = new GifMaker(this, "outputGif/animExport" + SSID + ".gif", 100);
      gifExport.setRepeat(0);
      //gifExport.setTransparent(0,0,0);
      exportGif = true;  
      println("Started recording GIF");
    } else {
      exportGif = false;
      gifExport.finish();
      println("Saved GIF");
    }
    break;
  case 'f':
    saveFrames = !saveFrames;
    savedFrameCount = 0;
    break;
  case 'p':
    savePDF = true;
    SSID = (int) random(9999999);
    println("Saved PDF.");
    break;
  case 'c':
    plocs.clear();
    break;
  }
}

