%function q = q_bg_estimation(I,pristine_metric,curr_bgP,objCode,points)
function q = q_bg_estimation(pristine_metrics,curr_metrics,bgP_regions)
% Estimation of the q_bg metric quality from background patches of a video
% frame. The q metric is estimated using a ratio between the Hamming
% distances from the background to the target patches in the BRIEF
% representation space for the distorted frame, and the same distance
% calculated in the pristine frame.

% C = 0.01;

bgP_metrics = zeros(size(bgP_regions,1),1);
bgP_metrics_prst = zeros(size(bgP_regions,1),1);

for i = 1:size(bgP_regions,1)
%     I_bgP  = selectPatch(I,curr_bgP(i,:));
%      bgCode = [mean2(I_bgP) std2(I_bgP)];
%     bgCode = briefDescriptor(I_bgP,points);
%     bgCode = entropy(I_bgP);
%     bgP_metric(i) = pdist2(objCode,bgCode,'hamming');
%     bgP_dist(i) = pdist2(objCode,bgCode);
%     bgP_dist(i) = corr2(I_objP, I_bgP);
    bgP_metrics_prst(i,:) = pristine_metrics(bgP_regions(i));
    bgP_metrics(i,:) = curr_metrics(bgP_regions(i));
end

%q = (bgP_dist + C)./(pristine_dist + C);
q = (bgP_metrics_prst - bgP_metrics)./(bgP_metrics + bgP_metrics_prst);
%q = 2*bgP_dist./(bgP_dist + pristine_dist);
%q = bgP_dist;