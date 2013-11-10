clc;
clear all;
[X Y] = uigetfile ('*.jpg;*.ppm;*.tif;*.png;' , 'pick a jpg file');
file = fullfile(Y,X);
I=imread(file);
figure, imshow(I);
Org = I;

cform = makecform('srgb2lab');
lab_he = applycform(I,cform);

ab = double(lab_he(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);

bc = reshape(ab,nrows*ncols,2);

nColors = 3;
% repeat the clustering 3 times to avoid local minima
[cluster_idx cluster_center] = kmeans(bc,nColors,'distance','sqEuclidean','Replicates',3);

pixel_labels = reshape(cluster_idx,nrows,ncols);
figure, imshow(pixel_labels,[]), title('image labeled by cluster index');

segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);

for k = 1:nColors
    color = I;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end

hello = 218;
figure, imshow(segmented_images{1}), title('objects in cluster 1');
I = segmented_images{1};
I = rgb2gray(I);
[a b] = imhist(I);
[value, ind] = sort(a);
low=0.1;
high=0.9;
for i = 1:size(value, 1)
    if(ind(i)<20)
        low=1.0*ind(i)/255;
        break;
    end
end
for i = 1:size(value, 1)
    if(ind(i)>200)
        high=1.0*ind(i)/255;
        break;
    end
end
IB1 = im2bw(I,low);
IB2 = im2bw(I,high);
I = IB1-IB2;
figure, imshow(I), title ('ye hai wo');
SE = strel('disk',  1, 0);
I1 = imerode(I, SE);
figure, imshow(I1), title('binarised image');
IE = I1;
flag_stop=0;
for i = 1:2
    IE = imerode(IE, SE);
   [L, num] = bwlabel(IE);
    for j=1:num
        if(bwarea(L==i)<25)
            flag_stop=1;
            break;
        end
    end
    if(flag_stop==1)
        break;
    end
end
flag_stop=0;
figure, imshow(IE);
ID = IE;
for i = 1:4
    ID = imdilate(ID, SE);
     [L, num] = bwlabel(IE);
    for j=1:num
        if(bwarea(L==i)>100)
            flag_stop=1;
            break;
        end
    end
    if(flag_stop==1)
        break;
    end
end
figure, imshow(ID);

[m,n]=size(I);
[L, num] = bwlabel(ID,8);
cn=zeros(num,1);

for i=1:m;
    for j=1:n;
        if(L(i,j)~=0)
            cn(L(i,j))=cn(L(i,j))+1;
        end
    end
end

maxcn=cn(1);
maxl=1;
for i=2:1:num;
    if(cn(i)>maxcn)
        maxcn=cn(i);
        maxl=i;
    end
end

for i=1:m;
    for j=1:n;
        if(L(i,j) == maxl)
            X(i,j)=1;
        else
            X(i,j)=0;
        end
    end
end
% 
% IDiff = I1 - ID;
% figure, imshow(IDiff);
% GX1 = rgb2gray(segmented_images{1});
% [m,n]=size(GX1);
% 
% GX=zeros(m-6,n-6);
% 
% for i=4:1:m-3;
%     for j=4:1:n-3;
%        GX(i-3,j-3)=GX1(i,j);
%     end
% end
% [m,n]=size(GX);
% GX=medfilt2(GX,[4 4]);
% 
% for i=1:m;
%     for j=1:n;
%       if(GX(i,j)<230 & GX(i,j)>30)
%           GX(i,j)=255;
%       else
%           GX(i,j)=0;
%       end
%     end
% end
% 
% X=im2bw(GX);
% figure(),imshow(X);
% 
% [L, num] = bwlabel(X,8);
% cn=zeros(num,1);
% 
% for i=1:m;
%     for j=1:n;
%         if(L(i,j)~=0)
%             cn(L(i,j))=cn(L(i,j))+1;
%         end
%     end
% end
% 
% maxcn=cn(1);
% maxl=1;
% for i=2:1:num;
%     if(cn(i)>maxcn)
%         maxcn=cn(i);
%         maxl=i;
%     end
% end
% 
% for i=1:m;
%     for j=1:n;
%         if(L(i,j) == maxl)
%             X(i,j)=1;
%         else
%             X(i,j)=0;
%         end
%     end
% end


