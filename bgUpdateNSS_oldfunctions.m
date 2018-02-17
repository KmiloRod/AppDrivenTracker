function [hogFeatSet_nxt,bgKeys_nxt,NSSSet_nxt] = bgUpdateNSS(I,method,perUpd,objbbox_curr,bgP_curr,bgKeys_curr,hogFeatSet_curr,NSSSet_curr,Cs)

% I: current frame
% objbbox_curr: object bounding box at current frame I
% bgP_curr: background Patches
% objHOGfeat_curr: HOG features of the bg patches

imSize = size(I); 
Nbg  = size(bgP_curr,1);
Nobj = size(hogFeatSet_curr,1)-Nbg;
Nadd = round(Nbg*perUpd);   % Number of background patches to be updated

                    
switch method
    case 'msp' % minimum spatial proximity
        [bgP_nxt,bgKeys_nxt] = bgPatchGen(objbbox_curr,objbbox_curr,Nadd,imSize);
        dist_bgkeys = abs(bgKeys_curr*ones(1,Nadd) - ones(Nbg,1)*bgKeys_nxt');
        [~,idx_bgKeys] = min(dist_bgkeys);
        hogSbg_nxt = hogFeat(I,bgP_nxt);
        hogFeatSet_curr(Nobj+idx_bgKeys,:) = 0.35*hogSbg_nxt + 0.65*hogFeatSet_curr(Nobj+idx_bgKeys,:);
        hogFeatSet_nxt = hogFeatSet_curr;
        
    case 'mvc' % maximum variace change
        ibgP       = 1 : Nbg;
        bgPVar_nxt = patchVariance(I,bgP_curr); % bgKeys_nxt: variance vector
        bgPoverlap = bboxOverlapRatio(bgP_curr,objbbox_curr); % overlap (bg-obj) vector
        ibgP = ibgP(bgPVar_nxt > bgKeys_curr & bgPoverlap == 0); % bg patches that do not overlap with obj and their intensity variance is greater than in the previous frame
        if ~isempty(ibgP)
            disp(':)')
            [bgPVar_nxt,isort] = sort(bgPVar_nxt(ibgP),'descend');
            ibgP_nxt = ibgP(isort);
            if length(ibgP_nxt) > Nadd          % if more patches than Nadd match the conditions, crop them
                ibgP_nxt = ibgP_nxt(1:Nadd);
                bgPVar_nxt = bgPVar_nxt(1:Nadd);
            end
            bgKeys_curr(ibgP_nxt) = bgPVar_nxt; % keys of patches to update
            bgP_nxt = bgP_curr(ibgP_nxt,:); % patches to update
            % Old functions
            hogSbg_nxt = hogNSSFeat(I,bgP_nxt,0,Cs); % HOG features from patches to update
            NSSbg_nxt = nssFeat(I,bgP_nxt) / Cs; % NSS features from patches to update

            % New functions (OpenCV)
%             featuresSbg_nxt = hogNSSFeat(I,bgP_nxt,1,Cs);
%             hogSbg_nxt = featuresSbg_nxt(:,1:end-36); % HOG features from patches to update
%             NSSbg_nxt = featuresSbg_nxt(:,end-35:end); % NSS features from patches to update

            hogFeatSet_curr(Nobj+ibgP_nxt,:) = 0.35*hogSbg_nxt + 0.65*hogFeatSet_curr(Nobj+ibgP_nxt,:); % Calculate the new values for HOG features of updated patches and add them to the current bg matrix
            NSSSet_curr(Nobj+ibgP_nxt,:) = NSSbg_nxt; % Add the updated NSS features from updated patches to the bg matrix
        end
        bgKeys_nxt     = bgKeys_curr;
        hogFeatSet_nxt = hogFeatSet_curr;
        NSSSet_nxt = NSSSet_curr;
end