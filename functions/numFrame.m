% Ing. Carlos Fernando Quiroga 10 / Apr / 2019
% This function calculates which frame is being analyzed depending on the 
% frames removed in the calculation stage of the HOGs or NSS characteristics, in 
% the hog_nss program 

%the function receives two parameters. y and k, "y" is the array that 
%contains the PCA characteristics of the data set, and "k" is the vector 
%that contains the frames that have been removed in the calculation stage 
%of the HOG or NSS characteristics

function num_frame = numFrame(y,k)
  
    sumf=0;
    num_frame = 1:1:size(y,2);
    
    if isempty(k)==0
        init=k(1);
        for i=2:size(k,1)
            distance(i-1)=k(i)-k(i-1); 
            if distance(i-1) == 1
                sumf=sumf+distance(i-1);
                if i == size(k,1)
                    num_frame(1,init:size(y,2))=(sumf+1)+num_frame(1,init:size(y,2));
                end
            else 
                num_frame(1,init:size(y,2))=(sumf+1)+num_frame(1,init:size(y,2));
                init=find(num_frame == k(sumf+2));
                sumf=0;
            end
        end
    end
end