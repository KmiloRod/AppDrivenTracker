function [AOS,fp,accuracy,overlap] = AOS_score_SVMonly(P,gtP,threshold,MSflag)
% Function to calculate the AOS (Average Overlap Score) trough a sequence.
% The overlap is calculated between the object bounding box P and the
% ground truth bounding box gtP. The function returns the AOS value between
% 0 and 1, averaged along the entire sequence. The input threshold is used
% to estimate and output the false positive rate (fp), accuracy rate and
% overlap ratio of all frames.

overlap = 1000*ones(size(P,1),1);
%detectable = 0;
SVMframes = 0;
nfp_det = 0;


for i = 1 : size(P,1)
    if (sum(isnan(P(i,:)))+sum(isnan(gtP(i,:))) == 0) && (MSflag(i) == 0)
        overlap(i) = bboxOverlapRatio(P(i,:),gtP(i,:));
    elseif sum(isnan(gtP(i,:)))~=0 && sum(isnan(P(i,:)))==0
        nfp_det = nfp_det + 1;
    end
    if (sum(isnan(gtP(i,:)))==0) && (MSflag(i) == 0)
       %detectable = detectable + 1;
       SVMframes = SVMframes + 1;
    end
%         if (sum(isnan(P(i,:)))~=0 & sum(isnan(gtP(i,:)))==0) == 1
%            nfn = nfn + 1; 
%         end
end    

ntp = sum(overlap(overlap~=1000)>threshold);
nfp = sum(overlap(overlap~=1000)<=threshold) + nfp_det;

fp = nfp/size(P,1);
% recall    = ntp/(ntp+nfn);
% accuracy    = ntp/detectable;
accuracy    = ntp/SVMframes;

AOS = mean(overlap(overlap~=1000));
