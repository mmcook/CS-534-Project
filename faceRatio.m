function ratio = faceRatio(img, bbox_faces)
% The ratios used are taken from "Age Classification from Facial Images" 
% (we decided not to collect Ratio 1 and 4, because the nose and mouth
% classifier can confuse between nose and mouth.
% By calculating the ratio, it would allow us to differentiate between
% children and young adults (who would both have a small amount of edges).
%
% INPUT:
%   img = The image given by user
%   bbox_faces = The matrix which contains the x-cord, y-cord, width,
%       height of the face of the image. This would allow us to figure out 
%       the size of the face, as well as detect the eyes and the mouth of 
%       the face, so we can calculate the ratios.
% OUTPUT:
%   ratio = A 4x1 matrix collection of the ratios calculated by the
%       position of eyes and mouth, as well as the size of the face. From 
%       left, it contains Ratio 2, Ratio 3, Ratio 5, Ratio 6.
%       If there are any errors, such as cannot detect eyes/mouth, return 0
%   r_trans = List of images which annotate the measurements taken to
%       calculate the ratios used.

    % We will collect Ratio 2, Ratio 3, Ratio 5, Ratio 6 from the paper
    ratio = zeros(4,1);
    if size(bbox_faces,1) == 0
        return;
    end
    
    % Use the Viola-Jones algorithm to detect the eyes and the mouth.
    eyeDetector = vision.CascadeObjectDetector('EyePairBig');
    mouthDetector = vision.CascadeObjectDetector('Mouth', ...
                    'MergeThreshold',16);
    
    img2 = imcrop(img, [bbox_faces(1,1), bbox_faces(1,2), ... 
                 bbox_faces(1,3), bbox_faces(1,4)]);
  
    % Detect eyes from cropped image (using the top half of the cropped 
    % image using face detection)
    n = fix(size(img2,1)/2);
    top = img2(1:n,:,:);
    bbox_eyes = eyeDetector(top);
    
    % We cannot calculate ratio without information of eyes, so if there are
    % none, return 0
    if size(bbox_eyes,1) == 0
        return
    end
    
    % The exact point we will measure will be on the center of the eyes
    eyes =[bbox_eyes(1,1), bbox_eyes(1,2)+bbox_eyes(1,4)/2, ... 
            bbox_eyes(1,3), bbox_eyes(1,4)];
    
    % Detect mouth from bottom half of face
    bottom = img2(n+1:end,:,:);
    bbox_mouth = mouthDetector(bottom);
    bbox_mouth(:,2) = bbox_mouth(:,2) + n;
    
    % We cannot calculate ratio without detecting the mouth, so if there
    % are none, return 0
    if size(bbox_mouth,1) == 0
        return
    end
    
    % Since mouth detector can be unreliable, as it sometimes detects the 
    % nose or nostrils instead of the mouth, search through to find the box
    % with the largest area. The largest area will likely be the mouth
    ind = 1;
    m = 0;
    for i = 1:size(bbox_mouth,1)
        if bbox_mouth(i,3) * bbox_mouth(i,4) > m
            m = bbox_mouth(i,3) * bbox_mouth(i,4);
            ind = i;
        end
    end
    % The exact point we will measure will be on the center of the mouth
    lips = [bbox_mouth(ind,1), bbox_mouth(ind,2)+bbox_mouth(ind,4)/2, ...
            bbox_mouth(ind,3), bbox_mouth(ind,4)];
    
    % Calculate ratios using the values of eyes, mouth and face
    % left eye - right eye & eye - mouth (Ratio 2)
    ratio(1,1) =  abs(eyes(1,2) - lips(1,2)) / eyes(1,3);
%     figure; hold on;
%     imshow(img2);
%     line([eyes(1,1), eyes(1,1)],[eyes(1,2), lips(1,2)], 'LineWidth', 0.75);
%     line([eyes(1,1), eyes(1,3) + eyes(1,1)], [eyes(1,2), eyes(1,2)], ...
%         'Color', 'r', 'LineWidth', 0.75);
    
    % left eye-right eye & eye-chin (Ratio 3)
    ratio(2,1) =  eyes(1,3)/ abs(size(img2, 1) - eyes(1,2));
%     figure; hold on; 
%     imshow(img2);
%     line([eyes(1,1), eyes(1,3) + eyes(1,1)], [eyes(1,2), eyes(1,2), ...
%             'LineWidth', 0.75]);
%     line([eyes(1,1), eyes(1,1)], [eyes(1,2), size(img2,1), 'Color', 'r',...
%             'LineWidth', 0.75]);
    
    % eye-mouth & eye-chin (Ratio 5)
    ratio(3,1) = abs(eyes(1,2) - lips(1,2)) / abs(size(img2, 1)-eyes(1,2));
%     figure; hold on;
%     imshow(img2);
%     line([eyes(1,1), eyes(1,1)],[eyes(1,2), lips(1,2)],'LineWidth', 0.75);
%     line([eyes(1,3)+eyes(1,1),eyes(1,3)+eyes(1,1)],...
%             [eyes(1,2),size(img2,1)],'Color', 'r','LineWidth', 0.75);
    
    % eye-chin & forehead-chin (Ratio 6)
    ratio(4,1) = eyes(1,2) / size(img2, 1); 
%     figure; hold on;
%     imshow(img2);
%     line([eyes(1,1), eyes(1,1)],[eyes(1,2), size(img2,1)],'LineWidth',0.75);
%     line([eyes(1,3) + eyes(1,1),eyes(1,3) + eyes(1,1)],...
%             [size(img2,1),0], 'Color', 'r','LineWidth', 0.75);
    
%     disp(ratio);
end