% Modified by Camilo Rodriguez

function FRIQUEEcoeffvect =  computeFRIQUEEcoeff(vidname,height,width, ...
                           framenumber)

%--------------------------------------------------------------------------
% Feature Computation

%feat = [];
display(vidname)
tic
framevector  = 1:2:framenumber-1;
count = 1;
for frameitr = framevector   

    [ydis1 ydis2]           = readframe(vidname,frameitr,height,width);
    [feat]                  = computeFRIQUEEfeatvector(ydis1,ydis2);
    param(count).featvect   = feat;
    count                   = count +1;                               
end

% Score Computation
FRIQUEEcoeffvect             = computeFRIQUEEcoeffvector(param);
toc
end
%-------------------------------------------------------------------------
function FRIQUEEcoeffvect = computeFRIQUEEcoeffvector(param)

len                   = size(param,2)-1;
gap                   = floor(len/10);
FRIQUEEcoeffvect       = [];
for itr               = 1:round(gap/2):len
    
    f1_cum            = [];
    f2_cum            = [];
    
    for itr_param     = itr:min(itr+gap,len)
        
%         low_Fr1       =  [param(itr_param).featvect(:,3:14) ];
%         low_Fr2       =  [param(itr_param+1).featvect(:,3:14)];
        
        low_Fr1       =  [param(itr_param).featvect];
        low_Fr2       =  [param(itr_param+1).featvect];
        
%         high_Fr1      =  [param(itr_param).featvect(:,17:28)  ];
%         high_Fr2      =  [param(itr_param+1).featvect(:,17:28)];        
%                 
         vec1          = abs(low_Fr1 - low_Fr2);
%         vec2          = abs(high_Fr1- high_Fr2);
%        vec1          = low_Fr1 - low_Fr2;
%         vec2          = high_Fr1- high_Fr2;
        
%         [IDX    col]  = find(isinf(vec1)|isnan(vec1)|...
%                           isinf(vec2)|isnan(vec2));
        [IDX    col]  = find(isinf(vec1)|isnan(vec1));
                      
        vec1(IDX,:)   = [];
%         vec2(IDX,:)   = [];
        
        
        if(~isempty(vec1))
            f1_cum    = [f1_cum; vec1];
%             f2_cum    = [f2_cum; vec2];
        end
        
    end
%    if(~isempty(f1_cum))
    %C                 = diag(corr(f1_cum,f2_cum));
    %VIIDEOscorevect   = [ VIIDEOscorevect;mean(C(:))];
%    end
    FRIQUEEcoeffvect   = [FRIQUEEcoeffvect; f1_cum];
end
end

%--------------------------------------------------------------------------
function [featvect] = computeFRIQUEEfeatvector(ydis1,ydis2)

warning('off')
% shifts          = [1 0; 0 1; 1 1; 1 -1];
% window          = fspecial('gaussian',filtlength,mean(filtlength)/6);
% window          = window/sum(sum(window));

featvect        = [];

temporalsignal  = ydis1-ydis2;

featvect = [featvect friqueeLumaFeats(temporalsignal)];

% Convert the input RGB image to LAB color space.
lab = convertRGBToLAB(temporalsignal);
% Get the A and B components of the LAB color space.
A = double(lab(:,:,2));
B = double(lab(:,:,3));
% Compute the chroma map.
chroma = sqrt(A.*A + B.*B);
featvect = [featvect friqueeChromaFeats(chroma)];

% Convert the input RGB image to LMS color space.
lms = convertRGBToLMS(temporalsignal);
% Get the M and S components from the LMS color space.
LM = double(lms(:,:,2));
LS = double(lms(:,:,3));
fM = friqueeMSFeats(LM);
fS = friqueeMSFeats(LS);
featOpp = lmsColorOpponentFeats1(lms); % Color opponency features.

featvect = [featvect fM fS featOpp];

%FRIQUEE features from Hue and Saturation color maps.
% Convert the input RGB image to HSI color space.
hsv = convertRGBToHSI(temporalsignal);
featvect = [featvect friqueeHueSatFeats(hsv)];

% for itr =1:2
%     
% X                        = temporalsignal;
% mu_X                     = imfilter(X,window,'replicate');
% mu_sq                    = mu_X.*mu_X;
% sigma_X                  = sqrt(abs(imfilter(X.*X,window,'replicate')- mu_sq));
% 
% structdis                = (X-mu_X)./(sigma_X+1);
% 
% feat                     = computefeatvect(structdis,blocksizerow,...
%                          blocksizecol,blockrowoverlap,blockcoloverlap);
% featvect                 = [featvect feat(:,1) (feat(:,2)+feat(:,3))/2]; 
% 
% % featvect                 = [featvect; structdis(:)];
% 
% for itr_shift = 1:4
%     
% structdis_shifted        = circshift(structdis,shifts(itr_shift,:));
% feat                     = computefeatvect(structdis.*structdis_shifted, ...
%                            blocksizerow,blocksizecol,...
%                            blockrowoverlap,blockcoloverlap);
% featvect                 = [featvect feat]; 
% 
% end
% 
% temporalsignal          = mu_X;
%  
% end
end
%--------------------------------------------------------------------------
% function [feat]          = computefeatvect(structdis,blocksizerow,blocksizecol,...
%                            blockrowoverlap,blockcoloverlap)
%                        
% featnum                  = 3;
% feat                     = blkproc(structdis,[blocksizerow  blocksizecol],...
%                          [ blockrowoverlap blockcoloverlap],@estimateaggdparam);
% feat                     = reshape(feat,[featnum size(feat,1)*size(feat,2)/featnum]);
% feat                     = feat';
% feat                     = [feat(:,1) feat(:,2) feat(:,3)];
% end

