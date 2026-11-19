#include "mex.h"
#include "ueye.h"


// the gateway function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{

//Open camera with ID 1
HIDS hCam = 1;
INT nRet = is_InitCamera (&hCam, NULL);

 
}
