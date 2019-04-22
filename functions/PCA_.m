% Ing. Carlos Fernando Quiroga 22 / Apr / 2019
%Principal component analysis PCA
%The optimal solution is obtained for a dataset with a zero average.

%The PCA function receives as parameters:
%-"X": are the arrays of characteristics in a cell-type vector where each 
% cell of the vector corresponds to a analyzed frame and contains the 
% characteristics of that particular frame.
%-"distortion": indicates which distortions have been applied in the 
% construction of the dataset.
%-"Q": is a cell type arrangement where each cell contains the distortion 
% levels applied for each distortion.
%-"sumf": they are the quantity of main components that you want to obtain.
% The function returns:
%-"Y": It is the matrix with the main components
%-"Pvar": It is a vector that contains the percentage of variance retained 
% by each frame.
%-"xymin" and "xymax": vectors containing the minimum and maximum values of 
% each PCA transformation per frame

%--------------------------------------------------------------------------
% CLASSES: 
% 1 Image Pristine
% 2 Distorsion MPEG-4
% 3 Distorsion gaussian
% 4 Distorsion blur
% 5 Distorsion salt & pepper
% 6 Distorsion uneven illumination
%--------------------------------------------------------------------------

function [Y, Pvar, xymin, xymax]= PCA_(X,distorsion,Q,sumf)

    %1. Load Data Set

    for i = 1:size(X,2)
        [d(i),N(i)]=size(X{i}); %N Numero caracteristicas Data-Set x frame, d ejemplos x frame
    end

    M=size(distorsion,2)+1; %Number of classes without differentiating the level of distortion (number of distortions + pristine image)

    q(1)=1;
    for i=1:size(Q,2)
        q(i+1)=size(Q{i},2);
    end 

    
    for i=1:size(X,2)
        
        % 1. Load Data Set-----------------------------------------------------
        for j=1:M
            DN{i}(j)= d(i)*q(j)/sum(q); % Data Number for class
        end
        % 2. Normalize features -----------------------------------------------
        hogN{i}=mapstd(X{i}); 

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
        Y{i}=(A{i}'*hogN{i}')';
        xymin(i,:)=min(Y{i});
        xymax(i,:)=max(Y{i});

    end

end