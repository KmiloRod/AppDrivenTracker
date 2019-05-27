% Ing. Carlos Fernando Quiroga 22 / Apr / 2019

%Gaussian, Blur, MPEG4, pristine
distosion = 'pristine';
v=2;
NSS1=1; HOG=0; 
Cs=1;
Display=0;
saveas=1;
PC=0;
Norm=0; NormN=1; NormZ=2;
grafico=2;


[ROC_PH,ROC_AH,AOSH] = Test_ROC_AOS_MVC_NSS_Prueba(distosion,v,HOG,Cs,Display,saveas, PC,Norm);
[ROC_PN,ROC_AN] = Test_ROC_AOS_MVC_NSS_Prueba(distosion,v,NSS1,Cs,Display,saveas, PC,Norm);

[ROC_PHN,ROC_AHN,AOSHN] = Test_ROC_AOS_MVC_NSS_Prueba(distosion,v,HOG,Cs,Display,saveas, PC,NormN);
[ROC_PNN,ROC_ANN] = Test_ROC_AOS_MVC_NSS_Prueba(distosion,v,NSS1,Cs,Display,saveas, PC,NormN);

[ROC_PHZ,ROC_AHZ,AOSHZ] = Test_ROC_AOS_MVC_NSS_Prueba(distosion,v,HOG,Cs,Display,saveas, PC,NormZ);
[ROC_PNZ,ROC_ANZ] = Test_ROC_AOS_MVC_NSS_Prueba(distosion,v,NSS1,Cs,Display,saveas, PC,NormZ);


color_arrayH = {'b-o'; 'r-o'; 'm-o'};
color_arrayN = {'b-*'; 'r-*'; 'm-*'};

color_arrayHN = {'b--o'; 'r--o'; 'm--o'};
color_arrayNN = {'b--*'; 'r--*'; 'm--*'};

color_arrayHZ = {'b-.o'; 'r-.o'; 'm-.o'};
color_arrayNZ = {'b-.*'; 'r-.*'; 'm-.*'};

switch distosion
    case 'MPEG4'
        Q = [60 30 0]; % MPEG Compression
    case 'Gaussian'
        Q = [0.01, 0.05, 0.1]; % AWGN
    case 'Blur'
        Q = [5, 10, 15]; % Blur
end

save(strcat('./SVM_new_results/','Video_',num2str(v),'_Distorsion_',distosion));

