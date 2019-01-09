# People_Tracking_PIV
Track people in a sequence of images. Project for the course of Image and Vision Processing

Identifying people moving with a fixed Kinect camera.

Identification of the background (static)
	- using the median of pixels method
Identify the floor surface using the RANSAC (Random sampling consensus) method, and reorient the refencial to make the floor coincide with the xy plane:
	- select 3 points randomly floor the floor surface previouly found
	- calculate the parameters a,b,c,d of the equation ax+by+cz = d through SVD (singular value decomposition).
	- compute which points are closer that 5cm to that plane.
	- repete 500 times 
Identifying moving objects (people), by subtacting the pixels in the current image to the background
To identify the movement of a person between consecutive images th distance between its centers is computed, using the Hungarian algorithm.

More details and challenges are explained in the Project_Report (only in Portuguese).
