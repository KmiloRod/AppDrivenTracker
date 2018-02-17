function [precision] = location_error(P,gtP,threshold)
% Function to calculate the location error of a tracker trough a sequence.
% The input threshold is used to estimate and output the false positive
% rate (fp), accuracy rate and overlap ratio of all frames.

% loc_error = 1000*ones(size(P,1),1);
% detectable = 0;
% nfp_det = 0;

gtP_loc = [gtP(:,1) + round(gtP(:,3)/2) gtP(:,2) + round(gtP(:,4)/2)];
bbox_loc = [P(:,1) + round(P(:,3)/2) P(:,2) + round(P(:,4)/2)];
loc_error = diag(pdist2(gtP_loc, bbox_loc));
detectable = size(P,1) - sum(isnan(gtP(:,1)));

ntp = sum(loc_error<=threshold);

precision = ntp/detectable;
% for i = 1 : size(P,1)
%     if sum(isnan(P(i,:)))+sum(isnan(gtP(i,:))) == 0
%         loc_error(i) = 
%         overlap(i) = bboxOverlapRatio(P(i,:),gtP(i,:));
%     elseif sum(isnan(gtP(i,:)))~=0 && sum(isnan(P(i,:)))==0
%         nfp_det = nfp_det + 1;
%     end
%     if sum(isnan(gtP(i,:)))==0 
%        detectable = detectable + 1;
%     end
% %         if (sum(isnan(P(i,:)))~=0 & sum(isnan(gtP(i,:)))==0) == 1
% %            nfn = nfn + 1; 
% %         end
% end    
% 
% ntp = sum(overlap(overlap~=1000)>threshold);
% nfp = sum(overlap(overlap~=1000)<=threshold) + nfp_det;
% 
% fp = nfp/size(P,1);
% % recall    = ntp/(ntp+nfn);
% accuracy    = ntp/detectable;
% 
% % Average over frames where the object was detected by the tracker
% %AOS = mean(overlap(overlap~=1000));
% 
% % Average over frames where the object was detectable
% AOS = sum(overlap(overlap~=1000))/detectable;
