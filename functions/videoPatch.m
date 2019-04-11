function patchFrame = videoPatch(gtP,frames)
%Funcion que calcula un tipo de dato cell array, que contiene por cada
%frame la ubicacion del parche principal y los ocho parches circundantes
%los cuales son usados para el analisis de la extraccion de las
%caracteristicas hogs y en analisis de componentes principales. 
%gtP es la matriz de [4 x numOfFrames] donde las columnas de la matriz son 
% [x y desplazamiento(x) desplazamiento(y)] y numOfFrames es la cantidad de
% frames del video. 

    height = size(frames,1);
    width = size(frames,2);

    
    for i = 1:size(gtP,1)
        patchFrame{i}(1,:) = [gtP(i,1)    gtP(i,2)    gtP(i,3)    gtP(i,4)];
        patchFrame{i}(2,:) = [gtP(i,1)    gtP(i,2)-2  gtP(i,3)    gtP(i,4)];
        patchFrame{i}(3,:) = [gtP(i,1)    gtP(i,2)+2  gtP(i,3)    gtP(i,4)];
        patchFrame{i}(4,:) = [gtP(i,1)-2  gtP(i,2)    gtP(i,3)    gtP(i,4)];
        patchFrame{i}(5,:) = [gtP(i,1)+2  gtP(i,2)    gtP(i,3)    gtP(i,4)];
        patchFrame{i}(6,:) = [gtP(i,1)-2  gtP(i,2)-2  gtP(i,3)    gtP(i,4)];
        patchFrame{i}(7,:) = [gtP(i,1)-2  gtP(i,2)+2  gtP(i,3)    gtP(i,4)];
        patchFrame{i}(8,:) = [gtP(i,1)+2  gtP(i,2)-2  gtP(i,3)    gtP(i,4)];
        patchFrame{i}(9,:) = [gtP(i,1)+2  gtP(i,2)+2  gtP(i,3)    gtP(i,4)];
    end
    
    for i = 1:size(gtP,1)
        fila=[];
        for j = 1:size(patchFrame{i},1)
            
            w = patchFrame{i}(j,1)+patchFrame{i}(j,3);
            h = patchFrame{i}(j,2)+patchFrame{i}(j,4);
            x = patchFrame{i}(j,1);
            y = patchFrame{i}(j,2);
            
            if w>width || h>height || x<=0 || y<=0
               fila = cat(1,fila,j); 
            end
            
        end
        
        patchFrame{i}(fila,:)=[];
        
    end 

end