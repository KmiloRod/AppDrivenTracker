#ifndef IMAGE_H
#define IMAGE_H

#include <math.h>
#include "opencvmex.hpp"
//#include <cv.h>
//#include <cxcore.h>
//#include <highgui.h>
//#include <cvaux.h>
//#include "FaceDetectConfig.h"

using namespace cv;
using namespace std;

#define M_PI           3.14159265358979323846
#define ELEM(type,start,step,size,xpos,ypos) (*((type*)(start+step*(ypos)+(xpos)*size)))

const bool verbose = 0;
//const int FACEWIDTH = 10;
//const int FACEHEIGHT = 10;


class Image
{
    Mat img;
    vector<float> DescriptorVector;
    HOGDescriptor hog;
    Mat mscn[2], pairedproducts[2][4], negelem[10], numneg[10], poselem[10], numpos[10], leftsqthresh[10], leftsqsum[10], rightsqthresh[10], rightsqsum[10], absmscn[10], abssum[10];
    int HOGlength, BRISQUElength;
    bool ReadyForFastBrisque;

    double gamma(double x);
    void CreateMscnMaps();
    void ComputePairedProducts();
    void CreateIntegralImages();
    double windowsum(Mat&, int x, int y, int w, int h);

	public:
	int winWidth, winHeight;
    Image(Size winSize, Size blockSize, Size blockStride, Size cellSize)
    {
        hog = HOGDescriptor(
                winSize,	//winSize
                blockSize,	//blocksize
                blockStride,	//blockStride,
                cellSize,	//cellSize,
                9,	 //nbins,
                1,	 //derivAper,
                8,	 //winSigma,
                0,	 //histogramNormType,
                0.2,	 //L2HysThresh,
                0	 //gammal correction,
					//nlevels=64
                );
        ReadyForFastBrisque=0;
	winWidth = winSize.width;
	winHeight = winSize.height;
    }
    //input functions
    void CheckImage(Mat imagen){img = imagen; ReadyForFastBrisque=0; if(!img.data) throw "Error: Could not read image";}

    //output functions
    int GetHOGlength(){return HOGlength;}
    int GetBRISQUElength(){return BRISQUElength;}
    vector<float>& GetFeatureVector(){return DescriptorVector;}

    //manipulate functions
    bool ComputeFeatures(int x, int y, int w, int h, vector<float>& descriptorVector, bool AttachBrisque=1){
		ComputeHOG(w,h,descriptorVector);
		if(AttachBrisque){ //attach nss
			if(verbose) printf("BRISQUE.. \n");
			if(!ReadyForFastBrisque) {throw "Image not ready for Fast Brisque";}
			if(!FastBrisque(0, 0, w, h, descriptorVector)) return false;
		}
		return true;
	}
    bool ComputeScaledFeatures(int x, int y, int w, int h, float scaleBrisque, vector<float>& descriptorVector, bool AttachBrisque=1){
		bool valid = ComputeFeatures(x,y,w,h, descriptorVector, AttachBrisque);
		if(valid)
		{			
			for(int i=0;i<descriptorVector.size(); i++)
			{	
				if (i>=HOGlength)
					descriptorVector[i]=(descriptorVector[i])/scaleBrisque; //Cs
			}
		}
		return valid;
	}

    void ComputeHOG(int w, int h, vector<float>& descriptorVector){
    	hog.compute(img, descriptorVector, Size(), Size());
    	HOGlength=descriptorVector.size();
    }
    void PrepForFastBrisque(){
    	img.convertTo(img, CV_8U);
    	CreateMscnMaps();
    	ComputePairedProducts();
    	CreateIntegralImages();
    	ReadyForFastBrisque=true;
    }
    bool FastBrisque(int x, int y, int w, int h, vector<float>& descriptorVector);
};
#endif

