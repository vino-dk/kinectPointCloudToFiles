# kinectPointCloudToFiles
This Processing program captures point cloud frames from the Kinect v1, converts it to metric world coordinates and saves the frame in PCD format.

## Basic usage
Running the program creates a window with real time visualisation of the point cloud. Pressing 'w' prints the point cloud frame in metric world coordinates to a PCD file for further analysis. Before capture, the depth level can be adjusted real time with 'z' and 'x' for increasing and decreasing the depth, respectively.

Multiple files can be saved while the program runs, just press 'w' again after an eg. adjustment in position.

The captured resolution can be changed in the program by adjusting the value for 'skip'.

## Reference
The OpenKinect library has been ported to Processing by Daniel Shiffman. Parts of the demos have been used in order to make the program for this specific purpose. More information about the Processing approach to Kinect here:
http://shiffman.net/p5/kinect/
