#include "Imagev2.h"
using std::isfinite;

//extern bool verbose;

// BRISQUE COMPUTATION  ************************************************
// #ifndef isfinite
// bool isfinite(float x){
// 	return ((x==x)&&(x!=x+1));
// }
// #endif

void Image::CreateMscnMaps()
{
	Mat orig_bw;
	img.convertTo(orig_bw, CV_32F); // must be CV_32F or CV_64F for functions below
    divide(orig_bw, Scalar(255.0), orig_bw); //normalize image-> do I always have to do this?
	//cvtColor(orig_bw, orig_bw, CV_BGR2GRAY);

    
        
	for (int itr_scale = 1; itr_scale<=2; itr_scale++)
	{
		Mat imdist_scaled;
		resize(orig_bw, imdist_scaled, Size(), pow(0.5,itr_scale-1), pow(0.5, itr_scale-1));
		if(verbose) printf("Resized image \n");

		Mat mu;
		GaussianBlur(imdist_scaled, mu, Size(7,7), 1.16666 );
		if(verbose) printf("Mean computed\n");
                        
		Mat mu_sq;
		multiply(mu, mu, mu_sq);
		//compute sigma
                        
		Mat sigma;
		multiply(imdist_scaled, imdist_scaled, sigma);
		GaussianBlur(sigma, sigma, Size(7,7), 1.16666 );
		if(verbose) printf("Mean of squared image computed\n");
		absdiff(sigma, mu_sq, sigma);
		if(verbose) printf("Deviation from squared mean computed\n");
		cv::sqrt(sigma, sigma);
                         
		if(verbose) printf("Adding epsilon\n");
		add(sigma, Scalar(1.0/255), sigma);
		subtract(imdist_scaled, mu, mscn[itr_scale-1]);
                                    
		divide(mscn[itr_scale-1], sigma, mscn[itr_scale-1]);
		if(verbose) printf("MSCN computed\n");
                
		mu.release();
		mu_sq.release();
		sigma.release();
		imdist_scaled.release();
	}
	orig_bw.release();
}
void Image::CreateIntegralImages() //problem with cv::integral
{
	int count=-1;
	for (int itr_scale = 0; itr_scale<2; itr_scale++)
	{	
		count++;		
		if(verbose) printf("scale %d.. \n", itr_scale);
                
		if(verbose) printf("Running sum computed.. \n");
		cv::threshold(mscn[itr_scale], poselem[count], 0 , 1, THRESH_BINARY); //only positive elements
		if(verbose) printf("Positive elements identified.. \n");
		cv::threshold(mscn[itr_scale], negelem[count], 0 , 1, THRESH_BINARY_INV); //only positive elements
		if(verbose) printf("Negative elements identified.. \n");
		cv::integral(poselem[count], numpos[count]); //integral image of positive elements
		if(verbose) printf("Positive elements counted.. \n");
		cv::integral(negelem[count], numneg[count]); //integral image of negative elements
		if(verbose) printf("Negative elements counted.. \n");

		cv::threshold(mscn[itr_scale], leftsqthresh[count], 0, 1, THRESH_TOZERO_INV);
		multiply(leftsqthresh[count], leftsqthresh[count], leftsqthresh[count]);		
		cv::integral(leftsqthresh[count], leftsqsum[count]);
		if(verbose) printf("Negative sqsum computed.. \n");
                
		cv::threshold(mscn[itr_scale], rightsqthresh[count], 0, 1, THRESH_TOZERO);
		multiply(rightsqthresh[count], rightsqthresh[count], rightsqthresh[count]);		
		cv::integral(rightsqthresh[count], rightsqsum[count]);
		if(verbose) printf("Positive sqsum computed.. \n");
                
		absmscn[count]=abs(mscn[itr_scale]);
		cv::integral(absmscn[count], abssum[count]);
		if(verbose) printf("Running absolute sum computed.. \n");
                		
		for(int itr_shift = 0; itr_shift<4; itr_shift++)
		{
			count++;

			if(verbose) printf("Running sum computed.. \n");
			cv::threshold(pairedproducts[itr_scale][itr_shift], poselem[count], 0 , 1, CV_THRESH_BINARY); //only positive elements
			if(verbose) printf("Positive elements identified.. \n");
			cv::threshold(pairedproducts[itr_scale][itr_shift], negelem[count], 0 , 1, CV_THRESH_BINARY_INV); //only positive elements
			if(verbose) printf("Negative elements identified.. \n");
			cv::integral(poselem[count], numpos[count]); //integral image of positive elements
			if(verbose) printf("Positive elements counted.. \n");
			cv::integral(negelem[count], numneg[count]); //integral image of positive elements
			if(verbose) printf("Negative elements counted.. \n");

			cv::threshold(pairedproducts[itr_scale][itr_shift], leftsqthresh[count], 0, 1, CV_THRESH_TOZERO_INV);
			multiply(leftsqthresh[count], leftsqthresh[count], leftsqthresh[count]);
			cv::integral(leftsqthresh[count], leftsqsum[count]);
			if(verbose) printf("Negative sqsum computed.. \n");

			cv::threshold(pairedproducts[itr_scale][itr_shift], rightsqthresh[count], 0, 1, CV_THRESH_TOZERO);
			multiply(rightsqthresh[count], rightsqthresh[count], rightsqthresh[count]);
			cv::integral(rightsqthresh[count], rightsqsum[count]);
			if(verbose) printf("Positive sqsum computed.. \n");
		
			absmscn[count]=abs(pairedproducts[itr_scale][itr_shift]);
			cv::integral(absmscn[count], abssum[count]);
			if(verbose) printf("Running absolute sum computed.. \n");
		}
	}
}

