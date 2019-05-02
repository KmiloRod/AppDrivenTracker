% Ing. Carlos Fernando Quiroga Ruiz 23/Apr/2019
% This function graphs the results of the "PCA_" function with the possibility 
% of graphing up to 3 dimensions.
% 
% The input parameters are:
% - y: vector type cell that contains in each of its cells the characteristics 
%   of each frame. (cell)
%   To see how this vector is built see the "PCA_" function
% - "distortion": indicates which distortions have been applied in the 
%  construction of the dataset.
%
% CLASSES: 
% 1 Image Pristine
% 2 Distorsion MPEG-4
% 3 Distorsion gaussian
% 4 Distorsion blur
% 5 Distorsion salt & pepper
% 6 Distorsion uneven illumination
%
% - "Q": is a cell type arrangement where each cell contains the distortion 
%  levels applied for each distortion.
% - "k" is the vector that contains the frames that have been removed in the 
%   calculation stage of the HOG or NSS characteristics this parameter is
%   calculated automatly by hog_nss function
% - graph: define the type of graph


function graphics(y, distorsion, Q , k, graph)

    %Load Dataset
    
    M=size(distorsion,2)+1; %Number of classes without differentiating the level of distortion (number of distortions + pristine image)

    q(1)=1;
    for i=1:size(Q,2)
        q(i+1)=size(Q{i},2);
    end 
    
    for i = 1:size(y,2)
        [d,N]=size(y{i}); %N Numero caracteristicas Data-Set x frame, d ejemplos x frame
        for j=1:M
            DN{i}(j)= d *q(j)/sum(q); % Data Number for class
        end
    end

       
    %-"xymin" and "xymax": vectors containing the minimum and maximum values of 
    % each PCA transformation per frame
    

    for i=1:size(y,2)
        xymin(i,:)=min(y{i});
        xymax(i,:)=max(y{i});
    end

    xyn=min(xymin);
    xyx=max(xymax);

    num_frame = numFrame(y,k);

    tamano=get(0,'ScreenSize');

    switch graph
        case 0
        case 1
            %1 graphic pristine video and distored videos 1D
            figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
            for i=1:size(y,2)
                pause(0.005);

                subplot(1,2,1);
                plot(y{i}(1:DN{i}(1),1),1, 'ob',...
                     y{i}(DN{i}(1)+1:sum(DN{i}),1),0, '.r');
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]);
                legend('Pristine Video', 'Distored video');
                xlabel('Component 1');
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
                hold on; grid on;

                subplot(1,2,2);
                plot(y{i}(1:DN{i}(1),1),1, 'ob',... %Pristine Video
                     y{i}(DN{i}(1)+1:DN{i}(1)+DN{i}(2),1),0,'.r',... %gaussian
                     y{i}(DN{i}(1)+DN{i}(2)+1:DN{i}(1)+DN{i}(2)+DN{i}(3),1),0,'.g',... %MPEG-4
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+1:DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4),1),0,'.y',...%blurr
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+1:... %salt & pepper
                          DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5),1),0,'.c',...
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5)+1:sum(DN{i}),1),0,'.m');... %uneven illumination

                %hold on; 
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]);
                legend('Pristine', 'gaussian', 'MPEG-4',...
                      'blurr', 'salt & pepper', 'uneven illumination');
                xlabel('Component 1'); grid on;
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
                %imshow(uint8(frames_pristine{i}));


            end         
        case 2
            %2 graphic only pristine video 1D
            figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
            for i=1:size(y,2)
                pause(0.005);

                subplot(1,2,1);
                plot(y{i}(1:3,1),1, '.b',... %Pristine Video
                     y{i}(4:6,1),1,'.r',...
                     y{i}(7:9,1),1,'.g');
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]);
                legend('column 1', 'column 2', 'column 3');
                xlabel('Component 1');
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
                hold on; grid on;

                subplot(1,2,2);
                plot(y{i}(1:3,1),1,'ob',... %Pristine Video
                     y{i}(4:6,1),1,'or',...
                     y{i}(7:9,1),1,'og'); 

                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]);
                legend('column 1', 'column 2', 'column 3');
                xlabel('Component 1'); grid on;
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
               %imshow(uint8(frames_pristine{i}));
            end 
        case 3
            %1 graphic pristine video and distored videos 2D
            figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
            for i=1:size(y,2)
                pause(0.005);

                subplot(1,2,1);
                plot(y{i}(1:DN{i}(1),1),y{i}(1:DN{i}(1),2), 'ob',...
                     y{i}(DN{i}(1)+1:sum(DN{i}),1),y{i}(DN{i}(1)+1:sum(DN{i}),2), '.r');
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]);
                legend('Pristine Video', 'Distored video');
                xlabel('Component 1');ylabel('Component 2');grid on;
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
                hold on; 

                subplot(1,2,2);
                plot(y{i}(1:DN{i}(1),1),y{i}(1:DN{i}(1),2), 'ob',... %Pristine Video
                     y{i}(DN{i}(1)+1:DN{i}(1)+DN{i}(2),1),... %gaussian
                          y{i}(DN{i}(1)+1:DN{i}(1)+DN{i}(2),2), '.r',... 
                     y{i}(DN{i}(1)+DN{i}(2)+1:DN{i}(1)+DN{i}(2)+DN{i}(3),1),... %MPEG-4
                          y{i}(DN{i}(1)+DN{i}(2)+1:DN{i}(1)+DN{i}(2)+DN{i}(3),2), '.g',... 
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+1:DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4),1),...%blurr
                          y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+1:DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4),2), '.y',...  
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+1:... %salt & pepper
                          DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5),1),...
                          y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+1:...
                          DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5),2), '.c',...
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5)+1:sum(DN{i}),1),... %uneven illumination
                          y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5)+1:sum(DN{i}),2), '.m'); 
                hold on; 
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]);
                legend('Pristine', 'gaussian', 'MPEG-4',...
                      'blurr', 'salt & pepper', 'uneven illumination');
                xlabel('Component 1');ylabel('Component 2');grid on;
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
                %imshow(uint8(frames_pristine{i}));

            end 
        case 4
            %2 graphic only pristine video 2D
            figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
            for i=1:size(y,2)
                pause(0.005);

                subplot(1,2,1);
                plot(y{i}(1:3,1),y{i}(1:3,2), '.b',... %Pristine Video
                     y{i}(4:6,1),y{i}(4:6,2),'.r',...
                     y{i}(7:9,1),y{i}(7:9,2),'.g');
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]);
                legend('column 1', 'column 2', 'column 3');
                xlabel('Component 1');ylabel('Component 2');grid on;
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
                hold on; 

                subplot(1,2,2);
                plot(y{i}(1:3,1),y{i}(1:3,2),'ob',... %Pristine Video
                     y{i}(4:6,1),y{i}(4:6,2),'or',...
                     y{i}(7:9,1),y{i}(7:9,2),'og'); 

                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]);
                legend('column 1', 'column 2', 'column 3');
                xlabel('Component 1');ylabel('Component 2');grid on;
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
               %imshow(uint8(frames_pristine{i}));
            end 
        case 5
            %1 graphic pristine video and distored videos 3D
            figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
            for i=1:size(y,2)
                pause(0.005);

                subplot(1,2,1);
                plot3(y{i}(1:DN{i}(1),1),y{i}(1:DN{i}(1),2),y{i}(1:DN{i}(1),3),'ob',...
                     y{i}(DN{i}(1)+1:sum(DN{i}),1),y{i}(DN{i}(1)+1:sum(DN{i}),2),y{i}(DN{i}(1)+1:sum(DN{i}),3),'.r');
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]); zlim([xyn(3)-1 xyx(3)+1]);
                legend('Pristine Video', 'Distored video'); grid on;
                xlabel('Component 1');ylabel('Component 2');zlabel('Component 3');
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
                hold on; 

                subplot(1,2,2);
                plot3(y{i}(1:DN{i}(1),1),...%Pristine Video
                     y{i}(1:DN{i}(1),2),...
                     y{i}(1:DN{i}(1),3),'ob',... 
                     y{i}(DN{i}(1)+1:DN{i}(1)+DN{i}(2),1),... %gaussian
                     y{i}(DN{i}(1)+1:DN{i}(1)+DN{i}(2),2),...
                     y{i}(DN{i}(1)+1:DN{i}(1)+DN{i}(2),3),'.r',... 
                     y{i}(DN{i}(1)+DN{i}(2)+1:DN{i}(1)+DN{i}(2)+DN{i}(3),1),... %MPEG-4
                     y{i}(DN{i}(1)+DN{i}(2)+1:DN{i}(1)+DN{i}(2)+DN{i}(3),2),...
                     y{i}(DN{i}(1)+DN{i}(2)+1:DN{i}(1)+DN{i}(2)+DN{i}(3),3),'.g',... 
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+1:DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4),1),...%blurr
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+1:DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4),2),...
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+1:DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4),3),'.y',...  
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+1:... %salt & pepper
                          DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5),1),...
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+1:...
                          DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5),2),...
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+1:...
                          DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5),3),'.c',...
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5)+1:sum(DN{i}),1),... %uneven illumination
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5)+1:sum(DN{i}),2),... 
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5)+1:sum(DN{i}),3),'.m'); 
                hold on; 
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]); zlim([xyn(3)-1 xyx(3)+1]);
                legend('Pristine', 'gaussian', 'MPEG-4',...
                      'blurr', 'salt & pepper', 'uneven illumination'); grid on;
                xlabel('Component 1');ylabel('Component 2');zlabel('Component 3');
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
                %imshow(uint8(frames_pristine{i}));         
            end 
        case 6
             %2 graphic only pristine video 3D
            figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
            for i=1:size(y,2)
                pause(0.005);

                subplot(1,2,1);
                plot3(y{i}(1:3,1),y{i}(1:3,2),y{i}(1:3,3), '.b',... %Pristine Video
                     y{i}(4:6,1),y{i}(4:6,2),y{i}(4:6,3),'.r',...
                     y{i}(7:9,1),y{i}(7:9,2),y{i}(7:9,3),'.g');
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]); zlim([xyn(3)-1 xyx(3)+1]);
                legend('column 1', 'column 2', 'column 3');
                xlabel('Component 1');ylabel('Component 2');zlabel('Component 3');
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
                hold on; grid on;

                subplot(1,2,2);
                plot3(y{i}(1:3,1),y{i}(1:3,2),y{i}(1:3,3),'ob',... %Pristine Video
                     y{i}(4:6,1),y{i}(4:6,2),y{i}(4:6,3),'or',...
                     y{i}(7:9,1),y{i}(7:9,2),y{i}(7:9,3),'og'); 
                
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]); zlim([xyn(3)-1 xyx(3)+1]);
                legend('column 1', 'column 2', 'column 3');
                xlabel('Component 1');ylabel('Component 2');zlabel('Component 3');grid on;
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
               %imshow(uint8(frames_pristine{i}));
            end 
        case 7
            % 1 graphic graphic pristine video and distored videos 2D in space
            % of the space 3D
            figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
            for i=1:size(y,2)
                pause(0.005);

                %PLOT 1
                subplot(2,2,1);
                plot3(y{i}(1:DN{i}(1),1),y{i}(1:DN{i}(1),2),y{i}(1:DN{i}(1),3),'ob',...
                y{i}(DN{i}(1)+1:sum(DN{i}),1),y{i}(DN{i}(1)+1:sum(DN{i}),2),y{i}(DN{i}(1)+1:sum(DN{i}),3),'.r');
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]); zlim([xyn(3)-1 xyx(3)+1]);
                legend('Pristine Video', 'Distored video'); grid on;
                xlabel('Component 1');ylabel('Component 2');zlabel('Component 3');
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
                hold on; 

                %PLOT 2
                subplot(2,2,2);
                plot(y{i}(1:DN{i}(1),1),y{i}(1:DN{i}(1),2), 'ob',... %Pristine Video
                     y{i}(DN{i}(1)+1:DN{i}(1)+DN{i}(2),1),... %gaussian
                          y{i}(DN{i}(1)+1:DN{i}(1)+DN{i}(2),2), '.r',... 
                     y{i}(DN{i}(1)+DN{i}(2)+1:DN{i}(1)+DN{i}(2)+DN{i}(3),1),... %MPEG-4
                          y{i}(DN{i}(1)+DN{i}(2)+1:DN{i}(1)+DN{i}(2)+DN{i}(3),2), '.g',... 
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+1:DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4),1),...%blurr
                          y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+1:DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4),2), '.y',...  
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+1:... %salt & pepper
                          DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5),1),...
                          y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+1:...
                          DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5),2), '.c',...
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5)+1:sum(DN{i}),1),... %uneven illumination
                          y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5)+1:sum(DN{i}),2), '.m'); 
                hold on; 
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]);
                %legend('Pristine', 'gaussian', 'MPEG-4',...
                %      'blurr', 'salt & pepper', 'uneven illumination');
                xlabel('Component 1');ylabel('Component 2');grid on;
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);

                %PLOT 3
                subplot(2,2,3);
                plot(y{i}(1:DN{i}(1),1),y{i}(1:DN{i}(1),3), 'ob',... %Pristine Video
                     y{i}(DN{i}(1)+1:DN{i}(1)+DN{i}(2),1),... %gaussian
                          y{i}(DN{i}(1)+1:DN{i}(1)+DN{i}(2),3), '.r',... 
                     y{i}(DN{i}(1)+DN{i}(2)+1:DN{i}(1)+DN{i}(2)+DN{i}(3),1),... %MPEG-4
                          y{i}(DN{i}(1)+DN{i}(2)+1:DN{i}(1)+DN{i}(2)+DN{i}(3),3), '.g',... 
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+1:DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4),1),...%blurr
                          y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+1:DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4),3), '.y',...  
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+1:... %salt & pepper
                          DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5),1),...
                          y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+1:...
                          DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5),3), '.c',...
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5)+1:sum(DN{i}),1),... %uneven illumination
                          y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5)+1:sum(DN{i}),3), '.m'); 
                hold on; 
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]);
                %legend('Pristine', 'gaussian', 'MPEG-4',...
                %      'blurr', 'salt & pepper', 'uneven illumination');
                xlabel('Component 1');ylabel('Component 3');grid on;
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);

                %PLOT 4
                subplot(2,2,4);
                plot(y{i}(1:DN{i}(1),2),y{i}(1:DN{i}(1),3), 'ob',... %Pristine Video
                     y{i}(DN{i}(1)+1:DN{i}(1)+DN{i}(2),2),... %gaussian
                          y{i}(DN{i}(1)+1:DN{i}(1)+DN{i}(2),3), '.r',... 
                     y{i}(DN{i}(1)+DN{i}(2)+1:DN{i}(1)+DN{i}(2)+DN{i}(3),2),... %MPEG-4
                          y{i}(DN{i}(1)+DN{i}(2)+1:DN{i}(1)+DN{i}(2)+DN{i}(3),3), '.g',... 
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+1:DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4),2),...%blurr
                          y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+1:DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4),3), '.y',...  
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+1:... %salt & pepper
                          DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5),2),...
                          y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+1:...
                          DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5),3), '.c',...
                     y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5)+1:sum(DN{i}),2),... %uneven illumination
                          y{i}(DN{i}(1)+DN{i}(2)+DN{i}(3)+DN{i}(4)+DN{i}(5)+1:sum(DN{i}),3), '.m'); 
                hold on; 
                xlim([xyn(1)-1 xyx(1)+1]); ylim([xyn(2)-1 xyx(2)+1]);
                %legend('Pristine', 'gaussian', 'MPEG-4',...
                %      'blurr', 'salt & pepper', 'uneven illumination');
                xlabel('Component 2');ylabel('Component 3');grid on;
                title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);          
            end 
    end


end