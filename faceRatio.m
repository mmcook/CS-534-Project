function ratio = faceRatio(img)
% The ratios used are taken from "Age Classification from Facial Images" 
% (we decided not to collect Ratio 1 and 4, because the nose and mouth
% classifier can confuse between nose and mouth.
% By calculating the ratio, it would allow us to differentiate between
% children and young adults (who would both have a small amount of edges). 
% INPUT:
% 
% OUTPUT:
%

    % We will collect Ratio 2, Ratio 3, Ratio 5, Ratio 6 from the paper
    ratio = zeros(4,1);
    
    % Use the Viola-Jones algorithm to detect face, eyes, and mouth.
    faceDetector = vision.CascadeObjectDetector;
    eyeDetector = vision.CascadeObjectDetector('EyePairBig');
    mouthDetector = vision.CascadeObjectDetector('Mouth', ...
                    'MergeThreshold',16);
    
    % Crop image using coordinates from face detection
    bbox_faces = faceDetector(img);
    if size(bbox_faces,1) == 0
        return;
    end
    I2 = imcrop(img, [bbox_faces(1,1), bbox_faces(1,2), bbox_faces(1,3), ...
                bbox_faces(1,4)]);
    
    % Detect eyes from cropped image(using the top half of the cropped 
    % image using face detection)
    n = fix(size(I2,1)/2);
    top = I2(1:n,:,:);
    bbox_eyes = eyeDetector(top);
    
    % We cannot calculate ratio without information of eyes, so if there are
    % none, return 0
    if size(bbox_eyes,1) == 0
        return
    end
%     disp(bbox_eyes);
    eyes =[bbox_eyes(1,1), bbox_eyes(1,2)+bbox_eyes(1,4)/2, ... 
            bbox_eyes(1,3), bbox_eyes(1,4)];
%     disp(eyes);
    
    % Detect mouth from bottom half of face
    bottom = I2(n+1:end,:,:);
    bbox_mouth = mouthDetector(bottom);
    bbox_mouth(:,2) = bbox_mouth(:,2) + n;
    
    % We cannot calculate ratio without information of mouth, so if there
    % are none, return 0
    if size(bbox_mouth,1) == 0
        return
    end
    
    % Since mouth detector can be unreliable, search through to find the
    % box with the largest area. The largest area will likely be the lips
    % (instead of nose)
    ind = 1;
    m = 0;
    for i = 1:size(bbox_mouth,1)
        if bbox_mouth(i,3) * bbox_mouth(i,4) > m
            m = bbox_mouth(i,3) * bbox_mouth(i,4);
            ind = i;
        end
    end
    lips = [bbox_mouth(ind,1), bbox_mouth(ind,2)+bbox_mouth(ind,4)/2, ...
            bbox_mouth(ind,3), bbox_mouth(ind,4)];
    
    % Calculate ratios between eyes and mouth to face
    % left eye - right eye & eye - mouth (Ratio 2)
    ratio(1,1) =  abs(eyes(1,2) - lips(1,2)) / eyes(1,3);
%     figure; hold on;
%     imshow(I2);
%     line([eyes(1,1), eyes(1,1)],[eyes(1,2), lips(1,2)]);
%     line([eyes(1,1), eyes(1,3) + eyes(1,1)], [eyes(1,2), eyes(1,2)]);
    
    % left eye-right eye & eye-chin (Ratio 3)
    ratio(2,1) =  eyes(1,3)/ abs(size(I2, 1) - eyes(1,2));
%     figure; hold on; 
%     imshow(I2);
%     line([eyes(1,1), eyes(1,3) + eyes(1,1)], [eyes(1,2), eyes(1,2)]);
%     line([eyes(1,1), eyes(1,1)],[eyes(1,2), 0]);
    
    % eye-mouth & eye-chin (Ratio 5)
    ratio(3,1) = abs(eyes(1,2) - lips(1,2)) / abs(size(I2, 1) - eyes(1,2));
%     figure; hold on;
%     imshow(I2);
%     line([eyes(1,1), eyes(1,1)],[eyes(1,2), lips(1,2)]);
%     line([eyes(1,1), eyes(1,3) + eyes(1,1)], [eyes(1,2), eyes(1,2)]);
    
    % eye-chin & forehead-chin (Ratio 6)
    ratio(4,1) = eyes(1,2) / size(I2, 1); 
%     figure; hold on;
%     imshow(I2);
%     line([eyes(1,1), eyes(1,1)],[eyes(1,2), lips(1,2)]);
%     line([eyes(1,1), eyes(1,3) + eyes(1,1)], [eyes(1,2), eyes(1,2)]);
    
%     disp(ratio);
end