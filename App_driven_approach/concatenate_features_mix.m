% Script for concatenating the FRIQUEE features extracted from object and
% background patches from the videos specified in the array i, for using
% them as training samples. It also generates the suitable or non-suitable
% labeling for each object and background patch

train_feats_obj = []; train_feats_bg = [];
train_labels_obj = []; train_labels_bg = [];
q_obj_s = []; q_bg_s = [];
q_obj_ns = []; q_bg_ns = [];

%for i = [1, 2, 4, 5, 6, 7, 8, 12, 13, 18, 20, 22, 23, 27, 29]
%for i = [1, 2, 4, 5, 7, 8, 18]
    i = 2;
    i
    %[train_feats_i, train_labels_i] = gT_samples_extraction_FRIQUEE(i, 'uneven illumination', 51, 5);
    [train_feats_obj_i, train_feats_bg_i, train_labels_obj_i, train_labels_bg_i,...
        q_obj_s_i, q_obj_ns_i, q_bg_s_i, q_bg_ns_i] = ...
        gT_samples_extraction_FRIQUEE_mix(i, 300, 'Blur', 0.8, 10);
    
    q_obj_s = [q_obj_s; q_obj_s_i];
    q_obj_ns = [q_obj_ns; q_obj_ns_i];
    q_bg_s = [q_bg_s; q_bg_s_i];
    q_bg_ns = [q_bg_ns; q_bg_ns_i];
    
    %train_feats = [train_feats; train_feats_i];
    train_feats_obj = [train_feats_obj; train_feats_obj_i];
    train_feats_bg = [train_feats_bg; train_feats_bg_i];
    %train_labels = [train_labels; train_labels_i];
    train_labels_obj = [train_labels_obj; train_labels_obj_i];
    train_labels_bg = [train_labels_bg; train_labels_bg_i];
%end
clear train_feats_obj_i train_labels_obj_i train_feats_bg_i train_labels_bg_i

% gT_q_obj_n = (gT_q_obj - mean(gT_q_obj))./std(gT_q_obj);
% gT_q_bg_n = (gT_q_bg - mean(gT_q_bg))./std(gT_q_bg);
% 
% gT_q_obj_n = 1 ./ (1+exp(gT_q_obj_n));
% gT_q_bg_n = 1 ./ (1+exp(gT_q_bg_n));


