function hazy = hazyImage(im)
%HAZYIMAGE 此处显示有关此函数的摘要
%   此处显示详细说明
m=size(im,1);
n=size(im,2);
red=im(:,:,1);
green=im(:,:,2);
blue=im(:,:,3);
k=0;
while k<2
for row=2:m-1
    for col=2:n-1
        rowRange=row-1:row+1;
        colRange=col-1:col+1;
        red(row,col)=uint8(sum(sum(red(rowRange,colRange)))/9);
        green(row,col)=uint8(sum(sum(green(rowRange,colRange)))/9);
        blue(row,col)=uint8(sum(sum(blue(rowRange,colRange)))/9);

    end
end
k=k+1;
end
 hazy=cat(3,red,green,blue);
end

