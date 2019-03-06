function q = q_obj_estimation(curr_bbox,pristine_bbox,gt_bbox)
% Estimation of the q_obj application-driven metric quality from target
% patches of a video frame. The q metric is estimated as the ratio between
% the overlap of the tracked and the ground-truth target bounding boxes in
% a distorted video frame, and the pristine version of the same frame.

C = 0.01;

%q = (bboxOverlapRatio(curr_bbox,gt_bbox) + C)/(bboxOverlapRatio(pristine_bbox,gt_bbox) + C);
%q = 2*(bboxOverlapRatio(curr_bbox,gt_bbox))./(bboxOverlapRatio(curr_bbox,gt_bbox) + bboxOverlapRatio(pristine_bbox,gt_bbox));
%q = (bboxOverlapRatio(pristine_bbox,gt_bbox,'Min') - bboxOverlapRatio(curr_bbox,gt_bbox,'Min'))/(bboxOverlapRatio(curr_bbox,gt_bbox,'Min') + bboxOverlapRatio(pristine_bbox,gt_bbox,'Min'));
%q = (bboxOverlapRatio(pristine_bbox,gt_bbox) - bboxOverlapRatio(curr_bbox,gt_bbox))./(bboxOverlapRatio(curr_bbox,gt_bbox) + bboxOverlapRatio(pristine_bbox,gt_bbox));
prst_ovlp = mean(bboxOverlapRatio(pristine_bbox,gt_bbox));
curr_ovlp = mean(bboxOverlapRatio(curr_bbox,gt_bbox));

q = (prst_ovlp - curr_ovlp)./(prst_ovlp + curr_ovlp);  %v1
%q = (curr_ovlp + C)/(prst_ovlp + C);                   %v2
%q = curr_ovlp - prst_ovlp;                              %v3
%q = 2*curr_ovlp./(prst_ovlp + curr_ovlp);               %v4