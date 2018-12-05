%Detect face using Viola-Jones algorithm
faceDetector = vision.CascadeObjectDetector;
I = imread('baby.jpg');
bbox_faces = faceDetector(I);
face = imcrop(I, [bbox_faces(1,1), bbox_faces(1,2), bbox_faces(1,3), bbox_faces(1,4)]);
grayImg = rgb2gray(face);
bw = im2bw(grayImg, 0.5);
filterImg = medfilt2(bw);
edgeImg = edge(filterImg, 'canny', 0.1);
imshow(edgeImg)

cc = bwconncomp(edgeImg);
edgeNum = cc.NumObjects;
