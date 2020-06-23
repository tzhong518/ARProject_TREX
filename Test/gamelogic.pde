import java.util.LinkedList;
import java.sql.Timestamp;
import java.util.Random;

class GameWorld {
    // 500 * 500
    PVector size;
    Dino dino;
    Hammer hammer;
    LinkedList<Barrier> barriers;
    int baseScore;
    int score;
    int highScore;
    boolean isOver;
    Random r;
    int interval;

    GameWorld() {
        size = new PVector(500, 500, 0);
        reset();

        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        r = new Random(timestamp.getTime());
        interval = 0;
    }

    void reset() {
        dino = new Dino();
        hammer = new Hammer();
        barriers = new LinkedList<Barrier>();
        score = 0;
        baseScore = 0;
        isOver = false;
    }

    boolean checkNewBarrier() {
        if (barriers.isEmpty()) {
            return true;
        }

        Barrier last = barriers.getLast();
        if (size.x - last.pos.x >= interval) {
            int base = 100;
            int rand = r.nextInt(100);
            interval = base + rand;
            return true;
        }

        return false;
    }

    boolean checkCollision() {
        if (barriers.isEmpty()) return false;

        float dinoX1 = dino.pos.x;
        float dinoX2 = dino.pos.x + dino.width;
        
        // //original version
        // for (Barrier barrier : barriers) {
        //     if (dino.pos.y >= barrier.height) {
        //         continue;
        //     }

        //     float barrierX1 = barrier.pos.x;
        //     float barrierX2 = barrier.pos.x + barrier.width;

        //     if (barrierX1 > dinoX1 && barrierX1 < dinoX2) return true;
        //     if (barrierX2 > dinoX1 && barrierX2 < dinoX2) return true;
        // }

        //kitayama test
        float dinoY1 = dino.pos.y;
        float dinoY2 = dino.pos.y + dino.height;
        for (Barrier barrier : barriers) {
            if(barrier.checkCollision(dinoX1, dinoX2, dinoY1, dinoY2)){
                return true;
            }
        }

        return false;
    }

    void update() {
        // println("frameRate: "+frameRate);
        
        if (isOver) {
            return;
        }

        dino.update();
        for (Barrier barrier : barriers) {
            barrier.update();
        }

        baseScore += 10;
        score = baseScore / 100 * 10;
        if (score > highScore) {
            highScore = score;
        }

        if (checkNewBarrier()) {

            // // original version
            // Barrier newBarrier = new Barrier();

            //kitayama test
            Barrier newBarrier;
            int rand = r.nextInt(10);
            if(rand < 3){
                newBarrier = new Cactus();
            } else if(5 <= rand && rand < 5){
                newBarrier = new Ptera();
            } else{
                newBarrier = new Wall();
            }

            barriers.add(newBarrier);
        }

        if (checkCollision()) {
            isOver = true;
        }

        if (!barriers.isEmpty()) {
            Barrier first = barriers.getFirst();
            if (first.pos.x + first.width < 0) {
                barriers.removeFirst();
            }
        }
    }

    void draw() {
        new Cource().draw();
        dino.draw();
        hammer.draw();

        for (Barrier barrier : barriers) {
            barrier.draw();
        }
    }

    void dinoJump() {
        if (isOver) {
            reset();
            isOver = false;
        }

        if (dino.pos.y == 0) {
            dino.jump();
        }
    }

    void useHammer(){

        // //like jump buttom
        // if (barriers.getFirst() instanceof Wall) {
        //     barriers.removeFirst();
        // }

        //hammer move to wall        
        int index = 0;
        int toRemv = -1;
        for(Barrier barrier : barriers){
            if(barrier instanceof Wall){
                if(hammer.checkCollision(barrier)){
                    toRemv = index;
                    break;
                }
            }
            index ++;
        }
        if (toRemv > -1){
            barriers.remove(toRemv);
        }
    }
}

class Dino {
    PVector pos;
    float width;
    float height;
    float jumpSpeed;
    boolean isJumping;
    PShape Body, LegR, LegL;
    
    // for animation
    float theta_leg = 0;
    float range_leg = 30;
    boolean inc = true;
    float leg_offx = -10 * gameScale * 0.001;
    float leg_offy = -30 * gameScale * 0.001;
    float leg_offz = -5 * gameScale * 0.001;
    float leg_offtheta = -10;
    
    Dino() {
        pos = new PVector(100, 0, 0);
        width = 50;
        height = 100;
        isJumping = false;
        Body = loadShape("Model_files" + File.separator + "T-body.obj");
        LegR = loadShape("Model_files" + File.separator + "T-legR.obj");
        LegL = loadShape("Model_files" + File.separator + "T-legL.obj");
        Body.width = this.width;
        Body.height = this.height;
        Body.scale(gameScale);
        LegL.scale(gameScale);
        LegR.scale(gameScale);

    }

    void update() {
        if (isJumping) {
            jumpSpeed -= 60 / frameRate;
            println("jumpSpeed: "+jumpSpeed);
            pos.y += jumpSpeed;
            if (pos.y < 0) {
                pos.y = 0;
                isJumping = false;
            }
        }
    }

