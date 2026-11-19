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
//#include <mex.h>
#include <opencv2/highgui/highgui.hpp>
#include <string.h>
#include <string>
//#include <gtk/gtk.h>
//#include <MxArray.hpp>


using namespace cv;
int main(){

/*
This the the standalone version of the mexFunction to capture video from the uEye USB3 camera. This allows the memory leaks to be mitigated by closing the program after running, something that isn't possible with mexFunctions called through matlab. This should be preferably called using '!./' syntax from matlab. Each variable to be read in should be saved in seperate text files, with names 'external_capture_VARIABLE'.

The function should take several arguments, the first is a 1 or 0 denoting the gain boost, and the second is an integer betwenen 0 and 100 which controls the master hardware gain. The third is the framerate. The fourth is the number of frames to be captured. The Fifth is the exposure. The sixth and seventh are the x and y positions of the area of interest (set both to zero for whole-field capture), and the eighth and ninth are the size for the AOI. If set to 0, the whole fov will be imaged.

The LHS is a single value, which reflects the actual framerate set by the camera (not necessarily exactly the same as the one requested). If a framerate value is too high for the selected area of interest, then the framerate will be set to the maximum possible. No errors will be generated. If more immediate feedback is needed, it is left as an exercise for the user to write some valcue-checking code.
 
The video captured by this code as it is is stored in a stack of .tiff images in the folder from which it is run. these are named image0.tif..image(n-1).tif for a stack of n images. It is trivial to stitch these together into an .avi video container in matlab. In order to do this, the framerate is important.


Any queries about this code should be directed at Sam Thompson st643@york.ac.uk in the first instance.

***************************

The pixel clock is always set to the highest possible value to ensure the highest framerates are available - the USB3 interface is sufficiently fast as to allow this. This code will not work with a camera connected using a USB2 or slower interface.

*/

//Make debug file
std::ofstream a_file ( "video_capture_dbg.txt" );

//Set camera handle default
HIDS hCam = 1; //assume camera will always have ID 1

//initialise camera
int initcamera = is_InitCamera(&hCam, NULL);
initcamera = is_InitCamera(&hCam, NULL);
//initcamera = is_InitCamera(&hCam, NULL);
a_file<<"successful initialisation \n";

//initialise feedback variable
//plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
//double *a;
//a = mxGetPr(plhs[0]);
//a[0]=-1;

int nRet;

/*
//set trigger mode
if (is_SetExternalTrigger(hCam, IS_GET_EXTERNALTRIGGER) != IS_SET_TRIGGER_SOFTWARE)
{
nRet = is_SetExternalTrigger(hCam, IS_SET_TRIGGER_SOFTWARE);
if (nRet != IS_SUCCESS)
{
a_file<<"Failed to activate software trigger ";
a_file<< nRet;
a_file<< " \n";
//feedback[0] = 3;
return;
}
}
*/

//Get pixel clock value range
UINT nRange[3];
ZeroMemory(nRange,sizeof(nRange));
nRet = is_PixelClock(hCam,IS_PIXELCLOCK_CMD_GET_RANGE, (void*)nRange, sizeof(nRange));
//if (nRet == IS_SUCCESS)
//{
UINT nMin = nRange[0];
UINT nMax = nRange[1];
UINT nInc = nRange[2];
//}

//nMax is the salient result, this is then fed into the next command to crank the pixel clock as high as possible.
nRet = is_PixelClock(hCam, IS_PIXELCLOCK_CMD_SET, (void*)&nMax, sizeof(nMax));
if (nRet != IS_SUCCESS){
	a_file<<"Pixel clock setting failed ";
	a_file<<nRet;
//feedback[0] = 2;
	//return 0;
}


//get number of frames to be captured from matlab
int frame_count;
std::ifstream frame_count_file("external_capture_frame_count");
frame_count_file>>frame_count;
//frame_count = mxGetScalar(prhs[3]);


//Initialisation variables
int BITS_PER_PIXEL = 24;
int pWidth = CAPTURE_WIDTH;
int pHeight = CAPTURE_HEIGHT; 
SENSORINFO sensor_info;
CAMINFO camera_info;

//initialise memory pointers for camera
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
int colormode = is_SetColorMode(hCam, IS_CM_BGR8_PACKED);
//int colormode = is_SetColorMode(hCam, IS_CM_BGRA12_UNPACKED);
a_file<<"Successful colour mode setting \n";

//set capture image size
int pXPos = (sensor_info.nMaxWidth);
int pYPos = (sensor_info.nMaxHeight);

//get AOI details
IS_RECT rectAOI;
//rectAOI.s32X = mxGetScalar(prhs[5]);
std::ifstream xdim ("external_capture_xdim");
xdim>>rectAOI.s32X;
//rectAOI.s32Y = mxGetScalar(prhs[6]);
std::ifstream ydim ("external_capture_ydim");
ydim>>rectAOI.s32Y;
//int newWidth = mxGetScalar(prhs[7]);
std::ifstream AOIWidth("external_capture_width");
int newWidth;
AOIWidth>>newWidth;
if (newWidth == 0){
    rectAOI.s32Width = pXPos;
}
else{
    rectAOI.s32Width = newWidth;
}
//int newHeight = mxGetScalar(prhs[8]);
int newHeight;
std::ifstream AOIHeight("external_capture_height");
AOIHeight>>newHeight;
if (newHeight == 0){
    rectAOI.s32Height = pYPos;
}
else{
    rectAOI.s32Height = newHeight;
}

//set simple variables to describe the height and width of the video
int height = rectAOI.s32Height;
int width = rectAOI.s32Width;

//and set the new AOI
INT nAOI = is_AOI(hCam,IS_AOI_IMAGE_SET_AOI,(void*)&rectAOI,sizeof(rectAOI));
a_file<<"AOI successully set \n";

//Allocate opencv matrix to store the images during export
Mat frame(height,width,CV_8UC3);

//point claim sufficient memory from the heap
int rit = is_AllocImageMem (hCam,width,height, 24, &m_pcImageMemory, &m_lMemoryId);
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
//int GainBoostSet = mxGetScalar(prhs[0]);
int GainBoostSet;
std::ifstream gainboost_file ("external_capture_gainboost");
gainboost_file>>GainBoostSet;
if (GainBoostSet == 1){
	int gains = is_SetGainBoost(hCam,IS_SET_GAINBOOST_ON);
}

if (GainBoostSet == 0){
	int gains = is_SetGainBoost(hCam,IS_SET_GAINBOOST_OFF);
}

if (GainBoostSet != 0 && GainBoostSet != 1){
	a_file<<"Invalid gain boost setting \n";
	return 0;
}

//set gain
//int gainset = mxGetScalar(prhs[1]);
int gainset;
std::ifstream gain_file ("external_capture_gain");
gain_file>>gainset;
if (gainset < 0 or gainset > 100){
	a_file<<"The specified gain setting was out of range";
	return 0;
}

int gains2 = is_SetHardwareGain(hCam,IS_IGNORE_PARAMETER,gainset,gainset,gainset);

//get range of available exposures
double exposureRange[3];
double exposureMin, exposureMax, exposureInc;
nRet = is_Exposure(hCam, IS_EXPOSURE_CMD_GET_EXPOSURE_RANGE,(void*) exposureRange, sizeof(exposureRange));
exposureMin = exposureRange[0];
exposureMax = exposureRange[1];
exposureInc = exposureRange[2];

a_file<<"successfully retrieved valid exposures \n";

a_file<<exposureMin;
a_file<<"\n";
a_file<<exposureMax;
a_file<<"\n";
a_file<<exposureInc;
a_file<<"\n";

//get exposure from matlab
//double exposureMat = mxGetScalar(prhs[4]);
double exposureMat;
std::ifstream exposure_file ("external_capture_exposure");
exposure_file>>exposureMat;

//check it's a legit value
if ((exposureMat >= exposureMin) and (exposureMat <= exposureMax)){
	nRet = is_Exposure(hCam, IS_EXPOSURE_CMD_SET_EXPOSURE,(void*) &exposureMat, sizeof(exposureMat));
	if (nRet != IS_SUCCESS){
		a_file<<"Could not set exposure with camera \n";
		return 0;
	}

	else{
		a_file<<"successfully set new exposure \n";
	}

}
else{
	a_file<<"Your exposure settings weren't correct! \n";
	//return 0;
}

//get framerate from matlab
//int NewFPS = mxGetScalar(prhs[2]);
double NewFPS;
std::ifstream fps_file ("external_capture_fps");
fps_file>>NewFPS;
double ActualFPS;

//set the frame rate
INT frameset = is_SetFrameRate(hCam, NewFPS, &ActualFPS);
a_file<<"Actual FPS = ";
a_file<<ActualFPS;
a_file<<"\n";
if (frameset == IS_INVALID_PARAMETER){
	a_file<<"Framerate couldn't be set.";
	//feedback[0] = 1;
	return 0;
}


//set capture pointers
int dummy;
char *pMem, *pLast;

// create image buffer
char *pFrameBuffer[frame_count];
INT pFrame[frame_count];
is_ClearSequence (hCam);

//allocate memory

for (int i = 0; i < frame_count;i++){
	int nAlloc = is_AllocImageMem (hCam, width,height, 24, &pFrameBuffer[i], &pFrame[i]);
	int nSeq = is_AddToSequence(hCam, pFrameBuffer[i], pFrame[i]);
	pFrame[i] = i + 1;
}

//Capture video...
int nCap = is_CaptureVideo(hCam, IS_WAIT);

//initialise image queue
int nInit = is_InitImageQueue(hCam, 0);
char *pBuffer = NULL;
INT nMemID = 0;

/*
//set up progress bar for capture
int argc = 1;
char* argv[1];
gtk_init(&argc,NULL);
GtkWidget *window,*progress;
window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
g_signal_connect(window,"delete_event",G_CALLBACK(gtk_main_quit),NULL);
progress = gtk_progress_bar_new();
gtk_progress_bar_set_fraction(GTK_PROGRESS_BAR(progress),0);
gtk_progress_bar_set_text(GTK_PROGRESS_BAR(progress),"Capturing video 0% complete");
gtk_container_add(GTK_CONTAINER(window),progress);
gtk_widget_show_all(window);
//gtk_main();
*/

//get images from camera and write to queue addresses
int k = 0;
while (k < frame_count){
	nRet = is_WaitForNextImage(hCam, 1000, &pBuffer, &nMemID);
	//gtk_progress_bar_set_fraction(GTK_PROGRESS_BAR(progress),(k/frame_count));
	//int nFrac = (k/frame_count)*100;
	//std::ostringstream progs;
	//progs << nFrac;
	//std::string disfrac = progs.str();
	//std::string caps = "Capturing video ";
	//std::string ends = "% complete";
	//std::string progstring = caps + disfrac + ends;
	//gtk_progress_bar_set_text(GTK_PROGRESS_BAR(progress),progstring);
	k++;
}
//a_file<<pFrameBuffer;

//write all images to disk
k=0;
while (k < frame_count){
	IplImage* tmpImg = cvCreateImage(cvSize(width,height), IPL_DEPTH_8U,3);
	tmpImg->imageData = pFrameBuffer[k];
	frame = cv::cvarrToMat(tmpImg);
//convert k to a string so images may be labelled
	std::ostringstream strs;
	strs << k;
	std::string str = strs.str();//str is the name of the new string
//append this to a filestub
	std::string stub = "image";
	std::string extension = ".tif";
	std::string filename = stub + str + extension;
//write actual file
	imwrite(filename,frame);
	k++;
}

is_ClearSequence (hCam);

//release memory
is_UnlockSeqBuf(hCam, nMemID, pBuffer);
is_ClearSequence (hCam);
int nSeq2 = is_ClearSequence(hCam);
k=0;
/*while (k < frame_count){
	int fMem = is_FreeImageMem(hCam, pFrameBuffer[k], pFrame[k]);
	k++;
}
*/
//delete[] pFrameBuffer;

//int fMem2 = is_FreeImageMem (hCam, (char*) &pFrameBuffer, *pFrame);

//Exit camera so something else can use it
//int en = is_ExitCamera(hCam);
a_file<<"successful close";

//and finally make a value to return to matlab to tell it things went well
//a[0] = ActualFPS;

std::ofstream framerate("framerate");
framerate<<framerate;

return 0;
}


