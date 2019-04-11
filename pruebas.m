% Ing. Carlos Fernando Quiroga 10 / Apr / 2019
% This function calculates which frame is being analyzed depending on the 
%frames removed in the calculation stage of the HOGs characteristics, in 
%the testsHOGs program (Note: testsHOG.m will become a function)

sumf=0;
num_frame = 1:1:size(y,2);

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