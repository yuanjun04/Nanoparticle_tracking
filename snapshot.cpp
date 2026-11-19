#define CAPTURE_WIDTH  1280
#define CAPTURE_HEIGHT 1024
#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <ueye.h>
#include "opencv2/core/core.hpp"
//#include <opencv2/opencv.hpp>
#include "cv.h"
#include <highgui.h>
#include <fstream>
#include <mex.h>

using namespace cv;
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

/*
The mexFunction should take 7 arguments, the first is a 1 or 0 denoting the gain boost, and the second is an integer betwenen 0 and 100 which controls the master hardware gain. The third is the exposure in ms. The final four are the area of interest. The first two of them give the top left corner of the aoi, and the other two give the width and height.
*/

//make feedback variable
plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
double *a;
a = mxGetPr(plhs[0]);
a[0] = 0;

//Make debug file
std::ofstream a_file ( "single_capture_dbg.txt" );

a_file<<"Starting capture script \n";

//Set camera handle default
HIDS hCam = 1; //assume camera will always have ID 1

//initialise camera
//int initcamera = is_InitCamera(&hCam, NULL);
a_file<<"successful initialisation \n";

//get aoi details
IS_RECT rectAOI;
rectAOI.s32X = mxGetScalar(prhs[3]);
rectAOI.s32Y = mxGetScalar(prhs[4]);
int newWidth = mxGetScalar(prhs[5]);
if (newWidth == 0){
    rectAOI.s32Width = CAPTURE_WIDTH;
}
else{
    rectAOI.s32Width = newWidth;
}
int newHeight = mxGetScalar(prhs[6]);
if (newHeight == 0){
    rectAOI.s32Height = CAPTURE_HEIGHT;
}
else{
    rectAOI.s32Height = newHeight;
}
int height = rectAOI.s32Height;
int width = rectAOI.s32Width;

a_file<<rectAOI.s32Height;
a_file<<"\n";


//and set the new AOI
INT nAOI = is_AOI(hCam,IS_AOI_IMAGE_SET_AOI,(void*)&rectAOI,sizeof(rectAOI));
a_file<<"AOI successully set \n";

    //Allocate opencv matrix to store the image
Mat frame(height, width,CV_8UC3);

//Initialisation variables
int BITS_PER_PIXEL = 24;
int pWidth = width;
int pHeight = height; 
SENSORINFO sensor_info;
CAMINFO camera_info;

//initialise memort pointers for camera
char* m_pcImageMemory;
int m_lMemoryId;
a_file<<"Successful memory pointer initialisation \n";

// acquire camera camera information
int camerainfo = is_GetCameraInfo (hCam, &camera_info);
a_file<<"Successful camera information population \n";

// acquire sensor information
int sensorinfo = is_GetSensorInfo (hCam, &sensor_info);
a_file<<"Successful sensor information population \n";

//set colour mode
//int colormode = is_SetColorMode(hCam, IS_CM_BGR8_PACKED);
int colormode = is_SetColorMode(hCam, IS_CM_BGRA12_UNPACKED);
a_file<<"Successful colour mode setting \n";

//set capture image size
int pXPos = width;
int pYPos = height;

//point claim sufficient memory from the heap
int rit = is_AllocImageMem (hCam,width,height, 64, &m_pcImageMemory, &m_lMemoryId);
a_file<<"Successful allocmem \n";

//and point the camera to that memory
int rat = is_SetImageMem (hCam, m_pcImageMemory, m_lMemoryId);
a_file<<"Successful setmem \n";

//set colour correction factor
//double strenght_factor = 1.0;
//int colorcorrection = is_SetColorCorrection(hCam, IS_CCOR_ENABLE, &strenght_factor);

//set white-balance correction
//double pval = 1;
//int whiteb = is_SetAutoParameter(hCam, IS_SET_ENABLE_AUTO_WHITEBALANCE, &pval, 0);

//set gain parameter
//double gval = 10000;
//int gains = is_SetAutoParameter(hCam, IS_SET_ENABLE_AUTO_GAIN, &gval, 0);

//set gainboost
int GainBoostSet = mxGetScalar(prhs[0]);
if (GainBoostSet == 1)
{
	int gains = is_SetGainBoost(hCam,IS_SET_GAINBOOST_ON);
}
if (GainBoostSet == 0)
{
	int gains = is_SetGainBoost(hCam,IS_SET_GAINBOOST_OFF);
}
if (GainBoostSet != 0 && GainBoostSet != 1)
{
	a_file<<"Invalid gain boost setting \n";
	return;
}

//set gain
int gainset = mxGetScalar(prhs[1]);
if (gainset < 0 or gainset > 100)
{
	a_file<<"The specified gain setting was out of range";
	return;
}
int gains2 = is_SetHardwareGain(hCam,IS_IGNORE_PARAMETER,gainset,gainset,gainset);

//get range of available exposures
double exposureRange[3];
double exposureMin, exposureMax, exposureInc;
INT nRet = is_Exposure(hCam, IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE,(void*) exposureRange, sizeof(exposureRange));
exposureMin = exposureRange[0];
exposureMax = exposureRange[1];
exposureInc = exposureRange[2];

a_file<<"successfully retrieved valid exposures \n";

//get exposure from matlab
double exposureMat = mxGetScalar(prhs[2]);

//check it's a legit value
if ((exposureMat >= exposureMin) and (exposureMat <= exposureMax)){
	INT nRet = is_Exposure(hCam, IS_EXPOSURE_CMD_SET_EXPOSURE,(void*) &exposureMat, sizeof(exposureMat));
	if (nRet != IS_SUCCESS){
		a_file<<"Could not set exposure with camera \n";
		return;
	}
	else{
		a_file<<"successfully set new exposure \n";
	}
}
else{
	a_file<<"Your settings weren't correct! \n";
	if (exposureMat < exposureMin){
		exposureMat = exposureMin;
		INT nRet = is_Exposure(hCam, IS_EXPOSURE_CMD_SET_EXPOSURE,(void*) &exposureMat, sizeof(exposureMat));
	}
	if (exposureMat > exposureMax){
		exposureMat = exposureMax;
		INT nRet = is_Exposure(hCam, IS_EXPOSURE_CMD_SET_EXPOSURE,(void*) &exposureMat, sizeof(exposureMat));
	}
}

//set capture pointers
int dummy;
char *pMem, *pLast;

//capture frame
int sho = is_FreezeVideo(hCam, IS_WAIT);
a_file<<"Successful frame \n";

//do some opencv wizardry to wrap raw data into image header
IplImage* tmpImg = cvCreateImage(cvSize(width,height), IPL_DEPTH_16U,3); 
tmpImg->imageData = m_pcImageMemory;
frame = cv::cvarrToMat(tmpImg);

//display it
//imshow("Image",frame);
//waitKey(0);

//write it to file
imwrite("image.tif",frame);


//std::ofstream a_file ("output2");
//a_file<<frame;

//release memory to stop leak
int fMem = is_FreeImageMem (hCam, m_pcImageMemory, m_lMemoryId);

//Exit camera so something else can use it
//int en = is_ExitCamera(hCam);
a_file<<"successful close";

//and finally make a value to return to matlab to tell it things went well
a[0] = 1;

return;
}
