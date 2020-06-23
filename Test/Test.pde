import gab.opencv.*;
import processing.video.*;

final boolean MARKER_TRACKER_DEBUG = false;
final boolean BALL_DEBUG = false;
final boolean GAME_DEBUG = true;

final boolean USE_SAMPLE_IMAGE = false;

final boolean USE_DIRECTSHOW = true;

// final double kMarkerSize = 0.036; // [m]
final double kMarkerSize = 0.01; // [m] 2.4cm

Capture cap;
DCapture dcap;
OpenCV opencv;

float fov = 45; // for camera capture

// Marker codes of scene and action
final int[] sceneList = {0x005A};
final int[] actionList = {0x0272, 0x1c44}; // 0x0272: jump, 0x1c44: hammer

HashMap<Integer, PMatrix3D> markerPoseMap;
PMatrix3D pose_plane;
PMatrix3D pose_jump;
PMatrix3D pose_hammer;

MarkerTracker markerTracker;
PImage img;

KeyState keyState;

// control
boolean isReady = false;
boolean isStart = false;
int cntDown = 0;
boolean isJump = false;

int frameRate = 20;
int frameCnt = 0;

// model parameters
float sceneScale = 0.02;
float dinoScale = 0.02;
float dinoXOff = 0;
float dinoYOff = 0;

// scale game logic
// float gameScale = 0.00015;
float gameScale = 0.1;

GameWorld world;

boolean isRec = false;

void selectCamera() {
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default");
    cap = new Capture(this, 640, 480);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    //cap = new Capture(this, cameras[5]);

    // Or, the settings can be defined based on the text in the list
    cap = new Capture(this, 1280, 720, "USB2.0 HD UVC WebCam", 30);
  }
}

void settings() {
  if (USE_SAMPLE_IMAGE) {
    // Here we introduced a new test image in Lecture 6 (20/05/27)
    size(1280, 720, P3D);
    opencv = new OpenCV(this, "./Maker_sample/marker_test2.jpg");
    // size(1000, 730, P3D);
    // opencv = new OpenCV(this, "./marker_test.jpg");
  } else {
    if (USE_DIRECTSHOW) {
      dcap = new DCapture();
      size(dcap.width, dcap.height, P3D);
      opencv = new OpenCV(this, dcap.width, dcap.height);
    } else {
      selectCamera();
      size(cap.width, cap.height, P3D);
      opencv = new OpenCV(this, cap.width, cap.height);
    }
  }
}

void setup() {
    background(0);
    smooth();
    frameRate(frameRate);

    markerTracker = new MarkerTracker(kMarkerSize);

    if (!USE_DIRECTSHOW)
        cap.start();

    PMatrix3D cameraMat = ((PGraphicsOpenGL)g).camera;
    cameraMat.reset();

    keyState = new KeyState();

    markerPoseMap = new HashMap<Integer, PMatrix3D>();  // hashmap (code, pose)

    world = new GameWorld();
    //world.speedScale = 0.01;
    //win = new PWindow();
}

void draw() {
    ArrayList<Marker> markers = new ArrayList<Marker>();
    markerPoseMap.clear();

    if (!USE_SAMPLE_IMAGE) {
        if (USE_DIRECTSHOW) {
            img = dcap.updateImage();
            opencv.loadImage(img);
        } else {
            if (cap.width <= 0 || cap.height <= 0) {
            println("Incorrect capture data. continue");
            return;
            }
            opencv.loadImage(cap);
        }
    }

  // use orthographic camera to draw images and debug lines
  // translate matrix to image center
    ortho();
    pushMatrix();
        translate(-width/2, -height/2,-(height/2)/tan(radians(fov)));
        markerTracker.findMarker(markers);
    popMatrix();

    for (int i = 0; i < markers.size(); i++) {
        Marker m = markers.get(i);
        markerPoseMap.put(m.code, m.pose);
    }
    
    // ready if enough markers, start if last for 2 sec
    gameStart(markers);

    // use perspective camera 
    perspective(radians(fov), float(width)/float(height), 0.01, 1000.0);

    // setup light
    ambientLight(180, 180, 180);
    directionalLight(180, 150, 120, 0, 1, 0);
    lights();    

    // marker poses
    pose_plane = markerPoseMap.get(sceneList[0]);
    pose_jump = markerPoseMap.get(actionList[0]);
    pose_hammer = markerPoseMap.get(actionList[1]);

    if (isStart && pose_plane != null){
      // detect jump action
      if ((world.dino.isJumping == false && pose_jump == null) || (world.isOver == true && pose_jump == null)){
        world.dinoJump();
      }


      // hammer action

      // // like jump bottom
      // if (pose_hammer == null){
      //   world.useHammer();
      // }
      
      // // hammer move to wall
      if (pose_hammer != null){
        world.useHammer();
      }

      if(GAME_DEBUG){
        if ((world.dino.isJumping == false && (keyPressed == true && key == 'j')) || (world.isOver == true && (keyPressed == true && key == 'j'))){
          world.dinoJump();
        }

        if (keyPressed == true && key == 'b'){
          world.useHammer();
        }
      }

      world.update();
    }

    // draw
    // the red cylinder is jump button  
    drawScene(isReady, isStart);
    world.draw();

    if (mousePressed == true){
      isRec = !isRec;
    }
    if (isRec){
      saveFrame("./video/demo-####.jpg");
    }
    
    // println(pose_hammer != null);


    // drawDino(isStart);
}
