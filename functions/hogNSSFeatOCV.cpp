//////////////////////////////////////////////////////////////////////////
// Creates C++ MEX-file for extraction of Histogram of Oriented Gradients 
// Features and NSS Features algorithms in OpenCV.
//////////////////////////////////////////////////////////////////////////
#include "opencvmex.hpp"
#include <cstdlib>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <fstream>
#include <sstream>
#include <map>
#include "Imagev2.h"

// On some platforms, the following include is needed for "placement new".
// For more information see: http://en.wikipedia.org/wiki/Placement_syntax
#include <memory> 
//#include "objdetect.hpp"

using namespace cv;

// global variable for the input image/frame
//static Image *image = NULL;

//////////////////////////////////////////////////////////////////////////////
// Check inputs
//////////////////////////////////////////////////////////////////////////////
void checkInputs(int nrhs, const mxArray *prhs[])
{
    if (nrhs != 5)
    {
        mexErrMsgTxt("Incorrect number of inputs. Function expects 5 inputs.");
    }
    
    // Check input image (I), first input
    
    // Check image dimensions
    if (mxGetNumberOfDimensions(prhs[0])>2)
    {
        mexErrMsgTxt("Incorrect number of dimensions. First input must be a matrix.");
    }
    
    // Check image data type
    if (!mxIsUint8(prhs[0]))
    {
        mexErrMsgTxt("Image must be UINT8.");
    }
    
    // Check P (patches), second input
    
    // Check patches dimensions
    if (mxGetNumberOfDimensions(prhs[1])>2)
     {
         mexErrMsgTxt("Incorrect number of dimensions. Second input must be a matrix.");
     }
     
     // Check patches data type
     if (!mxIsInt32(prhs[1]))
     {
         mexErrMsgTxt("P must be INT32.");
     }
    
    // Check NSS, third input
    
    // Check NSS type
    if (!mxIsLogical(prhs[2]))
    {
        mexErrMsgTxt("NSS must be logical.");
    }
    
    // Check Cs (scaling factor), fourth input
    
    // Check Cs type
    if (!mxIsSingle(prhs[3]))
    {
        mexErrMsgTxt("Cs must be single.");
    }
    
    // Check hogParams, fifth input
    
    // Check hogParams type
    if (!mxIsStruct(prhs[4]))
    {
        mexErrMsgTxt("hogParams must be a structure.");
    }
}

//////////////////////////////////////////////////////////////////////////////
// Get MEX function inputs
// Copy values from the input parameters object to C++ variables
// Parameters: HOG input parameters by reference, mex object type with parameters
//////////////////////////////////////////////////////////////////////////////
void getHOGParams(Size &winSize, Size &cellSize, Size &blockSize, Size &blockStride, const mxArray* mxParams)
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
    winSize = Size(winSizeInt[0], winSizeInt[1]);

    //--cellSize--
    mxfield = mxGetField(mxParams, 0, "CellSize");
    if (mxfield)
        cellSizeInt = (int*)mxGetData(mxfield);
    cellSize = Size(cellSizeInt[0], cellSizeInt[1]);

    //--blockSize--
    mxfield = mxGetField(mxParams, 0, "BlockSize");
    if (mxfield)
        blockSizeInt = (int*)mxGetData(mxfield);
    blockSize = Size(blockSizeInt[0]*cellSizeInt[0], blockSizeInt[1]*cellSizeInt[1]);
    
    //--blockOverlap--
    mxfield = mxGetField(mxParams, 0, "BlockOverlap");
    if (mxfield)
        blockOverlap = (int*)mxGetData(mxfield);
    blockStride = Size(blockOverlap[0]*cellSizeInt[0],
                       blockOverlap[1]*cellSizeInt[1]);
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
// mexFunction
// Parameters:
//  nlhs: Number of expected output mxArrays
//  plhs: Array of pointers to the expected output mxArrays
//  nrhs: Number of input mxArrays
//  prhs: Array of pointers to the input mxArrays.
//////////////////////////////////////////////////////////////////////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    checkInputs(nrhs, prhs);
    
    if (nlhs != 2)
    {
        mexErrMsgTxt("Incorrect number of outputs, must be 1.");
    }
    
    // Get Inputs
    
    cv::Ptr<cv::Mat> imgCV = ocvMxArrayToImage_uint8(prhs[0], true); // Image I
    int* P = (int *) mxGetData(prhs[1]); // Patches P
    bool NSS = (bool)mxGetScalar(prhs[2]);
    float Cs = (float)mxGetScalar(prhs[3]);
    
    // Assign HOG parameters    
    Size winSize,
         cellSize,
         blockSize,
         blockStride;
    getHOGParams(winSize, cellSize, blockSize, blockStride, prhs[4]);
    
    // Construct Image object and assign HOG parameters
    Image *image = NULL;
    // Allocate memory for Image model
    image = (Image *)mxCalloc(1, sizeof(Image));
    // Use "placement new" to construct an object on memory that was
    // already allocated using mxCalloc
    new (image) Image(winSize, blockSize, blockStride, cellSize);
    // assign image data to object and validate
    image->CheckImage(*imgCV);
    
    // Estimate number of features
    
    int hogLength = image->GetHOGlength();
    //printf("hogLength: %d \n", hogLength); // must implement
    int nssLength = 0;    
    if (NSS)
    {
        nssLength = image->GetBRISQUElength(); // must implement
        //printf("nssLength: %d \n", nssLength);
        image->PrepForFastBrisque(); // compute mscn coefficients
    }
    int featLength = hogLength + nssLength;
    //printf("featLength: %d \n", featLength);
    
    // Allocate space for featMat
    
    int numberOfPatches = mxGetM(prhs[1]);
    //printf("Number of patches: %d", numberOfPatches);
    // We are trying to use the DescriptorVector Property to store the 
    // features of each patch
    
    vector<float> descriptorMatrix;
    vector<float>::iterator descriptorIterator;
    
    // Compute features for each patch
    int x = 0,
        y = 0,
        nssPatchWidth = P[2*numberOfPatches],
        nssPatchHeight = P[3*numberOfPatches];
    //printf("hogWidth = %d, hogHeight= %d \n nssWidth = %d, nssHeight = %d \n",
            //image->winWidth, image->winHeight, nssPatchWidth, nssPatchHeight);    
    
    bool validCheck = 0;
    
    for(int patch_i = 0; patch_i < numberOfPatches; patch_i++)
    {
        descriptorIterator = descriptorMatrix.begin() + patch_i * featLength;
        vector<float> descriptorVector;
        x = P[patch_i] - 1;
        y = P[patch_i + numberOfPatches] - 1;
        //printf("patch_i = %d \n x = %d, y = %d \n", patch_i, x+1, y+1);
        
        validCheck = image->ComputeScaledFeatures(x, y, nssPatchWidth, nssPatchHeight, Cs, descriptorVector, NSS);
        if(!validCheck)
            mexErrMsgTxt("Error while calculating features."); //better a warning
        descriptorMatrix.insert(descriptorIterator, descriptorVector.begin(), descriptorVector.end());
    }
    //printf("final vector length: %d \n", (int)descriptorMatrix.size());
    // Return features in MexArray
    plhs[0] = getMexArray(descriptorMatrix);
    plhs[1] = mxCreateDoubleScalar((double)featLength);
    
    // free memory
    if (image != NULL){
        // explicitly call destructor for "placement new"
        image->~Image();
        mxFree(image);
        image = NULL;
    }
}