    void jump() {
        jumpSpeed = 30;
        isJumping = true;
    }

    void draw() {
        float dinoZOff = -this.pos.y * gameScale * 0.001;
        if (pose_plane != null) {
            pushMatrix();
                applyMatrix(pose_plane); 
                translate(dinoXOff, dinoYOff,dinoZOff);
                rotateX(radians(90));
                shape(Body);
                
                // set leg angle
                if(inc){
                    theta_leg += 6;
                }else{
                    theta_leg -= 6;
                }
                if(theta_leg >= range_leg){
                    inc = false;
                }else if(theta_leg <= -range_leg){
                    inc = true;
                }

                // draw right leg
                pushMatrix();
                    translate(leg_offx, leg_offy, leg_offz);
                    rotateX(radians(leg_offtheta));
                    rotateX(radians(theta_leg));
                    shape(LegR);
                popMatrix();

                // draw left leg
                pushMatrix();
                    translate(-leg_offx, leg_offy, leg_offz);
                    rotateX(radians(leg_offtheta));
                    rotateX(radians(-theta_leg));
                    shape(LegL);
                popMatrix();
            popMatrix();
        }
    }
}

class Barrier {
    PVector pos;
    float width;
    float height;
    float length;
    float speed;

    Barrier() {
        pos = new PVector(1000, 0, 0);
        width = 40;
        height = 80;
        speed = 300;
    }

    void update() {
        pos.x -= speed / frameRate;
    }

    void draw() {}
    boolean checkCollision(float dinoX1, float dinoX2, float dinoY1, float dinoY2){
        return false;
    }
}

class Cactus extends Barrier{
    PShape cactus_body, cactus_top;
    int nOfBlocks;

    Cactus(int nOfBlocks){
        pos = new PVector(1000, 0, 0);
        this.nOfBlocks = nOfBlocks;
        width = 40;
        height = nOfBlocks*20;
        cactus_body = loadShape("./Model_files/Cuctas_body.obj");
        cactus_body.width = this.width;
        cactus_body.height = 20;
        cactus_body.scale(gameScale);
        cactus_top = loadShape("./Model_files/Cuctas_top.obj");
        cactus_top.width = this.width;
        cactus_top.height = 20;
        cactus_top.scale(gameScale);
    }

    Cactus(){
        this(4);
    }


    void draw(){
        float barrierZOff = -this.height*gameScale*0.001;
        float barrierYOff = -(this.pos.x-100) * gameScale * 0.001;
        if (pose_plane != null) {
            pushMatrix();
                applyMatrix(pose_plane); 
                translate(0, barrierYOff, barrierZOff);
                for(int i=0; i<nOfBlocks-1; i++){
                    shape(cactus_body);
                    translate(0, 0, 20*gameScale*0.001);
                }
                shape(cactus_top);
            popMatrix();
        }
    }

    boolean checkCollision(float dinoX1, float dinoX2, float dinoY1, float dinoY2){
        if (dinoY1 >= this.height) {
            return false;
        }

        float barrierX1 = this.pos.x;
        float barrierX2 = this.pos.x + this.width;

        if (barrierX1 > dinoX1 && barrierX1 < dinoX2) return true;
        if (barrierX2 > dinoX1 && barrierX2 < dinoX2) return true;

        return false;
    }
}

class Ptera extends Barrier{
    PShape ptera;

    Ptera(){
        pos = new PVector(1000, 100, 0);
        width = 80;
        height = 40;
        ptera = loadShape("./Model_files/Ptera.obj");
        ptera.width = this.width;
        ptera.height = this.height;
        ptera.scale(gameScale);
        ptera.rotateY(radians(180));
        
    }

    void draw(){
        float barrierYOff = -(this.pos.x-100) * gameScale * 0.001;
        float barrierZOff = -(this.pos.y) * gameScale * 0.001;
        if (pose_plane != null) {
            pushMatrix();
                applyMatrix(pose_plane); 
                translate(0, barrierYOff, barrierZOff);
                rotateX(radians(90));
                shape(ptera);
            popMatrix();
        }
    }

    
    boolean checkCollision(float dinoX1, float dinoX2, float dinoY1, float dinoY2){
        float barrierX1 = this.pos.x;
        float barrierX2 = this.pos.x + this.width;
        float barrierY1 = this.pos.y;
        float barrierY2 = this.pos.y + this.height;

        if (barrierX1 > dinoX1 && barrierX1 < dinoX2 && barrierY1 > dinoY1 && barrierY1 < dinoY2) return true;
        if (barrierX1 > dinoX1 && barrierX1 < dinoX2 && barrierY2 > dinoY1 && barrierY2 < dinoY2) return true;
        if (barrierX2 > dinoX1 && barrierX2 < dinoX2 && barrierY1 > dinoY1 && barrierY1 < dinoY2) return true;
        if (barrierX2 > dinoX1 && barrierX2 < dinoX2 && barrierY2 > dinoY1 && barrierY2 < dinoY2) return true;

        return false;
    }
}

