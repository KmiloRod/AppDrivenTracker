#include "opencvmex.hpp"
#include <cstdlib>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <fstream>
#include <sstream>
#include <map>
#include "fwdfastspatialnss/Imagen.h"

using namespace cv;

// global variable for the input image patch
static Image *image = NULL;

//////////////////////////////////////////////////////////////////////////////
// Check inputs
//////////////////////////////////////////////////////////////////////////////
void checkInputs(int nrhs, const mxArray *prhs[])
{
    if ((nrhs < 1) || (nrhs > 4))
    {
        mexErrMsgTxt("Incorrect number of inputs. Function expects between 1 and 4 inputs.");
    }
}

//////////////////////////////////////////////////////////////////////////////
// Get MEX function inputs
// Copy values from the input parameters object to C++ variables
// Parameters: HOG input parameters by reference, mex object type with parameters
//////////////////////////////////////////////////////////////////////////////
void getParams(Size &winSize, Size &cellSize, Size &blockSize, Size &blockStride, const mxArray* mxParams)
{
    const mxArray* mxfield;
    int *winSizeInt = NULL,
        *cellSizeInt = NULL,
        *blockSizeInt = NULL,
        *blockOverlap = NULL;
    
    //--winSize--
    mxfield = mxGetField(mxParams, 0, "WindowSize");
    if (mxfield)
        winSizeInt = (int*)mxGetData(mxfield);
    winSize = Size(winSizeInt[1], winSizeInt[0]);

    //--cellSize--
    mxfield = mxGetField(mxParams, 0, "CellSize");
    if (mxfield)
        cellSizeInt = (int*)mxGetData(mxfield);
    cellSize = Size(cellSizeInt[1], cellSizeInt[0]);

    //--blockSize--
    mxfield = mxGetField(mxParams, 0, "BlockSize");
    if (mxfield)
        blockSizeInt = (int*)mxGetData(mxfield);
    blockSize = Size(blockSizeInt[1]*cellSizeInt[1], blockSizeInt[0]*cellSizeInt[0]);
    
    //--blockOverlap--
    mxfield = mxGetField(mxParams, 0, "BlockOverlap");
    if (mxfield)
        blockOverlap = (int*)mxGetData(mxfield);
    blockStride = Size(blockOverlap[1]*cellSizeInt[1],
                       blockOverlap[0]*cellSizeInt[0]);
}

//////////////////////////////////////////////////////////////////////////////
// Exit function for freeing persistent memory
//////////////////////////////////////////////////////////////////////////////
void exitFcn() 
{
    if (image != NULL){
        // explicitly call destructor for "placement new"
        image->~Image();
        mxFree(image);
        image = NULL;
    }
}

//////////////////////////////////////////////////////////////////////////////
// Construct object
//////////////////////////////////////////////////////////////////////////////
void constructObject(const mxArray *prhs[])
{  
    Size winSize,
         cellSize,
         blockSize,
         blockStride;

    // second input must be struct with params
    if (mxIsStruct(prhs[1]))
        getParams(winSize, cellSize, blockSize, blockStride, prhs[1]);

    // Allocate memory for Image model
    image = (Image *)mxCalloc(1, sizeof(Image));
    // Make memory allocated by MATLAB software persist after MEX-function completes. 
    // This lets us use the updated Image model for the next frame.
    mexMakeMemoryPersistent(image);
    // Use "placement new" to construct an object on memory that was
    // already allocated using mxCalloc
    new (image) Image(winSize, blockSize, blockStride, cellSize);
    
    // Register a function that gets called when the MEX-function is cleared. 
    // This function is responsible for freeing persistent memory
    mexAtExit(exitFcn);
}

