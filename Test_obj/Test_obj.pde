float fov = 45;

void setup(){
    size(512, 512, P3D);

    smooth();

    PMatrix3D cameraMat = ((PGraphicsOpenGL)g).camera;
    cameraMat.reset();
}

void draw(){
    background(100);
    perspective(radians(fov), float(width)/float(height), 0.01, 1000.0);

    translate(0, 0.05, -0.5);

    lights();

    rotateX(radians(-30));
    rotateY(radians(-60));
    

    drawTrex(2);
}