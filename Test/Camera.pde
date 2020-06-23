boolean isReady(ArrayList<Marker> markers, boolean isReady){
    int markerNum = markers.size();
    fill(255, 0, 0);
    textSize(40);
    if (markerNum <2){   
        fill(255, 0, 0);
        textSize(40);
        text("Marker not enough ", width/2, height/2);
        isReady = false;
    }else{
        isReady = true;
    }

    return isReady;
}

// int isStart(HashMap<Integer, PMatrix3D> markerPoseMap, boolean isStart, int[] actionList, int cntNoJump){
//     PMatrix3D pose_jump = markerPoseMap.get(actionList[0]);
//     if (pose_jump == null){
//         cntNoJump ++;
//     }else{
//         cntJump ++;
//     }
//     if (cntNoJump > 10){
//         fill(255, 0, 0);
//         textSize(40);
//         int resTime = ceil((41 - cntNoJump)/10);
//         text("Start in " + resTime, width/2, height/2-10);
//     }
//     return cntNoJump;
// }

void gameStart(ArrayList<Marker> markers){
        pushMatrix();        
        translate(-width/2, -height/2,-(height/2)/tan(radians(fov)));
        if (isStart == false && isReady == false){
            isReady = isReady(markers, isReady);
        }
        if (isStart == false && isReady == true){
            fill(255);
            rect(width/2-100,  height/2-60, 200,80);
            cntDown ++;
            if  (cntDown < frameRate){
                fill(255, 0, 0);
                textSize(40);
                textAlign(CENTER);
                text("Ready!", width/2, height/2);
            }
            if (cntDown >= frameRate){
                int resTime = ceil((frameRate*2 + 1 - cntDown)/frameRate);
                fill(255, 0, 0);
                textSize(40);
                textAlign(CENTER);
                text("Start in " + resTime, width/2, height/2-10);
            }
            if (cntDown > frameRate*2)
                isStart = true;           
        }
        if (world.isOver == true){
            fill(255);
            rect(width/2-220,  height/2-60, 440,80);
            fill(255, 0, 0);
            textSize(40);
            textAlign(CENTER);
            text("Press jump to restart", width/2, height/2-10);
        }
        // show score
        if (isStart){
            frameCnt ++;
            fill(255, 0, 0);
            text("Score \n" + world.score, width-200, 50);
            text("High Score \n" + world.highScore, 200, 50);
        }
    popMatrix();
}
boolean isJump(PMatrix3D pose_jump, boolean isStart, boolean isJump){
    if (isJump == false && pose_jump == null){
        isJump = true;
    }   
    if (isJump == true && pose_jump == null){
        isJump = false;
    }

    return isJump;
}

void drawJumpBotton(PMatrix3D pose_jump){
    // draw jump botton
    if (pose_jump != null){
        pushMatrix();
            applyMatrix(pose_jump);
            rotateX(90);
            noStroke();
            fill(255, 120, 0);
            drawCylinder(0.003, 0.003, 0.003, 32);
        popMatrix();
    }
}

void drawScene(boolean isReady, boolean isStart){
    // draw scene if ready
    if (isReady && pose_plane != null){       
      pushMatrix();         
        applyMatrix(pose_plane); 
        // course
        // drawCourse(0.5);
        
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
        
        // draw barriers 
        // for (Barrier barrier : world.barriers){
        //   float barrierOff = -(barrier.pos.x-100) * gameScale; //
        //   pushMatrix();
        //     translate(0, barrierOff, 0);
        //     box(0.008, 0.008, 0.016); 
        //     // println("barrierOff: "+barrierOff);
        //     //drawObj(sceneSize); // render
        //   popMatrix();
        // }
      popMatrix();
      drawJumpBotton(pose_jump);
    }
}

/*
void drawDino(boolean isStart){
    // draw dino if start
    if (isStart && pose_plane != null){
        // detect jump action
        if ((world.dino.isJumping == false && pose_jump == null) || (world.isOver == true && pose_jump == null)){
          world.dinoJump();
        } 
        
        world.update();

        // jump height
        float dinoZOff = -world.dino.pos.y * gameScale; 
        println("dinozoff:"+world.dino.pos.y);
        // draw dino model
        pushMatrix();
            applyMatrix(pose_plane); 
            translate(dinoXOff, dinoYOff,dinoZOff);
            rotateX(90);
            drawTrex(0.3); // height 0.03m?
        popMatrix();

        // draw game logic world
        ortho();       
        pushMatrix();
          translate(-width/2, -height/2,-(height/2)/tan(radians(fov)));
        //   world.draw();
        popMatrix();
    }
}
*/
