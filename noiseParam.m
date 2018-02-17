
function param = noiseParam(noisetype,N)
% N = 10; % distortion levels

switch noisetype
    case 'gaussian'
        % gaussian noise 
        m = zeros(N,1);
        v = linspace(4.5e-5,0.36,N);
        param = [m v(:)];
    case 'salt & pepper'
        % salt and pepper
        d     = linspace(5,50,N);
        param = d(:)/300;
    case 'Motion JPEG AVI'
        % mpeg
        Q     = linspace(95,12,N);
        param = round(Q(:));
	case 'MPEG-4'
        % mpeg
        Q     = linspace(95,12,N);
        param = round(Q(:));
    case 'blur'
        % blur
        wsize = 9*ones(N,1);
        sigma = linspace(0.34,32,N);
        param = [sigma(:) wsize];
end
