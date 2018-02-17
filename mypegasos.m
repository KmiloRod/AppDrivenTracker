function w=mypegasos(data,labs,w,to1,to2,lpeg,nrep)
slpeg=sqrt(lpeg);
indx=1:size(data,1);
indx=repmat(indx,1,nrep);
iic1=to1;
iic2=to2;
for ii=indx
    if labs(ii)==1
        eta=1/(lpeg*iic1);
        iic1=iic1+1;
    else
        eta=1/(lpeg*iic2);
        iic2=iic2+1;
    end
    fx=w*data(ii,:)';
    if labs(ii)*fx < 1
        w=(1-eta*lpeg)*w+eta*labs(ii)*data(ii,:);
    elseif labs(ii)*fx >= 1
        w=(1-eta*lpeg)*w;
    end
    w=min([1 (1/(slpeg*norm(w,2)))])*w;
end