% Script for concatenating the FRIQUEE features extracted from object and
% background patches from the videos specified in the array i, for using
% them as training samples. It also generates the app-driven quality
% metrics q_obj and q_bg for each object and background patch respectively

gT_obj_feats = []; gT_bg_feats = [];
gT_q_obj = []; gT_q_bg = [];
C = 0.001;

%for i = [1, 2, 4, 5, 6, 7, 8, 12, 13, 18, 20, 22, 23, 27, 29]
for i = [2, 4, 5, 8, 13]
%for i = 8 
    i
    [gT_obj_feats_i, gT_bg_feats_i, gT_q_obj_i, gT_q_bg_i] = gT_samples_extraction_FRIQUEE_q(i, 201, 'Blur');
    gT_obj_feats = [gT_obj_feats; gT_obj_feats_i];
    gT_bg_feats = [gT_bg_feats; gT_bg_feats_i];
    gT_q_obj = [gT_q_obj; gT_q_obj_i]; gT_q_bg = [gT_q_bg; gT_q_bg_i];
end
clear gT_obj_feats_i gT_bg_feats_i
clear gT_q_obj_i gT_q_bg_i

gT_q_obj = (gT_q_obj - mean(gT_q_obj, 'omitnan'))./(std(gT_q_obj, 'omitnan')+C);
gT_q_obj = 1 ./ (1+exp(gT_q_obj));

% gT_q_obj_n = (gT_q_obj - mean(gT_q_obj))./std(gT_q_obj);
% gT_q_bg_n = (gT_q_bg - mean(gT_q_bg))./std(gT_q_bg);
% 
% gT_q_obj_n = 1 ./ (1+exp(gT_q_obj_n));
% gT_q_bg_n = 1 ./ (1+exp(gT_q_bg_n));