bool Image::FastBrisque(int x, int y, int w, int h, vector<float>& descriptorVector)
{
    bool valid=1;
    int area = w*h;
    int count=-1;
    double countpos, countneg;
    float lsqsum, rsqsum, leftstd, rightstd, leftstdsq, rightstdsq, gammahat, rhat, rhatnorm, prevgamma, prevdiff, r_gam, diff, term1, term2, term3, prevterm1, prevterm2, prevterm3;
    float lastElem;
    for(int itr_scale=1; itr_scale<=2; itr_scale++)
    {
        if(verbose) printf("itr_scale %d \n", itr_scale);
        count++;
        countpos = windowsum(numpos[count], x+1, y+1, w, h); 
        countneg = windowsum(numneg[count], x+1, y+1, w, h); 
        if(verbose) 
            printf("countpos %f \n", countpos);
        if(verbose) 
            printf("countneg %f \n", countneg);
        
// 		if(!countpos||!countneg)
// 		{
// 			printf("invalid image patch in count %d\n",count);
// 			valid = 0;
// 			return valid;
// 		}
// 		else
// 			valid = 1;


        lsqsum = windowsum(leftsqsum[count], x+1, y+1, w, h);
        leftstd = lsqsum/countneg; 
        if(verbose) 
            printf("leftstd %f \n", leftstd);
        
        rsqsum = windowsum(rightsqsum[count], x+1, y+1, w, h);
        rightstd = rsqsum/countpos; 
        if(verbose) 
            printf("rightstd %f \n", rightstd);
        
        //float temp = 0.5*(leftstd+rightstd);
        leftstdsq = leftstd;
        rightstdsq = rightstd;
        leftstd = sqrt(leftstd);
        rightstd = sqrt(rightstd);
        gammahat = leftstd/rightstd;
        rhat = (pow(windowsum(abssum[count], x+1, y+1, w, h), 2)/(lsqsum+rsqsum))/area;
        rhatnorm = (rhat*(pow(gammahat,3) +1)*(gammahat+1))/pow((pow(gammahat,2) +1),2);
        
        prevgamma = 0;
		prevdiff = 1e10;
		for (float gam=0.2; gam<10; gam+=0.005) //possible to improve sampling to quicken the code
		{
			term1 = gamma(1/gam);
			term2 = gamma(2/gam);
			term3 = gamma(3/gam);

			r_gam = pow(term2, 2)/(term1*term3);
			diff = abs(r_gam-rhatnorm);
			if(diff> prevdiff) break;
			prevdiff = diff;
			prevgamma = gam;
			prevterm1 = term1;
			prevterm2 = term2;
			prevterm3 = term3;
        }
		if(verbose)
			printf("gamma %f\n", prevgamma);
        
        if(isnan(prevgamma)||!isfinite(prevgamma))
        {
            prevgamma = 0;
        }        
		descriptorVector.push_back(prevgamma);
        
        
        lastElem = 0.5*(rightstdsq+leftstdsq);
        if(isnan(lastElem)||!isfinite(lastElem))
		{
			lastElem = 0;
		}
        descriptorVector.push_back(lastElem);
        

        for(int itr_shift=1; itr_shift<=4; itr_shift++)
        {
            if(verbose) printf("Shift %d \n", itr_shift);
            count++;
            countpos = windowsum(numpos[count], x+1, y+1, w, h);
            countneg = windowsum(numneg[count], x+1, y+1, w, h); 
//     		if(!countpos||!countneg)
//     		{
//     			printf("invalid image patch in count %d\n",count);
//     			valid = 0;
//     			return valid;
//     		}
//     		else
//     			valid = 1;

            if(verbose) printf("countpos %f \n", countpos);
            if(verbose) printf("countneg %f \n", countneg);

            lsqsum = windowsum(leftsqsum[count], x+1, y+1, w, h);
            leftstd = lsqsum/countneg; 
            if(verbose) printf("leftstd %f\n", leftstd);

            rsqsum = windowsum(rightsqsum[count], x+1, y+1, w, h);
            rightstd = rsqsum/countpos;
            if(verbose) printf("rightstd %f\n", rightstd);

            leftstdsq = leftstd;
            rightstdsq = rightstd;
            leftstd = sqrt(leftstd);
            rightstd = sqrt(rightstd);
               
            gammahat = leftstd/rightstd;
            rhat = (pow(windowsum(abssum[count], x+1, y+1, w, h), 2)/(lsqsum+rsqsum))/area;
            rhatnorm = (rhat*(pow(gammahat,3) +1)*(gammahat+1))/pow((pow(gammahat,2) +1),2);

            prevgamma = 0;
            prevdiff = 1e10;	
            for (float gam=0.2; gam<10; gam+=0.005) //possible to improve sampling to quicken the code
            {
                term1 = gamma(1/gam);
                term2 = gamma(2/gam);
                term3 = gamma(3/gam);
                
                r_gam = pow(term2, 2)/(term1*term3);
                diff = abs(r_gam-rhatnorm);
                if(diff> prevdiff) break;
                prevdiff = diff;
                prevgamma = gam;
                prevterm1 = term1;
                prevterm2 = term2;
                prevterm3 = term3;
            }
            if(verbose) printf("gamma %f\n", prevgamma);            
            if(isnan(prevgamma)||!isfinite(prevgamma))
            {
                prevgamma = 0;
            }
            descriptorVector.push_back(prevgamma);

            
            lastElem = (rightstd-leftstd)*prevterm2/prevterm1*sqrt(prevterm1/prevterm3);
            if(isnan(lastElem)||!isfinite(lastElem))
			{
                lastElem = 0;
			}
            descriptorVector.push_back(lastElem);
            
            if(isnan(leftstdsq)||!isfinite(leftstdsq))
            {
                leftstdsq = 0;
            }
            descriptorVector.push_back(leftstdsq);
            
            if(isnan(rightstdsq)||!isfinite(rightstdsq))
            {
                rightstdsq = 0;
            }
            descriptorVector.push_back(rightstdsq);
        }
        area = area/4; x/=2; y/=2; w/=2; h/=2;                
    }
    BRISQUElength = descriptorVector.size()-HOGlength;     
    return valid;
}
void Image::ComputePairedProducts()
{
    int shifts[4][2]={{0,1},{1,0},{1,1},{-1,1}};		
    for (int scale=0; scale<2; scale++)
        for (int shift=0; shift<4; shift++)
        {
            int* shiftopt = shifts[shift];
			int rows = mscn[scale].rows;
			int cols = mscn[scale].cols;
			uchar* mscndata = mscn[scale].data;
			int stepsize = mscn[scale].step;
			int elemsize = mscn[scale].elemSize();
			pairedproducts[scale][shift] = Mat(rows, cols, CV_32FC1);
			uchar* finaldata = pairedproducts[scale][shift].data;

			for(int i= 0; i<rows; i++)
			{
				uchar* mscnrowptr = mscndata+stepsize*(i);
				int inew = i+shiftopt[0];
				uchar* mscnnewrowptr = mscndata+stepsize*inew;
				uchar* finalrowptr = finaldata+stepsize*(i);
				for(int j=0; j<cols;j++)
				{
					int jnew = j+shiftopt[1];
					if(inew>=0 && inew<rows && jnew>=0 && jnew<cols)
						*((float*)(finalrowptr + j*elemsize)) = (*((float*)(mscnrowptr + j*elemsize)))*(*((float*)(mscnnewrowptr + jnew*elemsize)));
					else
						*((float*)(finalrowptr + j*elemsize)) =0;
				}
			}
        }
}
double Image::windowsum(Mat& integral_im, int x, int y, int w, int h){
    uchar* data = integral_im.data;
    int stepsize = integral_im.step;
    int elemsize = integral_im.elemSize();
    return ELEM(double, data , stepsize, elemsize, (x+w-1),(y+h-1))-ELEM(double, data , stepsize, elemsize, x,(y+h-1))-(ELEM(double, data , stepsize, elemsize, (x+w-1),y)-ELEM(double, data , stepsize, elemsize, x,y)) ;
}

