clear
clc
close all
T=linspace(0,1,100);
%T=zeros(1,100);
mt=10;
nb=100;
nt=10;
labs=[-1*ones(nb,1); ones(nt,1)];
% Initial conditions for the classifier
to1=1;
to2=1;
lpeg=1;
nepch=5; % a high value increases the memory of the system (only integer values)
rch=5; % adaptability; increase if a fast adaptation to new values is required
w=zeros(1,2);
for ii=1:length(T)
    t=T(ii);
    back=randn(nb,2);
    x=mt*sin(2*pi*t);
    y=mt*cos(2*pi*t);
    tar=[randn(nt,1)+x randn(nt,1)+y];
    data=[back; tar];
    if ii==1
        w=mypegasos(data,labs,w,to1,to2,lpeg,nepch);
        labsp=sign(data*w'-1);
    else
        labsp=sign(data*w'-1);
        w=mypegasos(data,labsp,w,to1,to2,lpeg,nepch);
    end
    backp=data(labsp==-1,:);
    tarp=data(labsp==1,:);
    figure(1)
    clf
    subplot(1,2,1)
    hold on
    plot(back(:,1),back(:,2),'bo')
    plot(tar(:,1),tar(:,2),'ro')
    hold off
    title('Original')
    subplot(1,2,2)
    hold on
    plot(backp(:,1),backp(:,2),'bo')
    plot(tarp(:,1),tarp(:,2),'ro')
    hold off
    title('Online classification')
    disp(num2str(ii))
    pause(0.2)
    to1=to1+round((1/rch)*nepch)*nt;
    to2=to2+round((1/rch)*nepch)*nb;
end