%--------------------------------------------------------------------------
function [structdis,iMinusMu,mu,sigma]= divisiveNormalization(imdist)
    
    window = fspecial('gaussian',7,7/6);
    window = window/sum(sum(window));
    
    mu = filter2(window, imdist, 'same');
    mu_sq = mu.*mu;
    
    sigma = sqrt(abs(filter2(window, imdist.*imdist, 'same') - mu_sq));
    iMinusMu = (imdist-mu);
    structdis =iMinusMu./(sigma +1);
end

%--------------------------------------------------------------------------
function feat      = estimateaggdparam(vec)

vec                = vec(:);

if(sum(abs(vec(:))))
    
gam                = 0.2:0.01:5;
r_gam              = ((gamma(2./gam)).^2)./(gamma(1./gam).*gamma(3./gam));
leftstd            = sqrt(mean((vec(vec<0)).^2));
rightstd           = sqrt(mean((vec(vec>0)).^2));
gammahat           = leftstd/rightstd;
rhat               = (mean(abs(vec)))^2/mean((vec).^2);
rhatnorm           = (rhat*(gammahat^3 +1)*(gammahat+1))/((gammahat^2 +1)^2);
[min_difference,...
   array_position] = min((r_gam - rhatnorm).^2);
alpha              = gam(array_position);
betal              = leftstd *sqrt(gamma(1/alpha)/gamma(3/alpha));
betar              = rightstd*sqrt(gamma(1/alpha)/gamma(3/alpha));
feat               = [alpha;betal;betar];

else
    
feat               = [inf; inf ; inf];
end
end
%--------------------------------------------------------------------------
function [y1 y2]  =  readframe(vidfilename, framenum,height,width)

fid                  =  fopen(vidfilename);

fseek(fid,(framenum-1)*width*height*1.5,'bof');

y1           = fread(fid,width*height, 'uchar')';
y1           = reshape(y1,[width height]);
y1           = y1';
fseek(fid,width*height*((framenum-1)*1.5+1),'bof');
u1           = fread(fid,width*height*0.25, 'uchar')';
u1           = reshape(u1, [width/2 height/2]);
u1           = u1';
fseek(fid,width*height*((framenum-1)*1.5+1.25),'bof');
v1           = fread(fid,width*height*0.25, 'uchar')';
v1           = reshape(v1, [width/2 height/2]);
v1           = v1';

y1 = yuv2rgb(y1,u1,v1);

fseek(fid,(framenum)*width*height*1.5,'bof');

y2           = fread(fid,width*height, 'uchar')';
y2           = reshape(y2,[width height]);
y2           = y2'; 
fseek(fid,width*height*((framenum)*1.5+1),'bof');
u2           = fread(fid,width*height*0.25, 'uchar')';
u2           = reshape(u2, [width/2 height/2]);
u2           = u2';
fseek(fid,width*height*((framenum)*1.5+1.25),'bof');
v2           = fread(fid,width*height*0.25, 'uchar')';
v2           = reshape(v2, [width/2 height/2]);
v2           = v2';

y2 = yuv2rgb(y2,u2,v2);

fclose(fid);
end
%--------------------------------------------------------------------------

% -- FRIQUEE Features -----------------------------------------------------
function feat = friqueeLumaFeats(rgb)
    
    imGray = double(rgb2gray(rgb));
    %imGray = rgb;
    %% Initializations
    scalenum=2;
    imGray1=imGray;
    
    % The array that aggregates all the features from different feature
    % maps.
    feat = [];
    
    for itr_scale = 1:scalenum
        % 4 Neighborhood map features of Luma map
       nFeat = neighboringPairProductFeats(imGray);
       feat = [feat nFeat];
       
        
        % Sigma features of Luma map
        sigFeat = sigmaMapFeats(imGray);
        feat = [feat sigFeat];
        
        % Luma map's classical debiased and normalized map's features.
        dnFeat = debiasedNormalizedFeats(imGray);
        feat = [feat dnFeat];
        
        imGray = imresize(imGray,0.5);      
    end
    
    imGray=imGray1;
   
    % Features from the Yellow color channel map.
    yFeat=yellowColorChannelMap(rgb);
    feat = [feat yFeat];
    
    % Features from the Difference of Gaussian (DoG) of Sigma Map 
    dFeat =DoGFeat(imGray);
    feat = [feat dFeat];
      
    % Laplacian of the Luminance Map
    lFeat = lapPyramidFeats(imGray);
    feat =[feat lFeat];
