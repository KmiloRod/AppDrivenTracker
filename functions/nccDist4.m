function dist = nccDist4(frames,P1,fp1,P2,fp2,points)

N1    = size(P1,1);
N2    = size(P2,1);
dist = 2*ones(N1,N2);

if N1 == N2
    for i = 1 : N1
        I1 = double(rgb2gray(uint8(frames(:,:,:,fp1(i)))));        
        for j = i : N2
            I2 = double(rgb2gray(uint8(frames(:,:,:,fp2(j)))));
            I_patch1 = I1(P1(j,2):P1(j,2)+P1(j,4)-1,P1(j,1):P1(j,1)+P1(j,3)-1);
            I_patch2 = I2(P2(i,2):P2(i,2)+P2(i,4)-1,P2(i,1):P2(i,1)+P2(i,3)-1);
            binCode1 = briefDescriptor(I_patch1,points);
            binCode2 = briefDescriptor(I_patch2,points);
            dist(i,j) = pdist2(binCode1,binCode2,'hamming');
            dist(j,i) = dist(i,j);
        end
    end
else
    for i = 1 : N1
        I1 = double(rgb2gray(uint8(frames(:,:,:,fp1(i)))));        
        for j = 1 : N2
            I2 = double(rgb2gray(uint8(frames(:,:,:,fp2(j)))));
            I_patch1 = I1(P1(i,2):P1(i,2)+P1(i,4)-1,P1(i,1):P1(i,1)+P1(i,3)-1);
            I_patch2 = I2(P2(j,2):P2(j,2)+P2(j,4)-1,P2(j,1):P2(j,1)+P2(j,3)-1);
            binCode1 = briefDescriptor(I_patch1,points);
            binCode2 = briefDescriptor(I_patch2,points);
            dist(i,j) = pdist2(binCode1,binCode2,'hamming');
        end
    end
end


% if N1 == N2
%     for i = 1 : N1
%         I1 = double(rgb2gray(uint8(frames(:,:,:,fp1(i)))));
%         for j = i : N2
%             I2 = double(rgb2gray(uint8(frames(:,:,:,fp2(j)))));
%             dist(i,j) = ncc(I1(P1(j,2):P1(j,2)+P1(j,4)-1,P1(j,1):P1(j,1)+P1(j,3)-1),...
%                             I2(P2(i,2):P2(i,2)+P2(i,4)-1,P2(i,1):P2(i,1)+P2(i,3)-1));
%             dist(j,i) = dist(i,j);
%         end
%     end
% else
%     for i = 1 : N1
%         I1 = double(rgb2gray(uint8(frames(:,:,:,fp1(i)))));
%         for j = 1 : N2
%             I2 = double(rgb2gray(uint8(frames(:,:,:,fp2(j)))));
%             dist(i,j) = ncc(I1(P1(i,2):P1(i,2)+P1(i,4)-1,P1(i,1):P1(i,1)+P1(i,3)-1),...
%                             I2(P2(j,2):P2(j,2)+P2(j,4)-1,P2(j,1):P2(j,1)+P2(j,3)-1));
%         end
%     end
% end
