function [hasFace,scatteredBBStructs,unifiedBBStructs]= faceDetection(im)
%FACEDETECTION 此处显示有关此函数的摘要
%   此处显示详细说明
m=size(im,1);
n=size(im,2);
narrowerSide=min(m,n);
red=im(:,:,1);
green=im(:,:,2);
blue=im(:,:,3);
borderRatio=1/16;%border的宽度（高度）占整幅图像的宽度（高度）的比例
rowBorder=floor(borderRatio*m);%rowBorder以内的像素不会被遍历
colBorder=floor(borderRatio*n);
ratioMin=1/5;%ratioMin决定着deltaWidth的最小值
ratioMax=1-2*borderRatio;%该值是根据scanImage函数里面的计算两个border的比例得出的。比如border的比例为1/10，那么ratioMax就为（1-2*(1/10)).
% deltaHeightMin=floor(ratioMin*m);
deltaWidthMin=floor(ratioMin*narrowerSide);
% deltaHeightMax=floor(ratioMax*m);
deltaWidthMax=floor(ratioMax*narrowerSide);
bbStructs={};


deltaWidth=deltaWidthMin;%让该变量随着for循环的进行而改变，初始值设为deltaWidthMin
deltaHeight=deltaWidth;%让deltaHeight的初始值等于deltaWidth，

deltaWidthStep=floor(0.2*(deltaWidthMax-deltaWidthMin));%deltaWidth的步进，（让步进为1会使循环运行很长时间）
while deltaWidth<=deltaWidthMax
    rowStep=floor(0.1*deltaWidth);%行的步进（让步进为1会使程序运行很长时间，必须改善for循环的步进
    colStep=floor(0.1*deltaHeight);%列的步进
    rowStop=m-rowBorder-deltaHeight;
    colStop=n-colBorder-deltaWidth;
    for row=rowBorder:rowStep:rowStop
        for col=colBorder:colStep:colStop
            rowRange=uint8(row:row+deltaHeight-1);%必须减去1
            colRange=uint8(col:col+deltaWidth-1);
            targetRed=red(rowRange,colRange);
            targetGreen=green(rowRange,colRange);
            targetBlue=blue(rowRange,colRange);
            target=cat(3,targetRed,targetGreen,targetBlue);
            targetGray=rgb2gray(target);
            threshold=graythresh(targetGray);
            targetBW=im2bw(target,threshold);
            targetBW=~targetBW;
            isFace=analyzeBW(targetBW);
            if isFace==1
                %如果判断为人脸，就记录下targetBW对应的Boungding Box
                bbStruct.x=col-0.5;
                bbStruct.y=row-0.5;
                bbStruct.w=size(targetBW,2);
                bbStruct.h=size(targetBW,1);
                bbStructs{length(bbStructs)+1}=bbStruct;

            end
        end
    end
    %说明扫描一遍了，更改deltaWidth
    if row>=rowStop-rowStep&&col>=colStop-colStep          
%         disp(deltaHeight);
%         disp(deltaWidth);
%         disp('have scanned the whole image once');
        deltaWidth=deltaWidth+deltaWidthStep;
        deltaHeight=deltaWidth;%although this line was wrote before,it should be wrote here.Beacause
                                %it seems there is not Reference in Matlab.
    end
end
%把中心距离相近的矩形放到一堆，每一堆意味着一张人脸
% image(im);
% hold on;
% rectangle('Position',[colBorder,rowBorder,n-2*colBorder,m-2*rowBorder],'EdgeColor','r');
centers={};
if ~isempty(bbStructs)
    hasFace=1;
    scatteredBBStructs=bbStructs;
    for k=1:length(bbStructs)
        bbStruct=bbStructs{k};%this variable 'bbStruct' has existed in the last for loop,but this doesn not make a bad effect.
        bbCell=struct2cell(bbStruct);
        bbMat=cell2mat(bbCell);
        %rectangle('Position',bbMat,'EdgeColor','g');
        center.x=(bbStruct.x+bbStruct.x+bbStruct.w)/2;
        center.y=(bbStruct.y+bbStruct.y+bbStruct.h)/2;
        centers{length(centers)+1}=center;
    end
else
    hasFace=0;
    scatteredBBStructs={};
end
belongsToOne={};
huizong={};
remainingCenters=centers;%先把centers Cell赋值给remainingCenters
remainingBBs=bbStructs;
while ~isempty(remainingCenters)
    copyRC=remainingCenters;%"RC" means "remaining centers"
    copyRBB=remainingBBs;%"RBB" means "remaining bounding boxes"
    remainingCenters(:)=[];%立刻删除其所有元素，为了更新remainingCenters，否则，remainingCenters的length不会改变
    remainingBBs(:)=[];%remainingBBs会跟remainingCenters同步变化
    firstCenter=copyRC{1};%先找一个中心，然后再判断其他中心与这个中心的距离
    firstBB=copyRBB{1};
    belongsToOne{1}=firstBB;
    for k=2:length(copyRC)
        currentCenter=copyRC{k};
        currentX=currentCenter.x;
        currentY=currentCenter.y;
        currentBB=copyRBB{k};
        if (currentX-firstCenter.x)^2+(currentY-firstCenter.y)^2<(m*n/10)%这个比例经过试验，效果还不错
            %belongsToOne{length(belongsToOne)+1}=currentCenter;
            belongsToOne{length(belongsToOne)+1}=currentBB;
        else
            remainingCenters{length(remainingCenters)+1}=currentCenter;
            remainingBBs{length(remainingBBs)+1}=currentBB;
        end
    end
    huizong{length(huizong)+1}=belongsToOne;
    belongsToOne(:)=[];
end
%start to get the biggest bounding box including the same face
leftXCell={};
rightXCell={};
topYCell={};
bottomYCell={};
biggestBBs={};%this variable is used to save every face's biggest bounding box.
if ~isempty(huizong)
    for h=1:length(huizong)
        belongsToOne=huizong{h};
        for b=1:length(belongsToOne)
            bb=belongsToOne{b};
            leftX=bb.x;
            rightX=bb.x+bb.w;
            topY=bb.y;
            bottomY=bb.y+bb.h;
            index=length(leftXCell)+1;%the following Cells have the same length at the same time.
            leftXCell{index}=leftX;
            rightXCell{index}=rightX;
            topYCell{index}=topY;
            bottomYCell{index}=bottomY;
        end
        minX=min(cell2mat(leftXCell));
        maxX=max(cell2mat(rightXCell));
        minY=min(cell2mat(topYCell));
        maxY=max(cell2mat(bottomYCell));
        biggestBB.x=minX;
        biggestBB.y=minY;
        biggestBB.w=floor(maxX-minX);
        biggestBB.h=floor(maxY-minY);
        biggestBBs{length(biggestBBs)+1}=biggestBB;
        leftXCell(:)=[];
        rightXCell(:)=[];
        topYCell(:)=[];
        bottomYCell(:)=[];
    end
end
if ~isempty(biggestBBs)
    unifiedBBStructs=biggestBBs;
    %figure;image(im);hold on;
    for k=1:length(biggestBBs)
        biggestBBMat=cell2mat(struct2cell(biggestBBs{k}));
        %rectangle('Position',biggestBBMat,'EdgeColor','b');
    end
else
    unifiedBBStructs={};
end

end

