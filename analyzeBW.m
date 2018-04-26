function boolean= analyzeBW(targetBW)
%ANALYZEBW �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
height=size(targetBW,1);
width=size(targetBW,2);
area=height*width;
L=logical(targetBW);
ct=regionprops(L,'centroid');% ct means centroid.
ctCell=struct2cell(ct);
bb=regionprops(L,'BoundingBox');% bb means BoundingBox
bbCell=struct2cell(bb);
minPixels=1/75*area;%�����۾��������ͨ���е������صĸ��������ޣ������������費�ϳ���
maxPixels=1/10*area;%�����۾��������ͨ���е������صĸ���������
ctMats={};
bbMats={};
parts={};%�ñ��������ж��Ƿ����left��right��down
for k=1:size(ctCell,2)
    singleCTMat=cell2mat(ctCell(k));
    singleBBMat=cell2mat(bbCell(k));
    ccRow=singleBBMat(2)+0.5;%cc means Connected Component(��ͨ��)
    ccCol=singleBBMat(1)+0.5;
    ccHeight=singleBBMat(4);
    ccWidth=singleBBMat(3);
    cc=targetBW(ccRow:ccRow+ccHeight-1,ccCol:ccCol+ccWidth-1);
    numOfOneInCC=sum(cc(:)==1);
    if numOfOneInCC<minPixels||numOfOneInCC>maxPixels
        continue;
    else
        if ccWidth/ccHeight>1.2%�۾���������Ӧ����ͨ��Ŀ�����ڸ�
            ctMats{length(ctMats)+1}=singleCTMat;
            bbMats{length(bbMats)+1}=singleBBMat;
        end
    end
    
    

end
if length(ctMats)<3%||length(ctMats)>4
%if ~(length(ctMats)==4)
    boolean=0;%���㷨ֻ��ʶ���������ֻ�۾�����������Ӧ��Ӧ3����ͨ����Ϊ���ܻ����ȡ��üë�ͱ��ӣ������ҵ�����ͨ��С��3�����ж�Ϊ��������
else%���ҵ�����ͨ��>=3,�����ж����ǵ�λ�ù�ϵ
    higherX=0;%abuse a higher X.
    lowerX=width;%abuse a lower X.������lowerX��ʼֵ��ýϴ󣬲�����ѭ���������������𼶵ݼ���������ΪtargetBW�Ŀ��
    higherY=0;%abuse a higher Y.
    for k=1:length(ctMats)
        currentCTMat=ctMats{k};
        cctx=currentCTMat(1);%current centroid's X.
        ccty=currentCTMat(2);%current centroid's Y.
%         nextCTMat=ctMats{k+1};
% 
%         nctx=nextCTMat(1);%next centroid's X.
%         ncty=nextCTMat(2);%next centroid's Y.
        if ccty>higherY  %Y�������µ�
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
        parts{1}=left;%����˵��parts�����ж����else�����forѭ���Ƿ�ִ����
        parts{2}=right;
        parts{3}=down;
    
    end
end
%����left��Ӧ���ۣ�right��Ӧ���ۣ�down��Ӧ��
%����ĳһ�����ļ���left����right������down����������A��.
if ~isempty(parts)%ֻ�е�parts���ǿյ�ʱ�򣬲Ŵ���left��right��down����û�������жϣ���������������δ����ľ���.
    eyesDx=right(1)-left(1);
    %disp(eyesDx);
    eyesDy=abs(right(2)-left(2));
    %disp(eyesDy);
    leftAndDownDy=down(2)-left(2); %Y�������µģ�����
    rightAndDownDy=down(2)-right(2);
    average=1/2*(leftAndDownDy+rightAndDownDy);
    %disp(average);
    if abs(eyesDx-width)<0.5*width  %������Ϊ�˱���Ȧ����Ȼ�����������������������ڿ���м�����
        if abs(average-height)<0.5*height  %������Ϊ�˱���Ȧ����Ȼ�����������������������ڿ���м�����
            if down(1)>left(1)&&down(1)<right(1)%���ȣ�down������left��right�м䣬���������A.
                if eyesDx/eyesDy>1%��Σ����ۼ��ˮƽ���������ڴ�ֱ����
                    if average/eyesDx>0.5&&average/eyesDx<1.5%����쵽���۵Ĵ�ֱ�����ƽ��ֵ�����ۼ�ľ��벻�����̫��
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
%һ�´��빩����ʶ���۾������á�
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
