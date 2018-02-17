function q = q_obj_estimation(curr_bbox,pristine_bbox,gt_bbox)
% Estimation of the q_obj application-driven metric quality from target
% patches of a video frame. The q metric is estimated as the ratio between
% the overlap of the tracked and the ground-truth target bounding boxes in
% a distorted video frame, and the pristine version of the same frame.

C = 0.01;

%q = (bboxOverlapRatio(curr_bbox,gt_bbox) + C)/(bboxOverlapRatio(pristine_bbox,gt_bbox) + C);
q = (bboxOverlapRatio(pristine_bbox,gt_bbox,'Min') - bboxOverlapRatio(curr_bbox,gt_bbox,'Min'))/(bboxOverlapRatio(curr_bbox,gt_bbox,'Min') + bboxOverlapRatio(pristine_bbox,gt_bbox,'Min'));