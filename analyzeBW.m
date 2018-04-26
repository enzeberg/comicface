function boolean= analyzeBW(targetBW)
%ANALYZEBW 此处显示有关此函数的摘要
%   此处显示详细说明
height=size(targetBW,1);
width=size(targetBW,2);
area=height*width;
L=logical(targetBW);
ct=regionprops(L,'centroid');% ct means centroid.
ctCell=struct2cell(ct);
bb=regionprops(L,'BoundingBox');% bb means BoundingBox
bbCell=struct2cell(bb);
minPixels=1/75*area;%符合眼睛和嘴的连通域中的亮像素的个数的下限，这两个界限需不断尝试
maxPixels=1/10*area;%符合眼睛和嘴的连通域中的亮像素的个数的下限
ctMats={};
bbMats={};
parts={};%该变量用来判断是否存在left，right，down
for k=1:size(ctCell,2)
    singleCTMat=cell2mat(ctCell(k));
    singleBBMat=cell2mat(bbCell(k));
    ccRow=singleBBMat(2)+0.5;%cc means Connected Component(连通域)
    ccCol=singleBBMat(1)+0.5;
    ccHeight=singleBBMat(4);
    ccWidth=singleBBMat(3);
    cc=targetBW(ccRow:ccRow+ccHeight-1,ccCol:ccCol+ccWidth-1);
    numOfOneInCC=sum(cc(:)==1);
    if numOfOneInCC<minPixels||numOfOneInCC>maxPixels
        continue;
    else
        if ccWidth/ccHeight>1.2%眼睛和嘴所对应的连通域的宽都会大于高
            ctMats{length(ctMats)+1}=singleCTMat;
            bbMats{length(bbMats)+1}=singleBBMat;
        end
    end
    
    

end
if length(ctMats)<3%||length(ctMats)>4
%if ~(length(ctMats)==4)
    boolean=0;%该算法只能识别含有嘴和两只眼睛的脸（至少应对应3个连通域，因为可能还会获取到眉毛和鼻子），若找到的连通域小于3，则判断为不是人脸
else%若找到的连通域>=3,则还需判断它们的位置关系
    higherX=0;%abuse a higher X.
    lowerX=width;%abuse a lower X.必须让lowerX初始值设得较大，才能在循环里满足条件地逐级递减，这里设为targetBW的宽度
    higherY=0;%abuse a higher Y.
    for k=1:length(ctMats)
        currentCTMat=ctMats{k};
        cctx=currentCTMat(1);%current centroid's X.
        ccty=currentCTMat(2);%current centroid's Y.
%         nextCTMat=ctMats{k+1};
% 
%         nctx=nextCTMat(1);%next centroid's X.
%         ncty=nextCTMat(2);%next centroid's Y.
        if ccty>higherY  %Y轴是向下的
            down=currentCTMat;
            higherY=ccty;
        end
        
        if cctx>higherX
            right=currentCTMat;
            higherX=cctx;
        end
        
        if cctx<lowerX
            left=currentCTMat;
            lowerX=cctx;
        end
        parts{1}=left;%或者说，parts用来判断这个else里面的for循环是否执行了
        parts{2}=right;
        parts{3}=down;
    
    end
end
%假设left对应左眼，right对应右眼，down对应嘴
%存在某一个质心既是left（或right）又是down的情况（情况A）.
if ~isempty(parts)%只有当parts不是空的时候，才存在left，right，down。若没有这行判断，则会出现以上三者未定义的警告.
    eyesDx=right(1)-left(1);
    %disp(eyesDx);
    eyesDy=abs(right(2)-left(2));
    %disp(eyesDy);
    leftAndDownDy=down(2)-left(2); %Y轴是向下的！！！
    rightAndDownDy=down(2)-right(2);
    average=1/2*(leftAndDownDy+rightAndDownDy);
    %disp(average);
    if abs(eyesDx-width)<0.5*width  %该行是为了避免圈出虽然包含人脸但是人脸并不处于框框中间的情况
        if abs(average-height)<0.5*height  %该行是为了避免圈出虽然包含人脸但是人脸并不处于框框中间的情况
            if down(1)>left(1)&&down(1)<right(1)%首先，down必须在left和right中间，避免了情况A.
                if eyesDx/eyesDy>1%其次，两眼间的水平距离必须大于垂直距离
                    if average/eyesDx>0.5&&average/eyesDx<1.5%最后，嘴到两眼的垂直距离的平均值跟两眼间的距离不能相差太大
                        boolean=1;
                    else
                        boolean=0;
                    end
                else
                    boolean=0;
                end
            else
                boolean=0;
            end
        else
            boolean=0;
        end
    else
        boolean=0;
    end
end
end



% imshow(targetBW);
% hold on;
% plot(down(1),down(2),'r+');
% plot(left(1),left(2),'r+');
% plot(right(1),right(2),'r+');

%whos ctMats;
%一下代码供测试识别眼睛和嘴用。
%if ~isempty(parts)
%     figure;
%     imshow(targetBW);
%     hold on;
%     for k=1:length(ctMats)
%         currentCTMat=ctMats{k};
%         currentBBMat=bbMats{k};
%         plot(currentCTMat(1),currentCTMat(2),'b+');
%         rectangle('Position',currentBBMat,'EdgeColor','g');
%     end
%     plot(down(1),down(2),'r*');
%     plot(left(1),left(2),'r+');
%     plot(right(1),right(2),'r+');
%end