class Wall extends Barrier{
    Wall(){
        width = 40;
        height = 300;
        length = 160;
    }

    void draw(){
        // float barrierZOff = -this.height*gameScale*0.001;
        float barrierYOff = -(this.pos.x-100) * gameScale * 0.001;
        if (pose_plane != null) {
            pushMatrix();
                applyMatrix(pose_plane); 
                translate(0, barrierYOff, 0);
                noStroke();
                fill(0);
                box(this.length*gameScale*0.001,this.width*gameScale*0.001,this.height*gameScale*0.001);
            popMatrix();
        }
    }
    
    boolean checkCollision(float dinoX1, float dinoX2, float dinoY1, float dinoY2){
        float barrierX1 = this.pos.x;
        float barrierX2 = this.pos.x + this.width;

        if (barrierX1 > dinoX1 && barrierX1 < dinoX2) return true;
        if (barrierX2 > dinoX1 && barrierX2 < dinoX2) return true;

        return false;
    }
}

class Cource{
    float width, length;

    Cource(float width, float length){
        this.width = width;
        this.length = length;
    }
    
    Cource(){
        this(200, 1000);
    }

    void draw(){
        float draw_scale = gameScale * 0.001;
        if (pose_plane != null) {
            pushMatrix();
                applyMatrix(pose_plane); 
                noStroke();
                fill(153, 76, 0);
                translate(0, (-(length/2)+100)*draw_scale, 0);
                box(width*draw_scale, length*draw_scale, 0);
            popMatrix();
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Because I'm not sure about game logic part, I set them just for Modeling and they may be improper
//
////////////////////////////////////////////////////////////////////////////////////////////////////

class Hammer{
    PVector pos;
    float width;
    float height;

    // parameters of hammer head
    float radius = 10 * gameScale;
    float length = 50 * gameScale;
    int sides = 20;

    // parameter of body
    float square = 10 * gameScale;
    float tall = 100 * gameScale;

    float draw_scale = 0.001;
    float tall_draw = tall * draw_scale;

    Hammer(){
    }

    void draw(){
        float draw_scale = 0.001;
        float radius_draw = radius * draw_scale;
        float length_draw = length * draw_scale;
        float square_draw = square * draw_scale;
        float tall_draw = tall * draw_scale;

        if (pose_hammer!=null){
            pushMatrix();
                // adjust coordinates
                applyMatrix(pose_hammer);
                translate(0, 0, -tall_draw/2);
                rotateX(radians(90));

                if(GAME_DEBUG){
                noFill();
                    strokeWeight(3);
                    stroke(255, 0, 0);
                    line(0, 0, 0, 0.02, 0, 0); // draw x-axis
                    stroke(0, 255, 0);
                    line(0, 0, 0, 0, 0.02, 0); // draw y-axis
                    stroke(0, 0, 255);
                    line(0, 0, 0, 0, 0, 0.02); // draw z-axis 
                }

                // body
                noStroke();
                fill(128, 75, 0);
                box(square_draw, tall_draw, square_draw);

                // head
                noStroke();
                fill(0);
                pushMatrix();
                    translate(-(length_draw)/2, -tall_draw/2, 0);
                    rotateZ(radians(-90));
                    drawCylinder(radius_draw, radius_draw, length_draw, sides);
                popMatrix();
            popMatrix();
        }
    }

    boolean checkCollision(Barrier wall){
        PMatrix3D pose_hammer_gw = pose_plane.get();
        pose_hammer_gw.invert();
        pose_hammer_gw.apply(pose_hammer);

        float x_ = ( -pose_hammer_gw.m02 * tall_draw + pose_hammer_gw.m03);///(draw_scale*gameScale);
        float y_ = ( -pose_hammer_gw.m12 * tall_draw + pose_hammer_gw.m13);///(draw_scale*gameScale);
        float z_ = ( -pose_hammer_gw.m22 * tall_draw + pose_hammer_gw.m23);///(draw_scale*gameScale);
        
        PVector hammer_point = new PVector(x_,y_,z_);
        this.pos = new PVector(-hammer_point.y*1000/gameScale, -hammer_point.x*1000/gameScale, -hammer_point.z*1000/gameScale);

        float wallX1 = wall.pos.x - 100;
        float wallX2 = wall.pos.x - 100 + wall.width;
        float wallY1 = wall.pos.y - wall.length/2;
        float wallY2 = wall.pos.y + wall.length/2;
        float wallZ1 = wall.pos.z;
        float wallZ2 = wall.pos.z + wall.height;

        if (GAME_DEBUG){
            println("pos.x: "+pos.x);
            println("pos.y: "+pos.y);//
            println("pos.z: "+pos.z);//
            println("wallZ1: "+wallZ1);
            println("wallZ2: "+wallZ2);
            println("wallY1: "+wallY1);
            println("wallY2: "+wallY2);
        }

        if ((wallX1 < this.pos.x && this.pos.x < wallX2) && (wallY1 < this.pos.y && this.pos.y < wallY2) && (wallZ1 < this.pos.z && this.pos.z < wallZ2)) return true;

        return false;
    }
}