g=zeros(1,n);
X=double(X);

for j=1:1:n;
    for i=1:1:m-1;
       if(X(i,j)==0 && X(i+1,j)==1)
         g(j)=g(j)+1;
       end
    end
end

gmod=medfilt1(g,5);


if(gmod(1)==0 || gmod(2)==0)
    for i=1:1:n
        if(gmod(i)==2)
            finalcolumn=i+2;
            break;
        end
    end
    for i=finalcolumn:1:n
        if(gmod(i)~=2)
            endc=i+2;
            break;
        end
    end
    diff=endc-finalcolumn;
    startc=finalcolumn-diff;
    if(startc < 2)
        startc=2;
    end
    
else
    for i=n:-1:1
        if(gmod(i)==2)
            finalcolumn=i-2;
            break;
        end        
    end
    for i=finalcolumn:-1:1
        if(gmod(i)~=2)
            endc=i-2;
            break;
        end
    end
 
    diff=finalcolumn-endc;
    startc=diff+finalcolumn;
    if(startc>n-1)
        startc=n-1;
    end
end

for i=1:1:m-1
    if(X(i,finalcolumn)==1 & X(i+1,finalcolumn)==0)
        upc=i;
        break;
    end
end
for i=upc:1:m-1
    if(X(i,finalcolumn)==0 & X(i+1,finalcolumn)==1)
        loc=i;
        break;
    end
end

for i=1:1:m;
    X(i,finalcolumn-1)=1;
    X(i,finalcolumn)=1;
    X(i,finalcolumn+1)=1;
    X(i,endc-1)=1;
    X(i,endc)=1;
    X(i,endc+1)=1;
    X(i,startc-1)=1;
    X(i,startc)=1;
    X(i,startc+1)=1;
end

for j=1:1:n;
    X(upc-1,j)=1;
    X(upc,j)=1;
    X(upc+1,j)=1;
    X(loc-1,j)=1;
    X(loc,j)=1;
    X(loc+1,j)=1;
end

figure(),imshow(X);
if(endc <= startc)
    Z1=zeros(upc-loc+1,startc-endc+1,3,'uint8'); 
    for i=upc+3:1:loc+3
         for j=endc+3:1:startc+3
             Z1(i-upc-2,j-endc-2,:)= Org(i,j,:);
         end
    end
else
    Z1=zeros(upc-loc+1,endc-startc+1,3,'uint8'); 
    for i=upc+3:1:loc+3
         for j=startc+3:1:endc+3
             Z1(i-upc-2,j-startc-2,:)=Org(i,j,:);
         end
    end    
end
%figure(),imshow(Z);
%saveas(gcf, 'segmented1.jpg');

var1 = size(Z1,1)*size(Z1,2)

figure, imshow(segmented_images{2}), title('objects in cluster 2');
I = segmented_images{2};
I = rgb2gray(I);
[a b] = imhist(I);
[value, ind] = sort(a);
low=0.1;
high=0.9;
for i = 1:size(value, 1)
    if(ind(i)<20)
        low=1.0*ind(i)/255;
        break;
    end
end
for i = 1:size(value, 1)
    if(ind(i)>200)
        high=1.0*ind(i)/255;
        break;
    end
end
IB1 = im2bw(I,low);
IB2 = im2bw(I,high);
I = IB1-IB2;
figure, imshow(I), title ('ye hai wo');
SE = strel('disk',  1, 0);
I1 = imerode(I, SE);
figure, imshow(I1), title('binarised image');
IE = I1;
flag_stop=0;
for i = 1:2
    IE = imerode(IE, SE);
   [L, num] = bwlabel(IE);
    for j=1:num
        if(bwarea(L==i)<25)
            flag_stop=1;
            break;
        end
    end
    if(flag_stop==1)
        break;
    end
