function [region, num_regions] = bg_regions(bgP, frame_size)
% This function determines to which of 9 spatial regions of the video frame
% belongs each of the background patches in bgP. The function receives as
% inputs the bgP matrix, and an array with the frame size.
% The function outputs an array of indeces of the region in which each
% background patch is located (region) and the number of regions in which
% is divided the frame (num_regions)

num_rows = 3; num_cols = 3;
row_height = round(frame_size(1)/num_rows);
col_width = round(frame_size(2)/num_cols);
reg_index = 1;

for i = 1:num_rows
    for j = 1:num_cols
        bgP_ovlps(:,reg_index) = bboxOverlapRatio(bgP,[1 + (j-1)*col_width, 1 + (i-1)*row_height,...
            col_width, row_height], 'ratioType', 'Min');
        reg_index = reg_index + 1;
    end
end

[~, region] = max(bgP_ovlps, [], 2);
num_regions = reg_index - 1;