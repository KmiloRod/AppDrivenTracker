% Script for concatenating the FRIQUEE features extracted from object and
% background patches from the videos specified in the array i, for using
% them as training samples

train_feats_obj = []; train_feats_bg = [];
train_labels_obj = []; train_labels_bg = [];

%for i = [1, 2, 4, 5, 6, 7, 8, 12, 13, 18, 20, 22, 23, 27, 29]
for i = [2, 4, 5, 8, 13]
%    i = 2;
    i
    %[train_feats_i, train_labels_i] = gT_samples_extraction_FRIQUEE(i, 'uneven illumination', 51, 5);
    [train_feats_obj_i, train_feats_bg_i, train_labels_obj_i, train_labels_bg_i] = ...
        gT_samples_extraction_FRIQUEE(i, 'Gaussian', 101, 5);
    %train_feats = [train_feats; train_feats_i];
    train_feats_obj = [train_feats_obj; train_feats_obj_i];
    train_feats_bg = [train_feats_bg; train_feats_bg_i];
    %train_labels = [train_labels; train_labels_i];
    train_labels_obj = [train_labels_obj; train_labels_obj_i];
    train_labels_bg = [train_labels_bg; train_labels_bg_i];
end
clear train_feats_obj_i train_labels_obj_i train_feats_bg_i train_labels_bg_i

% gT_q_obj_n = (gT_q_obj - mean(gT_q_obj))./std(gT_q_obj);
% gT_q_bg_n = (gT_q_bg - mean(gT_q_bg))./std(gT_q_bg);
% 
% gT_q_obj_n = 1 ./ (1+exp(gT_q_obj_n));
% gT_q_bg_n = 1 ./ (1+exp(gT_q_bg_n));