end
flag_stop=0;
figure, imshow(IE);
ID = IE;
for i = 1:4
    ID = imdilate(ID, SE);
     [L, num] = bwlabel(IE);
    for j=1:num
        if(bwarea(L==i)>100)
            flag_stop=1;
            break;
        end
    end
    if(flag_stop==1)
        break;
    end
end
figure, imshow(ID);

[m,n]=size(I);
[L, num] = bwlabel(ID,8);
cn=zeros(num,1);

for i=1:m;
    for j=1:n;
        if(L(i,j)~=0)
            cn(L(i,j))=cn(L(i,j))+1;
        end
    end
end

maxcn=cn(1);
maxl=1;
for i=2:1:num;
    if(cn(i)>maxcn)
        maxcn=cn(i);
        maxl=i;
    end
end

for i=1:m;
    for j=1:n;
        if(L(i,j) == maxl)
            X(i,j)=1;
        else
            X(i,j)=0;
        end
    end
end
% 
% IDiff = I1 - ID;
% figure, imshow(IDiff);
% GX1 = rgb2gray(segmented_images{1});
% [m,n]=size(GX1);
% 
% GX=zeros(m-6,n-6);
% 
% for i=4:1:m-3;
%     for j=4:1:n-3;
%        GX(i-3,j-3)=GX1(i,j);
%     end
% end
% [m,n]=size(GX);
% GX=medfilt2(GX,[4 4]);
% 
% for i=1:m;
%     for j=1:n;
%       if(GX(i,j)<230 & GX(i,j)>30)
%           GX(i,j)=255;
%       else
%           GX(i,j)=0;
%       end
%     end
% end
% 
% X=im2bw(GX);
% figure(),imshow(X);
% 
% [L, num] = bwlabel(X,8);
% cn=zeros(num,1);
% 
% for i=1:m;
%     for j=1:n;
%         if(L(i,j)~=0)
%             cn(L(i,j))=cn(L(i,j))+1;
%         end
%     end
% end
% 
% maxcn=cn(1);
% maxl=1;
% for i=2:1:num;
%     if(cn(i)>maxcn)
%         maxcn=cn(i);
%         maxl=i;
%     end
% end
% 
% for i=1:m;
%     for j=1:n;
%         if(L(i,j) == maxl)
%             X(i,j)=1;
%         else
%             X(i,j)=0;
%         end
%     end
% end


g=zeros(1,n);
X=double(X);

for j=1:1:n;
    for i=1:1:m-1;
       if(X(i,j)==0 && X(i+1,j)==1)
         g(j)=g(j)+1;
       end
    end
end

% g = medfilt2(g, [4 4]);
gmod=medfilt1(g,5);

if(gmod(1)==0 || gmod(2)==0)
    for i=1:1:n
        if(gmod(i)==2)
            finalcolumn=i+2;
            break;
        end
    end
    for i=finalcolumn:1:n
        if(gmod(i)~=2)
            endc=i+2;
            break;
        end
    end
     diff=endc-finalcolumn;
    startc=finalcolumn-diff;
    if(startc < 2)
        startc=2;
    end
    
else
    for i=n:-1:1
        if(gmod(i)==2)
            finalcolumn=i-2;
            break;
        end        
    end
    for i=finalcolumn:-1:1
        if(gmod(i)~=2)
            endc=i-2;
            break;
        end
    end
 
    diff=finalcolumn-endc;
    startc=diff+finalcolumn;
    if(startc>n-1)
        startc=n-1;
    end
end

for i=1:1:m-1
    if(X(i,finalcolumn)==1 & X(i+1,finalcolumn)==0)
        upc=i;
        break;
    end
end
for i=upc:1:m-1
    if(X(i,finalcolumn)==0 & X(i+1,finalcolumn)==1)
        loc=i;
        break;
    end
end

