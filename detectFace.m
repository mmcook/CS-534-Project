faceDetector = vision.CascadeObjectDetector;
%eyeDetector = vision.CascadeObjectDetector('EyePairBig');
%mouthDetector = vision.CascadeObjectDetector('Mouth','MergeThreshold',16);
I = imread('sample.jpg');
bbox = faceDetector(I);
%bbox = eyeDetector(I)
%bbox = mouthDetector(I)

IFaces = insertObjectAnnotation(I,'rectangle',bbox,'Face');   
figure
imshow(IFaces)
title('Detected faces');