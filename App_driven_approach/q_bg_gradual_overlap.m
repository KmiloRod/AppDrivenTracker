% Name of the file with the initial object bounding box
v = 2;
Distortion = 'MPEG4';
vidName = {'car','jumping','pedestrian1','pedestrian2','pedestrian3','charger','cameraJuan','gurgaon'};
gtName  = {'car_gt','jumping_gt','pedestrian1_gt','pedestrian2_gt','pedestrian3_gt','charger_gt','cameraJuan_gt','gurgaon_gt'};
load(gtName{v},'gtP');

tests_array = [7, 4, 10, 7, 7, 3, 5, 10];
test = tests_array(v);

switch Distortion
    case 'MPEG4'
        Q = [60 30 0]; % MPEG Compression
    case 'Gaussian'
        Q = [0.01, 0.05, 0.1]; % AWGN
    case 'Blur'
        Q = [5, 10, 15]; % Blur
    case 'S & P'
        Q = [0.01, 0.05, 0.1]; % S & P
    otherwise
        Q = 0;
end

bboxName = strcat('bbox_',vidName{v});
load(strcat(bboxName,'Test',num2str(test)),'bgP','binCode','points');
points = points;
Nbg  = size(bgP,1);     % Number of background patches
patch_width = bgP(1,3); patch_height = bgP(1,4);

% Loading video file and parameters
load(vidName{v},'frames');
frames_pristine = frames;

    % Adjust size of ground-truth patch to match background patches
    gt_center = [gtP(1,1)+round(gtP(1,3)/2), gtP(1,2)+round(gtP(1,4)/2)];
    gtP(1,:) = [gt_center(1)-round(patch_width/2), gt_center(2)-round(patch_height/2), patch_width, patch_height];


test_patches = zeros(ceil(patch_width/2),4);
test_patches(:,3) = patch_width; test_patches(:,4) = patch_height;

k = 1;
for i = 1:2:patch_width
	test_patches(k,1) = gtP(1,1)+i;
	test_patches(k,2) = gtP(1,2)+i;
    k = k + 1;
end

Nbg = size(test_patches,1);

% Pristine case
I_objP  = selectPatch(frames_pristine(:,:,:,1),gtP(1,:));
objCode = briefDescriptor(I_objP,points);
bgP_dist_prst = zeros(Nbg,1);
parfor ind = 1:Nbg
    I_bgP  = selectPatch(frames_pristine(:,:,:,1),test_patches(ind,:));
    bgCode = briefDescriptor(I_bgP,points);
    bgP_dist_prst(ind) = pdist2(objCode,bgCode,'hamming');
end

% Distortion case
q_bg_patch = zeros(length(Q),Nbg);
for o = 1 : length(Q)
    o
    % Generate distorted version of the first frame
    switch Distortion
        case 'MPEG4'
            [frames] = vidnoise(frames_pristine,'MPEG-4',Q(o));
        case 'Gaussian'
            [frames] = vidnoise(uint8(frames_pristine),'gaussian',[0, Q(o)]);
        case 'Blur'
            [frames] = vidnoise(uint8(frames_pristine),'blur',Q(o));
        case 'S & P'
            [frames] = vidnoise(uint8(frames_pristine),'salt & pepper',Q(o));
    end
    frames = frames(:,:,:,1);

    % Calculation of BRIEF descriptor from ground-truth object patch
    I_objP  = selectPatch(frames,gtP(1,:));
    objCode = briefDescriptor(I_objP,points);

    % Calculate average q_bg for all background patches
    parfor ind = 1:Nbg
        q_bg_patch(o,ind) = q_bg_estimation(frames,bgP_dist_prst(ind),test_patches(ind,:),objCode,points);
    end
end

color_array = 'brgmck';

if ~strcmp(Distortion,'pristine')
    figure;
    for o = 1:length(Q)
        plot(1:Nbg,q_bg_patch(o,:),strcat(color_array(o),'o-'),'DisplayName',num2str(o));
        hold on
    end    
    hold off
    %title(sprintf('q_{bg} mean, video %u, %s distortion',v,Distortion));    
    title(sprintf('D_{d}, video %u, %s distortion',v,Distortion));    
    plot_ax = gca;
    plot_ax.FontSize = 16;        
    xlabel('Frames');
    ylabel('q_{bg}');
    legend('show','Location','southeast');
end


    