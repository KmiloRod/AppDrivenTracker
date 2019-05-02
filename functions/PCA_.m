% Ing. Carlos Fernando Quiroga 22 / Apr / 2019
%Principal component analysis PCA
%The optimal solution is obtained for a dataset with a zero average.

%The PCA function receives as parameters:
%-"X": are the arrays of characteristics in a cell-type vector where each 
% cell of the vector corresponds to a analyzed frame and contains the 
% characteristics of that particular frame.
%-"sumf": they are the quantity of main components that you want to obtain.
%
% The function returns:
%-"Y": It is the matrix with the main components
%-"Pvar": It is a vector that contains the percentage of variance retained 
% by each frame.


function [Y, Pvar]= PCA_(X,sumf)

        
    for i=1:size(X,2)
        
        % 1. Load Data Set-----------------------------------------------------

        % 2. Normalize features -----------------------------------------------
        hogN=mapstd(X{i}); 

        % 3. Principal Component Analysis  ------------------------------------
        R=cov(hogN); % Autocorrelation Matrix (Covariance Matrix)
        [V,D] = eig(R); % Eigendecomposition

        % Sort the eigenvectors and eigenvalues
        lamda=diag(D);
        [eigenval,ind]=sort(lamda','descend');
        eigenvec=V(:,ind);

        % 4. Selección de l eigenvectors (l<d)---------------------------------
        A=eigenvec(:,1:sumf);
        % Porcentaje Varianza Retenida
        Pvar(i)=sum(eigenval(1:sumf))*100/sum(eigenval);

        % 5. Data set Transformed----------------------------------------------
        Y{i}=(A'*hogN')';

    end

end