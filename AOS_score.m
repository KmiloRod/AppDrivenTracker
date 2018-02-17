function [AOS,fp,accuracy,overlap] = AOS_score(P,gtP,threshold)
% Function to calculate the AOS (Average Overlap Score) trough a sequence.
% The overlap is calculated between the object bounding box P and the
% ground truth bounding box gtP. The function returns the AOS value between
% 0 and 1, averaged along the entire sequence. The input threshold is used
% to estimate and output the false positive rate (fp), accuracy rate and
% overlap ratio of all frames.

nfp_det = sum(isnan(gtP(:,1)) & ~isnan(P(:,1)));
detectable = sum(~isnan(gtP(:,1)));
overlap = diag(bboxOverlapRatio(P(~isnan(P(:,1))&~isnan(gtP(:,1)),:), gtP(~isnan(P(:,1))&~isnan(gtP(:,1)),:)));

ntp = sum(overlap>threshold,'omitnan');
nfp = sum(overlap<=threshold, 'omitnan') + nfp_det;

fp = nfp/size(P,1);
accuracy    = ntp/detectable;

% Average over frames where the object was detected by the tracker
% AOS = mean(overlap);

% Average over frames where the object was detectable
AOS = sum(overlap,'omitnan')/detectable;

% overlap = 1000*ones(size(P,1),1);
% detectable = 0;
% nfp_det = 0;
% 
% for i = 1 : size(P,1)
%     if sum(isnan(P(i,:)))+sum(isnan(gtP(i,:))) == 0
%         overlap(i) = bboxOverlapRatio(P(i,:),gtP(i,:));
%     elseif sum(isnan(gtP(i,:)))~=0 && sum(isnan(P(i,:)))==0
%         nfp_det = nfp_det + 1;
%     end
%     if sum(isnan(gtP(i,:)))==0 
%        detectable = detectable + 1;
%     end
% end    
% 
% ntp = sum(overlap(overlap~=1000)>threshold);
% nfp = sum(overlap(overlap~=1000)<=threshold) + nfp_det;
% 
% fp = nfp/size(P,1);
% accuracy    = ntp/detectable;
% 
% % Average over frames where the object was detected by the tracker
% %AOS = mean(overlap(overlap~=1000));
% 
% % Average over frames where the object was detectable
% AOS = sum(overlap(overlap~=1000))/detectable;