end

function feat = friqueeChromaFeats(imChroma)

    % Initializations
    scalenum=2;   
    imChroma1=imChroma;
    
    % The array that aggregates all the features from different feature
    % maps.
    feat = [];
    
    % Some features are computed at multiple scales
    for itr_scale = 1:scalenum
        
        % 4 Neighborhood map features of Chroma map
       nFeat = neighboringPairProductFeats(imChroma);
       feat = [feat nFeat];
       
        % Sigma features of Chroma map
        [sigFeat, sigmaMap] = sigmaMapFeats(imChroma);
        feat = [feat sigFeat];
        
        % Chroma map's classical debiased and normalized map's features.
        dnFeat = debiasedNormalizedFeats(imChroma);
        feat = [feat dnFeat];
        
        % Debiased and normalized map features of the sigmaMap of Chroma map.
        dnSigmaFeat = debiasedNormalizedFeats(sigmaMap);
        feat = [feat dnSigmaFeat];

        % Scale down the image by 2 and repeat the feature extraction.
        imChroma = imresize(imChroma,0.5);
    end
    
    imChroma=imChroma1;
    
    % Features from the Difference of Gaussian (DoG) of Sigma Map 
    dFeat =DoGFeat(imChroma);
    feat = [feat dFeat];
    
    % Laplacian of the Chroma Map
    lFeat = lapPyramidFeats(imChroma);
    feat = [feat lFeat];
end
function feat = friqueeMSFeats(img)
    scalenum=2;
    img1=img;

    % The array that aggregates all the features from different feature
    % maps.
    feat = [];

    for itr_scale = 1:scalenum    
         % Sigma features of M or S map (from LMS)
        [sigFeat, sigmaMap] = sigmaMapFeats(img);
        feat = [feat sigFeat];
        
        % M or S map's classical debiased and normalized map's features.
        dnFeat = debiasedNormalizedFeats(img);
        feat = [feat dnFeat];
        
         % Debiased and normalized map features of the sigmaMap of Chroma map.
        dnSigmaFeat = debiasedNormalizedFeats(sigmaMap);
        feat = [feat dnSigmaFeat];

        img = imresize(img,0.5);
    end
    
    img=img1;
   
    % Features from the Difference of Gaussian (DoG) of Sigma Map 
    dFeat =DoGFeat(img);
    feat = [feat dFeat];
    
    % Laplacian of the Chroma Map
    lFeat = lapPyramidFeats(img);
    feat =[feat lFeat];
end
function feat = lmsColorOpponentFeats1(lms)
% function dRG = lmsColorOpponentFeats(lms)
    % Extract the three channel maps (L,M, and S)
    l = double(lms(:,:,1))+1; 
    m = double(lms(:,:,2))+1; 
    s = double(lms(:,:,3))+1; 
    
    % Apply divisive normalization on log of these channel maps.
    dL = divisiveNormalization(log(l));
    dM = divisiveNormalization(log(m));
    dS = divisiveNormalization(log(s));
    
    % Constructing the BY-color opponency map.
    dBY = (dL+dM-2*dS)./sqrt(6);
    
    % Extracting model parameters (derived from AGGD fit) and the sample
    % statistical features (kurtosis and skewness)
    aggdParams2 = estimateaggdparam(dBY(:));
    beta2 = aggdParams2(1); lsigma2 = aggdParams2(2); rsigma2 = aggdParams2(3);
%     [beta2,lsigma2,rsigma2] = estimateaggdparam(dBY(:));
    kurt2=kurtosis(dBY(:));
    sk2 = skewness(dBY(:));
    
    % Constructing the RG-color opponency map.
    dRG = (dL-dM)./sqrt(2);
    
    % Extracting model parameters (derived from AGGD fit) and the sample
    % statistical features (kurtosis and skewness)
    aggdParams3 = estimateaggdparam(dBY(:));
    beta3 = aggdParams3(1); lsigma3 = aggdParams3(2); rsigma3 = aggdParams3(3);
%     [beta3,lsigma3,rsigma3] = estimateaggdparam(dRG(:));
    kurt3=kurtosis(dRG(:));
    sk3 = skewness(dRG(:));
    
    % Aggregating the final set of features from both the opponency maps.
    modelParamsBY = [beta2,lsigma2,rsigma2];
    sampleParamsBY = [kurt2 sk2];
    
    modelParamsRG = [beta3,lsigma3,rsigma3];
    sampleParamsRG = [kurt3 sk3];
    
    feat = [modelParamsRG sampleParamsRG modelParamsBY sampleParamsBY];
end
function feat = friqueeHueSatFeats(hsv)
    % Get the H and S components of the HSV color space.
    H = double(hsv(:,:,1));
    S = double(hsv(:,:,2));
    
    % Extract sample statistics such as mean and standard deviation of Hue
    % and Saturation maps.
    feat = [mean(H(:)) std(H(:)) mean(S(:)) std(S(:))];
end