//////////////////////////////////////////////////////////////////////////////
// Check compute inputs
//////////////////////////////////////////////////////////////////////////////
void checkComputeInputs(int nrhs, const mxArray *prhs[])
{    
            
    // Check input image dimensions
    
    if (mxGetNumberOfDimensions(prhs[1])>2)
    {
        mexErrMsgTxt("Incorrect number of dimensions. Second input must be a matrix.");
    }
    
    // Check image data type
    if (!mxIsUint8(prhs[1]))
    {
        mexErrMsgTxt("Image must be UINT8.");
    }
    
    // Check NSS bool input
    if (!mxIsLogical(prhs[2]))
    {
        mexErrMsgTxt("Third input must be logical.");
    }
}

//////////////////////////////////////////////////////////////////////////////
// Get MexArray from Vector of float
//////////////////////////////////////////////////////////////////////////////
mxArray * getMexArray (const vector<float> &v)
{
    // Create mex array of type single (real) with size of  input vector (v)
    size_t num = sizeof(float);
    int vectorLength = v.size();
    mxArray *mx = mxCreateNumericMatrix(1, vectorLength, mxSINGLE_CLASS, mxREAL);
    // Copy each element of input vector (v) to mex array
    memcpy( mxGetData(mx), &v[0], vectorLength*num );
    return mx;
}

//////////////////////////////////////////////////////////////////////////////
// Compute features
// Parameters:
//  nlhs: Number of expected output mxArrays (1: the feature vector)
//  plhs: Array of pointers to feature vector
//  nrhs: Number of input mxArrays (4: 'compute', img, NSS, Cs)
//  prhs: Array of pointers to the input mxArrays.
//////////////////////////////////////////////////////////////////////////////
void computeFeatures(int nlhs, mxArray *plhs[], const mxArray *prhs[])
{
    if (nlhs != 1)
        mexErrMsgTxt("Incorrect number of outputs, must be 1.");
    
    if (image!=NULL)
    {
        cv::Ptr<cv::Mat> imgCV;
        bool attachNSS;
        float Cs;
        // Calculate resized image size (for computing over cropped image)
        cv::Mat resizedImg(image->winWidth, image->winHeight, CV_8UC1);
        Size imSize;
        // output feature vector
        vector<float> descriptorVector;
        
        int HOGfeaturesize, BRISQUEfeaturesize;
        
        // Convert mxArray input into OpenCV types
        imgCV = ocvMxArrayToImage_uint8(prhs[1], true);
        attachNSS = (bool)mxGetScalar(prhs[2]);
        Cs = (float)mxGetScalar(prhs[3]);
        
        // Resize Image to legal size
        cv::resize(*imgCV, resizedImg, cv::Size(image->winWidth, image->winHeight));
        
        // check image data
        image->CheckImage(resizedImg);
        
        // compute MSCN and paired product coefficients
        if( attachNSS)
            image->PrepForFastBrisque();
        
        // extract features
        bool validcheck = image->ComputeScaledFeatures(0,0,image->winWidth,image->winHeight, Cs, descriptorVector, attachNSS); //second valid check
        
        if( !validcheck)
             mexErrMsgTxt("Error while calculating features.");
        
        // Return features in MexArray
        plhs[0] = getMexArray(descriptorVector);
    }
}

//////////////////////////////////////////////////////////////////////////////
// mexFunction
// Parameters:
//  nlhs: Number of expected output mxArrays
//  plhs: Array of pointers to the expected output mxArrays
//  nrhs: Number of input mxArrays
//  prhs: Array of pointers to the input mxArrays.
//////////////////////////////////////////////////////////////////////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{        
    checkInputs(nrhs, prhs); // Check correct number of inputs
    // string with action for contruct obj, compute features, or destroy obj
    const char *str = mxIsChar(prhs[0]) ? mxArrayToString(prhs[0]) : NULL;

    if (str != NULL) 
    {
        if (strcmp (str,"construct") == 0)
            constructObject(prhs);
        else if (strcmp (str,"compute") == 0)
            computeFeatures(nlhs, plhs, prhs);
        else if (strcmp (str,"destroy") == 0)
            exitFcn();

        // Free memory allocated by mxArrayToString
        mxFree((void *)str);
    }
}
