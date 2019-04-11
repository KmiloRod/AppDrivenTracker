% Ing. Carlos Fernando Quiroga 10 / Apr / 2019
%Analisis de componentes principales PCA
%La solucion optima se obtiene para un dataset con promedio cero.

%Nota para correr este programa PCA hay que correr primero el programa de
%pruebasHOG ya que PCA utiliza las variables que se generan.

%--------------------------------------------------------------------------
% CLASES: 
% 1 Imagenes pristinas
% 2 Distorsion MPEG-4
% 3 Distorsion gaussian
% 4 Distorsion blur
% 5 Distorsion salt & pepper
% 6 Distorsion uneven illumination
%--------------------------------------------------------------------------

%1. Load Data Set

%Donde hogS es la matriz de caracteristicas para las imagenes pristinas y distorsionadas
%dadas por la fucion extraccionHogs
%[x,t] = extraccionHogs('video'); %Etiquetado de clases para cada ejemplo

for i = 1:size(hog,2)
    [d(i),N(i)]=size(hog{i}); %N Numero caracteristicas Data-Set x frame, d ejemplos x frame
end

M=size(distorsion,2)+1; %Numero de clases sin difereciar el nivel de distorsion(numero de distorsiones + imagen pristina)

q(1)=1;
for i=1:size(Q,2)
    q(i+1)=size(Q{i},2);
end 

sumf=2;
for i=1:size(hog,2)
    i
    % 1. Load Data Set-----------------------------------------------------
    for j=1:M
        DN{i}(j)= d(i)*q(j)/sum(q); % Data Number for class
    end
    % 2. Normalize features -----------------------------------------------
    hogN{i}=mapstd(hog{i}); 
    
    % 3. Principal Component Analysis  ------------------------------------
    R{i}=cov(hogN{i}); % Autocorrelation Matrix (Covariance Matrix)
    [V{i},D{i}] = eig(R{i}); % Eigendecomposition
    
    % Sort the eigenvectors and eigenvalues
    lamda{i}=diag(D{i});
    [eigenval{i},ind{i}]=sort(lamda{i}','descend');
    eigenvec{i}=V{i}(:,ind{i});
    
    % 4. Selección de l eigenvectors (l<d)---------------------------------
    A{i}=eigenvec{i}(:,1:sumf);
    % Porcentaje Varianza Retenida
    Pvar(i)=sum(eigenval{i}(1:sumf))*100/sum(eigenval{i});
    
    % 5. Data set Transformed----------------------------------------------
    y{i}=(A{i}'*hogN{i}')';
    xymin(i,:)=min(y{i});
    xymax(i,:)=max(y{i});
    
end

num_frame = numFrame(y,k);

xymin=min(xymin);
xymax=max(xymax);

tamano=get(0,'ScreenSize');
figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);

%% Graphics
% 1 graphic pristine video and distored videos
for i=1:size(hog,2)
    pause(0.005);
    
    subplot(1,2,1);
    plot(y{i}(1:DN{i}(1),1),y{i}(1:DN{i}(1),2), 'ob',...
         y{i}(DN{i}(1)+1:sum(DN{i}),1),y{i}(DN{i}(1)+1:sum(DN{i}),2), '.r');
    xlim([xymin(1)-1 xymax(1)+1]); ylim([xymin(2)-1 xymax(2)+1]);
    legend('Pristine Video', 'Distored video');
    xlabel('Component 1');ylabel('Component 2');
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
    xlim([xymin(1)-1 xymax(1)+1]); ylim([xymin(2)-1 xymax(2)+1]);
    legend('Pristine', 'gaussian', 'MPEG-4',...
          'blurr', 'salt & pepper', 'uneven illumination');
    xlabel('Component 1');ylabel('Component 2');
    title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
    %imshow(uint8(frames_pristine{i}));
    
    
end 

% 2 graphic only pristine video
% 
% for i=1:size(hog,2)
%     pause(0.005);
%     
%     subplot(1,2,1);
%     plot(y{i}(1:3,1),y{i}(1:3,2), '.b',... %Pristine Video
%          y{i}(4:6,1),y{i}(4:6,2),'.r',...
%          y{i}(7:9,1),y{i}(7:9,2),'.g');
%     xlim([xymin(1)-1 xymax(1)+1]); ylim([xymin(2)-1 xymax(2)+1]);
%     legend('column 1', 'column 2', 'column 3');
%     xlabel('Component 1');ylabel('Component 2');
%     title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
%     hold on; 
%     
%     subplot(1,2,2);
%     plot(y{i}(1:3,1),y{i}(1:3,2),'ob',... %Pristine Video
%          y{i}(4:6,1),y{i}(4:6,2),'or',...
%          y{i}(7:9,1),y{i}(7:9,2),'og'); 
%       
%     xlim([xymin(1)-1 xymax(1)+1]); ylim([xymin(2)-1 xymax(2)+1]);
%     legend('column 1', 'column 2', 'column 3');
%     xlabel('Component 1');ylabel('Component 2');
%     title(['Transformation PCA complet video, Num. frame= ' num2str(num_frame(i))]);
%    %imshow(uint8(frames_pristine{i}));
% end 

