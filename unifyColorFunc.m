function processedIm= unifyColorFunc(im,times)
%UNIFYCOLORFUNC 此处显示有关此函数的摘要
%   此处显示详细说明
m=size(im,1);
n=size(im,2);
red=im(:,:,1);
green=im(:,:,2);
blue=im(:,:,3);
newRed=red;
newGreen=green;
newBlue=blue;
%scan with a square region
ratio=1/20;
regionWidth=floor(ratio*n);
regionHeight=floor(ratio*m);
step=floor(regionWidth/3);
%times=3;
t=0;
while t<times 
    for row=1:step:m-regionHeight
        for col=1:step:n-regionWidth;
            rowRange=row:row+regionHeight-1;
            colRange=col:col+regionWidth-1;
            %         region=im(rowRange,colRange);%im is 3-D,so can't write so.
            regionRed=red(rowRange,colRange);
            regionGreen=green(rowRange,colRange);
            regionBlue=blue(rowRange,colRange);
            region=cat(3,regionRed,regionGreen,regionBlue);
            regionGray=rgb2gray(region);
            threshold=graythresh(regionGray);
            regionBW=im2bw(regionGray,threshold);
            %targetIndex=find(regionBW==1);
            [targetRowVec,targetColVec]=find(regionBW==1);
            originalRowVec=targetRowVec+row-1;%it is not hard to understand
            originalColVec=targetColVec+col-1;
            targetIndexInOrigin=m*(originalColVec-1)+originalRowVec;%get the original index
            howMany=sum(regionBW(:)==1);
            %         red(targetIndexInOrigin)=sum(red(targetIndexInOrigin))/howMany;
            %         green(targetIndexInOrigin)=sum(green(targetIndexInOrigin))/howMany;
            %         blue(targetIndexInOrigin)=sum(blue(targetIndexInOrigin))/howMany;
            %下面三行跟上面三行的效果是完全不一样的，上面的会产生“连锁效应”，下面的不会
            newRed(targetIndexInOrigin)=sum(red(targetIndexInOrigin))/howMany;
            newGreen(targetIndexInOrigin)=sum(green(targetIndexInOrigin))/howMany;
            newBlue(targetIndexInOrigin)=sum(blue(targetIndexInOrigin))/howMany;
        end
    end
    t=t+1;
end
%rgb=cat(3,red,green,blue);
processedIm=cat(3,newRed,newGreen,newBlue);

end

