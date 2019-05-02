% Ing. Carlos Fernando Quiroga 10 / Apr / 2019
%Analisis de componentes principales PCA
%La solucion optima se obtiene para un dataset con promedio cero.

%Nota para correr este programa PCA hay que correr primero el programa de
%pruebasHOG ya que PCA utiliza las variables que se generan.

%Ver en numero adecuado de dimensión en PCA, observalos en el desempeño del 
%tracker ejemplo pristino sin adición de la nss, ejemplo pristino con nss,
% con distorsiones blur, AWGN, MPEG-4.
% Probar el tracker con esa metrica.
% Comportamiento de la curva de succes plot.
% Mirar los videos distorsionados autenticamente.

% [hog2, Pvar]= PCA_(hog,10);
[y, Pvar602]= PCA_(nss,3);


% for i=1:size(hog,2)
%      y{i}=[hog2{i},nss1{i}];
% end

% [y, Pvar]= PCA_(hognss,3);

%Combinaciones con buenos resultados 2hog 1nss


%% Graphics
grafico=6;

graphics(y, distorsion,Q, k, grafico)

