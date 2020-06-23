/**
 * Drawing Trex.
 * Default T-Rex's height is 0.1[m].
 * Origin of the object is between the foots.
 * T-REX faces the direction of x-axis.
 * @param scale : scaling factor of T-rex's size
 */
void drawTrex(float scale){
    PShape Trex;

    Trex = loadShape("TREX.obj");

    Trex.scale(scale);
    pushMatrix();
        rotateY(radians(90));
        shape(Trex);
    popMatrix();
    println("Draw T-REX");
}

void drawTrex(){
    drawTrex(1);
}


/**
 Drawing Cuctas
 It consists of Top and Body
 Default length of Cuctas block's edge is 0.03[m].
 Origin of the object is bottom center.
 @ param scale : scaling factor of Cactus's size
 @ param nOfBlocks : (nOfBlocks - 1) Body blocks are piled and then a Top block
 */
void drawCuctas(float scale, int nOfBlocks){
    PShape Cactas;
    
    // load and scale .obj files of Cuctas

    // set (nOfBlocks - 1) Body blocks

    // set a Top block on them
    println("Draw Cuctas");
}

void drawCuctas(int nOfBlocks){
    drawCuctas(1, nOfBlocks);
}

/**
 Drawing Course.
 Default length is 0.6[m] and width is 0.15[m].
 Origin of the object is center of the plane.
 The direction of length belongs x-axis.
 @ param scale : scaling factor of plane size
 */
void drawCourse(float scale){
    float length = 0.6 * scale;
    float width = 0.15 * scale;

    

    println("Draw Course");
}

void drawCourse(){
    drawCourse(1);
}

 

