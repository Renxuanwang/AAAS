function [segmat] = AAT_SEG2(filename, pathname,h, filelen,indexnum)
reset(gpuDevice(1));
qwe = 0;

hBtn = findall(h, 'type', 'uicontrol');
set(hBtn, 'string', 'cancel', 'FontSize', 10);
waitbar(qwe, h, ['Preprocessing (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
% load([figname '.mat']);
img = dicomread([pathname filename]);
img = double(img);
load('seg15.mat');

% patch extraction
patchsize = 17; half1 = floor(patchsize/2);
poolsize2 = 5; patchsize2 = patchsize*poolsize2; half2 = floor(patchsize2/2);
window_avg2 = 1/(poolsize2*poolsize2)*ones(poolsize2);


% image preprocessing
img = img/max(img(:));
img = single(img);
  qwe = qwe + 0.07;
        waitbar(qwe, h, ['Preprocessing (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
% abdomen part
mask = zeros(size(img));
mask(50:end-50,50:end-50) = 1;

bw = activecontour(img,mask,500); % active contour for detecting abdomen part;
 qwe = qwe + 0.04;
        waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
% patches
idx = find(bw==1);
N = length(idx);
data85 = zeros(N,patchsize^2);
data17 = zeros(N,patchsize^2);
[xxx,yyy]=size(img);


[xx,yy] = find(bw==1);
 qwe = qwe + 0.07;
        waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
for i = 1:N
    
     x = xx(i); y = yy(i);
    
    patch = zeros(patchsize2,patchsize2);
    xdelta1 = min(half2,x-1);  xdelta2 = min(half2,xxx-x); ydelta1 = min(half2,y-1); ydelta2 = min(half2,yyy-y);
    patch(half2+1-xdelta1:half2+1+xdelta2,half2+1-ydelta1:half2+1+ydelta2) = img(max(x-half2,1):min(x+half2,xxx),max(y-half2,1):min(y+half2,yyy));
    
    
    avg = conv2(patch,window_avg2,'valid'); avg_compress2 = avg(1:poolsize2:end,1:poolsize2:end);
    data85(i,:) = avg_compress2(:)';
    clear avg avg_compress2 patch

    patch = zeros(patchsize,patchsize);
    xdelta1 = min(half1,x-1);  xdelta2 = min(half1,xxx-x); ydelta1 = min(half1,y-1); ydelta2 = min(half1,yyy-y);
    patch(half1+1-xdelta1:half1+1+xdelta2,half1+1-ydelta1:half1+1+ydelta2) = img(max(x-half1,1):min(x+half1,xxx),max(y-half1,1):min(y+half1,yyy));
    
    data17(i,:) = patch(:)';
    clear patch
     if(mod(i,fix(N/35))==0)
         qwe = qwe + 0.01;
        waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
    end
end

data85 = single(data85);
data17 = single(data17);
% clear img;


%forward propogation
 % forward propogation for testing
%     N = size(data17,1);
    one = gpuArray(ones(N, 1));
    % local features;
    XX1 = [gpuArray(data17) one];
    w11probs = 1./(1+exp(-XX1*gpuArray(w11))); w11probs = [w11probs one]; % N*(l21+1);
    w21probs = 1./(1+exp(-w11probs*gpuArray(w21))); %w21probs = [w21probs ones(N,1)]; % N*(l3)
    clear XX1;
    clear w11probs;
    % global features;
     qwe = qwe + 0.03;
    waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
    XX2 = [gpuArray(data85) one];
    w12probs = 1./(1+exp(-XX2*gpuArray(w12))); w12probs = [w12probs one];% N*(l22+1);
    clear XX2;
     qwe = qwe + 0.03;
    waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
    w22probs = 1./(1+exp(-w12probs*gpuArray(w22))); %w22probs = [w22probs ones(N,1)]; % N*l3
    clear w12probs;
    qwe = qwe + 0.03;
    waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
    % feature fusion
    w2probs = [w21probs w22probs one]; % N*(l21+l22+1);
    clear w21probs;
    clear w22probs;
    qwe = qwe + 0.04;
        waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
    w3probs = 1./(1+exp(-w2probs*gpuArray(w3)));
    clear w2probs;
%     w3probs = [w3probs  ones(N,1)]; % N*(l4+1)
    % adding new features;
%     w3probs = [w3probs feas];
    qwe = qwe + 0.07;
        waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
    w3probs = [w3probs  one]; % N*(l4+1)
     qwe = qwe + 0.11;
        waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
    temp = w3probs*gpuArray(w_class);
    clear w3probs;
     qwe = qwe + 0.04;
    waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
    targetout = exp(temp-max(temp(:)));
    targetout = targetout./repmat(sum(targetout,2),1,3);
    clear temp;
    [dump,segvec] = max(targetout,[],2);
    clear targetout;
    
    
    % segmentation results
    qwe = qwe + 0.05;
    waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
    segmat = ones(size(img))*4;
    segmat(idx) = gather(segvec);
    qwe = qwe + 0.03;
        waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
    Out = uint8(segmat);
    mkdir('dat');
    dlmwrite(['dat/' filename '.dat'], Out, '\t');
     qwe = qwe + 0.02;
        waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
   % save([filename], 'segmat');
    qwe = qwe + 0.02;
        waitbar(qwe, h, ['Segmenting (' num2str(indexnum) '/' num2str(filelen) '): ' num2str(qwe*100) '%']);
    clear segvec;

    % imshow
   % figure(1)
    %imshow(img);
   % title('original MR image');
%     figure(2)
%     imagesc(lab);
%     title('manual segmentation');
   % figure(2)
    %imagesc(segmat);
    %title('our segmentation');
    