for i=1:1:m;
    X(i,finalcolumn-1)=1;
    X(i,finalcolumn)=1;
    X(i,finalcolumn+1)=1;
    X(i,endc-1)=1;
    X(i,endc)=1;
    X(i,endc+1)=1;
    X(i,startc-1)=1;
    X(i,startc)=1;
    X(i,startc+1)=1;
end

for j=1:1:n;
    X(upc-1,j)=1;
    X(upc,j)=1;
    X(upc+1,j)=1;
    X(loc-1,j)=1;
    X(loc,j)=1;
    X(loc+1,j)=1;
end

figure(),imshow(X);
if(endc <= startc)
    Z2=zeros(upc-loc+1,startc-endc+1,3,'uint8'); 
    for i=upc+3:1:loc+3
         for j=endc+3:1:startc+3
             Z2(i-upc-2,j-endc-2,:)= Org(i,j,:);
         end
    end
else
    Z2=zeros(upc-loc+1,endc-startc+1,3,'uint8'); 
    for i=upc+3:1:loc+3
         for j=startc+3:1:endc+3
             Z2(i-upc-2,j-startc-2,:)=Org(i,j,:);
         end
    end    
end
%figure(),imshow(Z);
%saveas(gcf, 'segmented2.jpg');
var2 = size(Z2,1)*size(Z2,2)

figure, imshow(segmented_images{3}), title('objects in cluster 3');
I = segmented_images{3};
I = rgb2gray(I);
[a b] = imhist(I);
[value, ind] = sort(a);
low=0.1;
high=0.9;
for i = 1:size(value, 1)
    if(ind(i)<20)
        low=1.0*ind(i)/255;
        break;
    end
end
for i = 1:size(value, 1)
    if(ind(i)>200)
        high=1.0*ind(i)/255;
        break;
    end
end
IB1 = im2bw(I,low);
IB2 = im2bw(I,high);
I = IB1-IB2;
figure, imshow(I), title ('ye hai wo');
SE = strel('disk',  1, 0);
I1 = imerode(I, SE);
figure, imshow(I1), title('binarised image');
IE = I1;
flag_stop=0;
for i = 1:2
    IE = imerode(IE, SE);
   [L, num] = bwlabel(IE);
    for j=1:num
        if(bwarea(L==i)<25)
            flag_stop=1;
            break;
        end
    end
    if(flag_stop==1)
        break;
    end
end
flag_stop=0;
figure, imshow(IE);
ID = IE;
for i = 1:4
    ID = imdilate(ID, SE);
     [L, num] = bwlabel(IE);
    for j=1:num
        if(bwarea(L==i)>100)
            flag_stop=1;
            break;
        end
    end
    if(flag_stop==1)
        break;
    end
end
figure, imshow(ID);

[m,n]=size(I);
[L, num] = bwlabel(ID,8);
cn=zeros(num,1);

for i=1:m;
    for j=1:n;
        if(L(i,j)~=0)
            cn(L(i,j))=cn(L(i,j))+1;
        end
    end
end

maxcn=cn(1);
maxl=1;
for i=2:1:num;
    if(cn(i)>maxcn)
        maxcn=cn(i);
        maxl=i;
    end
end

for i=1:m;
    for j=1:n;
        if(L(i,j) == maxl)
            X(i,j)=1;
        else
            X(i,j)=0;
        end
    end