double Image::gamma(double x){
    double ga=tgamma(x);
	/*int i,k,m;
    double ga,gr,r,z;

    static double g[] = {
        1.0,
        0.5772156649015329,
       -0.6558780715202538,
       -0.420026350340952e-1,
        0.1665386113822915,
       -0.421977345555443e-1,
       -0.9621971527877e-2,
        0.7218943246663e-2,
       -0.11651675918591e-2,
       -0.2152416741149e-3,
        0.1280502823882e-3,
       -0.201348547807e-4,
       -0.12504934821e-5,
        0.1133027232e-5,
       -0.2056338417e-6,
        0.6116095e-8,
        0.50020075e-8,
       -0.11812746e-8,
        0.1043427e-9,
        0.77823e-11,
       -0.36968e-11,
        0.51e-12,
       -0.206e-13,
       -0.54e-14,
        0.14e-14};

    if (x > 171.0) return 1e308;    // This value is an overflow flag.
    if (x == (int)x) {
        if (x > 0.0) {
            ga = 1.0;               // use factorial
            for (i=2;i<x;i++) {
               ga *= i;
            }
         }
         else
            ga = 1e308;
     }
     else {
        if (fabs(x) > 1.0) {
            z = fabs(x);
            m = (int)z;
            r = 1.0;
            for (k=1;k<=m;k++) {
                r *= (z-k);
            }
            z -= m;
        }
        else
            z = x;
        gr = g[24];
        for (k=23;k>=0;k--) {
            gr = gr*z+g[k];
        }
        ga = 1.0/(gr*z);
        if (fabs(x) > 1.0) {
            ga *= r;
            if (x < 0.0) {
                ga = -M_PI/(x*ga*sin(M_PI*x));
            }
        }
    }*/
    return ga;
}
