#include "mex.h"
#include "ueye.h"


// the gateway function
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
HIDS hCam = 1;
is_SetExternalTrigger(hCam, IS_SET_TRIGGER_SOFTWARE);

//plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL); 
//double *tempd = mxGetPr(plhs[0]);

//static char str[64];
plhs = is_FreezeVideo(hCam, IS_WAIT);
}
