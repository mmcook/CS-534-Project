%Detect face using Viola-Jones algorithm
faceDetector = vision.CascadeObjectDetector;
I = imread('sample4.jpg');
bbox_faces = faceDetector(I);

for i = 1:size(bbox_faces,1)
    eyeDetector = vision.CascadeObjectDetector('EyePairSmall');
    mouthDetector = vision.CascadeObjectDetector('Mouth','MergeThreshold',16);
    
    %Crop image using coordinates from face detection
    I2 = imcrop(I, [bbox_faces(i,1), bbox_faces(i,2), bbox_faces(i,3), bbox_faces(i,4)]);
    
    %Detect eyes from cropped image(using the top half of the cropped image
    %using face detection)
    n = fix(size(I2,1)/2);
    top = I2(1:n,:,:);
    figure
    imshow(top);
    bbox_eyes = eyeDetector(top);
    if size(bbox_eyes,1) > 0
        eyes = imcrop(I2, [bbox_eyes(1,1), bbox_eyes(1,2), bbox_eyes(1,3), bbox_eyes(1,4)]);
        k = fix(size(eyes,2)/2);
        leftEye = eyes(:, 1:k, :);
        rightEye = eyes(:, k+1:end, :);
    end
    
    %Detect mouth from bottom half of face
    bottom = I2(n+1:end,:,:);
    bbox_mouth = mouthDetector(bottom);
    bbox_mouth(:,2) = bbox_mouth(:,2) + n;
    
%     % Image annotation for testing
%     iFaces = insertObjectAnnotation(I2,'rectangle',bbox_eyes, 'eye');   
%     figure
%     imshow(iFaces)
end