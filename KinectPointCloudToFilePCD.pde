/* Based on parts of Daniel Shiffmans Kinect Point Cloud demos
   Purpose: Use Kinect v1, get point cloud, transform to world coordinates, save a 3d-frame in PCD format.*/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// Kinect Library object
Kinect kinect;

float a = 0;
float deg;

//reduce point resolution in x and y by a factor
int skip = 2;

// variables for loop mechanics
int countDepth = 0, counter = 0, writeCount = 0, c1 = 0, c2 = 0;
boolean runonce = true;
boolean runonce2 = true;

// array to store the metric depth values  
float[] depthLookUp = new float[2048];

// Arrays to store all the xyz values
float[] xarr = new float[640];
float[] yarr = new float[480];
Double[] zarr = new Double[307200];

//Create File
PrintWriter output;

// Initial pixel depth filter. Can also be adjusted real time with 'z' and 'x'.  
int minDepth =  60;
int maxDepth = 1028;

double identifier = java.lang.Double.NaN;    // depth pixels outside filter to NaN, required by the PCD format.


/*----------------------------------------Setup Runs Once--------------------------------------------*/

void setup(){
  size(640, 480, P3D);
  kinect = new Kinect(this);
  kinect.initDepth();
  deg = kinect.getTilt();
  
  // Lookup table for all possible depth values (0 - 2047)
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
}


/*-----------------------------------Process Data real time and visualize---------------------------------------*/


void draw(){  
  background(0);
  // Get depth in integer array 0-2048
  int[] depth = kinect.getRawDepth();    

  //Translate rotate
  translate(kinect.width/2, kinect.height/2, -50);    // center the pixels for display in window
  //rotateY(a);
  for(int x = 0; x < kinect.width; x+=skip){ //<>//
    for(int y = 0; y < kinect.height; y+=skip){
      int offset = x + y * kinect.width;
      if(depth[offset] >= minDepth && depth[offset] <= maxDepth){
        // raw data to world coord.
        PVector v = depthToPointCloudPos(x, y, depth[offset]);
        
        // draw the stuff
        stroke(255);
        pushMatrix();
        float factor = 200;  // making it easier for the eyes.  
        translate(v.x*factor, v.y*factor, factor-v.z*factor);
        point(0,0);
        popMatrix();
      } 
    }
    runonce2 = false;
  }
  //a += 0.015f; //<>//
}



/*-----------------------------------Interaction, process, save to file---------------------------------------*/
// Press 'w' multiple times to create additional files with new point cloud data each time. 

void keyPressed() {
  
  if (key == 'w') {
    int[] depth = kinect.getRawDepth();
    for(int x = 0; x < kinect.width; x+=skip){
      for(int y = 0; y < kinect.height; y+=skip){
        int offset = x + y * kinect.width;
        if(depth[offset] >= minDepth && depth[offset] <= maxDepth){
          PVector v = depthToPointCloudPos(x, y, depth[offset]);
          xarr[x] = v.x;
          yarr[y] = v.y;
          zarr[countDepth] = (double)v.z;
        } else{
            zarr[countDepth] = identifier;     //set irrelevant pixels to NaN //<>//
          }
        countDepth++;
      }
    }
    countDepth = 0;
    String num = str(writeCount);
    output = createWriter("frame"+num+".pcd");
    output.println("VERSION .7");
    output.println("FIELDS x y z");
    output.println("SIZE 4 4 8");
    output.println("TYPE F F F");
    output.println("COUNT 1 1 1");
    output.println("WIDTH 307200");
    output.println("HEIGHT 1");
    output.println("VIEWPOINT 0 0 0 1 0 0 0");
    output.println("POINTS 307200");
    output.println("DATA ascii");
    println("Writing to file...");
    for(int x = 0; x < kinect.width; x+=skip){
      for(int y = 0; y < kinect.height; y+=skip){
        output.println(xarr[x] +" "+ yarr[y] +" "+ zarr[counter]);
        counter++;
      }
    }
    writeCount++;
    counter = 0;

    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
    println("Done Writing - press e key to exit.");
  } else if(key == 'e'){
      exit(); // Stops the program
  } else if (key == CODED) {
      if (keyCode == UP) {
        deg++;
      } else if (keyCode == DOWN) {
          deg--;
      }
        deg = constrain(deg, 0, 30);
        kinect.setTilt(deg);
  } else if (key == 'z') {
      maxDepth = constrain(maxDepth+10, minDepth, 2047);
  } else if (key =='x') {
      maxDepth = constrain(maxDepth-10, minDepth, 2047);
  }
}


/*-----------------------------------Functions, coordinate transformations---------------------------------------*/


// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

// calc xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, int depthValue){
  PVector point = new PVector();
  
  double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
  point.z = (float)(depth);  // to meters                                  // z in meters
  point.x = (float)(x - CameraParams.cx) * point.z / CameraParams.fx;      //(u - cx) * z / fx
  point.y = (float)(y - CameraParams.cy) * point.z / CameraParams.fy;      //(v - cy) * z / fy
  return point;
}