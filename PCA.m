%Analisis de componentes principales PCA
%La solucion optima se obtiene para un dataset con promedio cero.

%--------------------------------------------------------------------------
% CLASES: 
% 1 Imagenes pristinas
% 2 Distorsion MPEG4
% 3 Distorsion Gaussian
% 4 Distorsion Blur
% 5 Distorsion S & P
% 6 Distorsion uneven illumination
%--------------------------------------------------------------------------

%1. Load Data Set

%Donde hogS es la matriz de caracteristicas para las imagenes pristinas y distorsionadas
%dadas por la fucion extraccionHogs
[x,t] = extraccionHogs('video'); %Etiquetado de clases para cada ejemplo

[d,N]=size(x); % N Numero de datos del Data-Set, d dimension
M=6;  % M Numero de clases, imagenes pristinas y con distorsiones sinteticas

N1=N/M; N2=N/M; N3=N/M; N4=N/M; N5=N/M; N6=N/M; % Data Number for class
Nxclass=[N1 N2 N3 N4 N5 N6];

% 2. Normalize features
x=mapstd(x);

% 3. Principal Component Analysis  

R=cov(x'); % Autocorrelation Matrix (Covariance Matrix)

% Eigendecomposition
[V,D] = eig(R);

% Sort the eigenvectors and eigenvalues
lamda=diag(D);
[eigenval,ind]=sort(lamda','descend');
eigenvec=V(:,ind);

% 4. Selección de l eigenvectors (l<d)
l=2;
A=eigenvec(:,1:l);
% Porcentaje Varianza Retenida
Pvar=sum(eigenval(1:l))*100/sum(eigenval);

% 5. Data set Transformed
y=A'*x;

% 6. Display the data set in transformed space
plot(y(1, 1:N1),y(2, 1:N1), 'or', y(1, N1+1:N1+N2),y(2, N1+1:N1+N2), 'og',...
     y(1, N1+N2+1:N1+N2+N3),y(2, N1+N2+1:N1+N2+N3), 'ob'  )
legend('class1', 'class2', 'class3'); xlabel('y1');ylabel('y2');
title(['Transformation PCA: d=' num2str(d)  '  l=' num2str(l)  ' Pvar=' num2str(Pvar)]);