%switch grafico
 %   case 0  Comportamiento de Succes Plots con características HOG y HOG_NSS
        figure;
        plot(AOSH,ROC_PH(1,:),'k-o','DisplayName','Pristine HOG'); hold on,
        plot(AOSH,ROC_PN(1,:),'k-*','DisplayName','Pristine HOG-NSS'); hold on,
        for o = 1:length(Q)
            plot(AOSH,ROC_AH(o,:),color_arrayH{o},'DisplayName',num2str(Q(o))); hold on;
            plot(AOSH,ROC_AN(o,:),color_arrayN{o},'DisplayName',num2str(Q(o))); hold on;
        end        
        title(sprintf('Video %u, %s distortion analysis with HOG and NSS',v,distosion));
        xlabel('Overlap threshold');
        ylabel('Success rate');
        legend('show','Location','southwest');
        grid on;
        hold off;  
        
 %   case 1  Comportamiento de Succes Plots con características HOG y HOG_NSS Normalizados (0-1) lineal 
        figure;
        plot(AOSH,ROC_PHN(1,:),'k-o','DisplayName','Pristine HOG'); hold on,
        plot(AOSH,ROC_PNN(1,:),'k-*','DisplayName','Pristine HOG-NSS'); hold on,
        for o = 1:length(Q)
            plot(AOSH,ROC_AHN(o,:),color_arrayHN{o},'DisplayName',num2str(Q(o))); hold on;
            plot(AOSH,ROC_ANN(o,:),color_arrayNN{o},'DisplayName',num2str(Q(o))); hold on;
        end        
        title(sprintf('Video %u, %s distortion analysis with HOG and NSS Normalized',v,distosion));
        xlabel('Overlap threshold');
        ylabel('Success rate');
        legend('show','Location','southwest');
        grid on;
        hold off;  
 %   case 2 Comportamiento de Succes Plots con características HOG y HOG_NSS Normalizados ZScore 
        figure;
        plot(AOSH,ROC_PHZ(1,:),'k-o','DisplayName','Pristine HOG'); hold on,
        plot(AOSH,ROC_PNZ(1,:),'k-*','DisplayName','Pristine HOG-NSS'); hold on,
        for o = 1:length(Q)
            plot(AOSH,ROC_AHZ(o,:),color_arrayHZ{o},'DisplayName',num2str(Q(o))); hold on;
            plot(AOSH,ROC_ANZ(o,:),color_arrayNZ{o},'DisplayName',num2str(Q(o))); hold on;
        end        
        title(sprintf('Video %u, %s distortion analysis with HOG and NSS Zscore',v,distosion));
        xlabel('Overlap threshold');
        ylabel('Success rate');
        legend('show','Location','southwest');
        grid on;
        hold off;  
        
 %   case 3   Comportamiento de Succes Plots con características HOG,
 %   HOG_NSS y HOG , HOG_NSS Normalizado Lineal y Zscore
        figure;
        plot(AOSH,ROC_PH(1,:),'k-o','DisplayName','Pristine HOG'); hold on,
        plot(AOSH,ROC_PN(1,:),'k-*','DisplayName','Pristine HOG-NSS'); hold on,
        plot(AOSH,ROC_PHN(1,:),'k--o','DisplayName','Pristine HOG Norm'); hold on,
        plot(AOSH,ROC_PNN(1,:),'k--*','DisplayName','Pristine HOG-NSS Norm'); hold on,
        plot(AOSH,ROC_PHZ(1,:),'k-.o','DisplayName','Pristine HOG Zscore'); hold on,
        plot(AOSH,ROC_PNZ(1,:),'k-.*','DisplayName','Pristine HOG-NSS Zscore'); hold on,
        for o = 1:length(Q)
            plot(AOSH,ROC_AH(o,:),color_arrayH{o},'DisplayName',num2str(Q(o))); hold on;
            plot(AOSH,ROC_AN(o,:),color_arrayN{o},'DisplayName',num2str(Q(o))); hold on;
            plot(AOSH,ROC_AHN(o,:),color_arrayHN{o},'DisplayName',num2str(Q(o))); hold on;
            plot(AOSH,ROC_ANN(o,:),color_arrayNN{o},'DisplayName',num2str(Q(o))); hold on;
            plot(AOSH,ROC_AHZ(o,:),color_arrayHZ{o},'DisplayName',num2str(Q(o))); hold on;
            plot(AOSH,ROC_ANZ(o,:),color_arrayNZ{o},'DisplayName',num2str(Q(o))); hold on;
        end

        title(sprintf('Video %u, %s  Linear Normalize and Zscore analysis with HOG and NSS',v,distosion));
        xlabel('Overlap threshold');
        ylabel('Success rate');
        legend('show','Location','southwest');
        grid on;
        hold off;
  %  case 4 Comportamiento de La variación Succes Plots respecto a las 
  %  caracteristicas HOG_NSS, HOG Normalizado , HOG_NSS Normalizado lineal y Zscore  
       %------------------------ Efficiency Pristine Video ----------------
        EFF_PN=(ROC_PN(1,:)-ROC_PH(1,:))*100;
        EFF_PHN=(ROC_PHN(1,:)-ROC_PH(1,:))*100;
        EFF_PHNN=(ROC_PNN(1,:)-ROC_PH(1,:))*100;
        EFF_PHZ=(ROC_PHZ(1,:)-ROC_PH(1,:))*100;
        EFF_PHNZ=(ROC_PNZ(1,:)-ROC_PH(1,:))*100;
        
        
        figure;
        subplot(2,2,1);
        plot(AOSH,EFF_PN(1,:),'k-*','DisplayName','HOG-NSS'); hold on,
        plot(AOSH,EFF_PHN(1,:),'k--o','DisplayName','HOG Norm'); hold on,
        plot(AOSH,EFF_PHNN(1,:),'k--*','DisplayName','HOG-NSS Norm'); hold on,
        plot(AOSH,EFF_PHZ(1,:),'k-.o','DisplayName','HOG Zscore'); hold on,
        plot(AOSH,EFF_PHNZ(1,:),'k-.*','DisplayName','HOG-NSS Zscore'); hold off,
        title(sprintf('Efficiency Pristine Video %u Reference: HOG',v));
        xlabel('Overlap threshold');
        ylabel('Efficiency Success rate');
        legend('show','Location','southwest');
        grid on;
        %---------------- Efficiency Distored -----------------------------
        
        for i=1:length(Q)
            EFF_DN=(ROC_AN(i,:)-ROC_AH(i,:))*100;
            EFF_DHN=(ROC_AHN(i,:)-ROC_AH(i,:))*100;
            EFF_DHNN=(ROC_ANN(i,:)-ROC_AH(i,:))*100;
            EFF_DHZ=(ROC_AHZ(i,:)-ROC_AH(i,:))*100;
            EFF_DHNZ=(ROC_ANZ(i,:)-ROC_AH(i,:))*100;

            subplot(2,2,i+1);
            plot(AOSH,EFF_DN(1,:),color_arrayN{i},'DisplayName','HOG-NSS'); hold on,
            plot(AOSH,EFF_DHN(1,:),color_arrayHN{i},'DisplayName','HOG Norm'); hold on,
            plot(AOSH,EFF_DHNN(1,:),color_arrayNN{i},'DisplayName','HOG-NSS Norm'); hold on,
            plot(AOSH,EFF_DHZ(1,:),color_arrayHZ{i},'DisplayName','HOG Zscore'); hold on,
            plot(AOSH,EFF_DHNZ(1,:),color_arrayNZ{i},'DisplayName','HOG-NSS Zscore'); hold off,
            title(sprintf('Efficiency Video Distored %u, Reference: HOG',Q(i)));
            xlabel('Overlap threshold');
            ylabel('Efficiency Success rate');
            legend('show','Location','southwest');
            grid on;
        end
%end