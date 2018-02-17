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
// const int FACEWIDTH = OBJECTWIDTH;
// const int FACEHEIGHT = OBJECTHEIGHT;


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
    Mat& GetImage(){return img;}
    int GetHOGlength()
    {
        int nCells = hog.blockSize.width / hog.cellSize.width
                     * hog.blockSize.height / hog.cellSize.height;
        int nBlocksX = winWidth - hog.blockSize.width + hog.blockStride.width;
        int nBlocksY = winHeight - hog.blockSize.height + hog.blockStride.height;
        nBlocksX = nBlocksX / hog.blockStride.width;
        nBlocksY = nBlocksY / hog.blockStride.height;
        HOGlength = nCells * hog.nbins * nBlocksX * nBlocksY;
        
        return HOGlength;
    }
    int GetBRISQUElength()
    {
        //int BRISQUElength = 36; // 18*numScales
        //return BRISQUElength;
        return 36;
    }
    vector<float>& GetFeatureVector(){return DescriptorVector;}

    //manipulate functions
    bool ComputeFeatures(int x, int y, int w, int h, vector<float>& descriptorVector, bool AttachBrisque=1){
		ComputeHOG(x,y,w,h,descriptorVector);
		if(AttachBrisque){
			if(verbose) printf("BRISQUE.. \n");
			if(!ReadyForFastBrisque) {throw "Image not ready for Fast Brisque";}
			if(!FastBrisque(x, y, w, h, descriptorVector)) return false;
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
					//descriptorVector[i]=(descriptorVector[i]-minVector[i])/rangeVector[i];
                    descriptorVector[i]=(descriptorVector[i])/scaleBrisque; //Cs
			}
		}
		return valid;
	}

    void ComputeHOG(int x, int y, int w, int h, vector<float>& descriptorVector){
        // Resize image patch to legal size
        Mat imagePatch = img(Rect(x,y,w,h));
        Mat resizedImagePatch(hog.winSize, CV_8UC1);
        cv::resize(imagePatch, resizedImagePatch, hog.winSize);
        hog.compute(resizedImagePatch, descriptorVector, Size(), Size());
    	//hog.compute(img(Rect(x, y, w, h)), descriptorVector, Size(), Size());
    	HOGlength=descriptorVector.size();
    }
    void PrepForFastBrisque(){
    	img.convertTo(img, CV_8U);
    	CreateMscnMaps();
    	ComputePairedProducts();
    	CreateIntegralImages();
    	ReadyForFastBrisque=true;
    }
    bool CheckValid(int x, int y, int w, int h){
    	cv::Scalar check = cv::sum(img(Rect(x,y,w,h)));
		if(!(check[0])) return 0;
    	for (int i=x; i<x+w-10; i++)
    		for (int j=y; j<y+h-10; j++){
    			cv::Scalar check = cv::sum(img(Rect(i,j, 10, 10)));
				if(!(check[0])) return 0;
   		}

		return 1;
	};
    bool FastBrisque(int x, int y, int w, int h, vector<float>& descriptorVector);
};
#endif
