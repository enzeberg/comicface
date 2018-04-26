function afterProcessing= linearContrastStretch(im)
%LINEARCONTRASTSTRETCH Summary of this function goes here
%   Detailed explanation goes here
m=size(im,1);n=size(im,2);
red=im(:,:,1);green=im(:,:,2);blue=im(:,:,3);
%将灰度值范围【a1,b1】展宽到【a2,b2】
a1=150;b1=170;a2=120;b2=190;
%k1,k2,k3表示三段线性函数的斜率
k1=a2/a1;
k2=(b2-a2)/(b1-a1);
k3=(255-b2)/(255-b1);
newRed=ones(m,n);newGreen=newRed;newBlue=newRed;
for ii=1:m
    for jj=1:n
        r=red(ii,jj);g=green(ii,jj);b=blue(ii,jj);
        if r<a1
            newRed(ii,jj)=k1*r;
        elseif r>b1
            newRed(ii,jj)=k3*(r-b1)+b2;
        else
            newRed(ii,jj)=k2*(r-a1)+a2;
        end
        if g<a1
            newGreen(ii,jj)=k1*g;
        elseif g>b1
            newGreen(ii,jj)=k3*(g-b1)+b2;
        else
            newGreen(ii,jj)=k2*(g-a1)+a2;
        end
        if b<a1
            newBlue(ii,jj)=k1*b;
        elseif b>b1
            newBlue(ii,jj)=k3*(b-b1)+b2;
        else
            newBlue(ii,jj)=k2*(b-a1)+a2;
        end
    end
end
afterProcessing=cat(3,uint8(newRed),uint8(newGreen),uint8(newBlue));

end

