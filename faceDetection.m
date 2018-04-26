function [hasFace,scatteredBBStructs,unifiedBBStructs]= faceDetection(im)
%FACEDETECTION �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
m=size(im,1);
n=size(im,2);
narrowerSide=min(m,n);
red=im(:,:,1);
green=im(:,:,2);
blue=im(:,:,3);
borderRatio=1/16;%border�Ŀ�ȣ��߶ȣ�ռ����ͼ��Ŀ�ȣ��߶ȣ��ı���
rowBorder=floor(borderRatio*m);%rowBorder���ڵ����ز��ᱻ����
colBorder=floor(borderRatio*n);
ratioMin=1/5;%ratioMin������deltaWidth����Сֵ
ratioMax=1-2*borderRatio;%��ֵ�Ǹ���scanImage��������ļ�������border�ı����ó��ġ�����border�ı���Ϊ1/10����ôratioMax��Ϊ��1-2*(1/10)).
% deltaHeightMin=floor(ratioMin*m);
deltaWidthMin=floor(ratioMin*narrowerSide);
% deltaHeightMax=floor(ratioMax*m);
deltaWidthMax=floor(ratioMax*narrowerSide);
bbStructs={};


deltaWidth=deltaWidthMin;%�øñ�������forѭ���Ľ��ж��ı䣬��ʼֵ��ΪdeltaWidthMin
deltaHeight=deltaWidth;%��deltaHeight�ĳ�ʼֵ����deltaWidth��

deltaWidthStep=floor(0.2*(deltaWidthMax-deltaWidthMin));%deltaWidth�Ĳ��������ò���Ϊ1��ʹѭ�����кܳ�ʱ�䣩
while deltaWidth<=deltaWidthMax
    rowStep=floor(0.1*deltaWidth);%�еĲ������ò���Ϊ1��ʹ�������кܳ�ʱ�䣬�������forѭ���Ĳ���
    colStep=floor(0.1*deltaHeight);%�еĲ���
    rowStop=m-rowBorder-deltaHeight;
    colStop=n-colBorder-deltaWidth;
    for row=rowBorder:rowStep:rowStop
        for col=colBorder:colStep:colStop
            rowRange=uint8(row:row+deltaHeight-1);%�����ȥ1
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
                %����ж�Ϊ�������ͼ�¼��targetBW��Ӧ��Boungding Box
                bbStruct.x=col-0.5;
                bbStruct.y=row-0.5;
                bbStruct.w=size(targetBW,2);
                bbStruct.h=size(targetBW,1);
                bbStructs{length(bbStructs)+1}=bbStruct;

            end
        end
    end
    %˵��ɨ��һ���ˣ�����deltaWidth
    if row>=rowStop-rowStep&&col>=colStop-colStep          
%         disp(deltaHeight);
%         disp(deltaWidth);
%         disp('have scanned the whole image once');
        deltaWidth=deltaWidth+deltaWidthStep;
        deltaHeight=deltaWidth;%although this line was wrote before,it should be wrote here.Beacause
                                %it seems there is not Reference in Matlab.
    end
end
%�����ľ�������ľ��ηŵ�һ�ѣ�ÿһ����ζ��һ������
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
remainingCenters=centers;%�Ȱ�centers Cell��ֵ��remainingCenters
remainingBBs=bbStructs;
while ~isempty(remainingCenters)
    copyRC=remainingCenters;%"RC" means "remaining centers"
    copyRBB=remainingBBs;%"RBB" means "remaining bounding boxes"
    remainingCenters(:)=[];%����ɾ��������Ԫ�أ�Ϊ�˸���remainingCenters������remainingCenters��length����ı�
    remainingBBs(:)=[];%remainingBBs���remainingCentersͬ���仯
    firstCenter=copyRC{1};%����һ�����ģ�Ȼ�����ж�����������������ĵľ���
    firstBB=copyRBB{1};
    belongsToOne{1}=firstBB;
    for k=2:length(copyRC)
        currentCenter=copyRC{k};
        currentX=currentCenter.x;
        currentY=currentCenter.y;
        currentBB=copyRBB{k};
        if (currentX-firstCenter.x)^2+(currentY-firstCenter.y)^2<(m*n/10)%��������������飬Ч��������
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