end
% 
% IDiff = I1 - ID;
% figure, imshow(IDiff);
% GX1 = rgb2gray(segmented_images{1});
% [m,n]=size(GX1);
% 
% GX=zeros(m-6,n-6);
% 
% for i=4:1:m-3;
%     for j=4:1:n-3;
%        GX(i-3,j-3)=GX1(i,j);
%     end
% end
% [m,n]=size(GX);
% GX=medfilt2(GX,[4 4]);
% 
% for i=1:m;
%     for j=1:n;
%       if(GX(i,j)<230 & GX(i,j)>30)
%           GX(i,j)=255;
%       else
%           GX(i,j)=0;
%       end
%     end
% end
% 
% X=im2bw(GX);
% figure(),imshow(X);
% 
% [L, num] = bwlabel(X,8);
% cn=zeros(num,1);
% 
% for i=1:m;
%     for j=1:n;
%         if(L(i,j)~=0)
%             cn(L(i,j))=cn(L(i,j))+1;
%         end
%     end
% end
% 
% maxcn=cn(1);
% maxl=1;
% for i=2:1:num;
%     if(cn(i)>maxcn)
%         maxcn=cn(i);
%         maxl=i;
%     end
% end
% 
% for i=1:m;
%     for j=1:n;
%         if(L(i,j) == maxl)
%             X(i,j)=1;
%         else
%             X(i,j)=0;
%         end
%     end
% end


g=zeros(1,n);
X=double(X);

for j=1:1:n;
    for i=1:1:m-1;
       if(X(i,j)==0 && X(i+1,j)==1)
         g(j)=g(j)+1;
       end
    end
end

% g = medfilt2(g, [4 4]);
gmod=medfilt1(g,5);

if(gmod(1)==0 || gmod(2)==0)
    for i=1:1:n
        if(gmod(i)==2)
            finalcolumn=i+2;
            break;
        end
    end
    for i=finalcolumn:1:n
        if(gmod(i)~=2)
            endc=i+2;
            break;
        end
    end
     diff=endc-finalcolumn;
    startc=finalcolumn-diff;
    if(startc < 2)
        startc=2;
    end
    
else
    for i=n:-1:1
        if(gmod(i)==2)
            finalcolumn=i-2;
            break;
        end        
    end
    for i=finalcolumn:-1:1
        if(gmod(i)~=2)
            endc=i-2;
            break;
        end
    end
 
    diff=finalcolumn-endc;
    startc=diff+finalcolumn;
    if(startc>n-1)
        startc=n-1;
    end
end

for i=1:1:m-1
    if(X(i,finalcolumn)==1 & X(i+1,finalcolumn)==0)
        upc=i;
        break;
    end
end
for i=upc:1:m-1
    if(X(i,finalcolumn)==0 & X(i+1,finalcolumn)==1)
        loc=i;
        break;
    end
end

for i=1:1:m;
    X(i,finalcolumn-1)=1;
    X(i,finalcolumn)=1;
    X(i,finalcolumn+1)=1;
    X(i,endc-1)=1;
    X(i,endc)=1;
    X(i,endc+1)=1;
    X(i,startc-1)=1;
    X(i,startc)=1;
    X(i,startc+1)=1;
end

for j=1:1:n;
    X(upc-1,j)=1;
    X(upc,j)=1;
    X(upc+1,j)=1;
    X(loc-1,j)=1;
    X(loc,j)=1;
    X(loc+1,j)=1;
end

figure(),imshow(X);
if(endc <= startc)
    Z3=zeros(upc-loc+1,startc-endc+1,3,'uint8'); 
    for i=upc+3:1:loc+3
         for j=endc+3:1:startc+3
             Z3(i-upc-2,j-endc-2,:)= Org(i,j,:);
         end
    end
else
    Z3=zeros(upc-loc+1,endc-startc+1,3,'uint8'); 
    for i=upc+3:1:loc+3
         for j=startc+3:1:endc+3
             Z3(i-upc-2,j-startc-2,:)=Org(i,j,:);
         end
    end    
end
%figure(),imshow(Z), title('this one 3');
%saveas(gcf, 'segmented3.jpg');

var3 = size(Z3,1)*size(Z3,2)

maxvar = max([var1 var2 var3])

if maxvar == var1
    figure(),imshow(Z1), title('The final segmented image');
    saveas(gcf, 'segmented.jpg');
end

if maxvar == var2
    figure(),imshow(Z2), title('The final segmented image');
    saveas(gcf, 'segmented.jpg');
end

if maxvar == var3
    figure(),imshow(Z3), title('The final segmented image');
    saveas(gcf, 'segmented.jpg');
end
