function edgeNum = countEdges(I)
% Calculate the amount of edges (which positively correlates with age due 
% to wrinkles on face) by performing a Canny edge detection on the face.
% We will use the method presented in the paper "Estimating The Age of
% Human Face In Image Processing Using Matlab"
%
% INPUT:
% 
% OUTPUT:
%
    edgeNum = 0;
   
    %Detect face using Viola-Jones algorithm
    faceDetector = vision.CascadeObjectDetector;
    %Contains x-cord, y-cord, width, height of the location of the face in
    %an image.
    bbox_faces = faceDetector(I);
    
    if size(bbox_faces,1) == 0
        return
    end
    
    % Crop the image to just the face, so we can limit the edges we count to
    % only that of the face (remove unnecessary objects from background)
    m = 0;
    ind = 0;
    for i = 1:size(bbox_faces,1)
        if bbox_faces(i,3) * bbox_faces(i,4) > m
            m = bbox_faces(i,3) * bbox_faces(i,4);
            ind = i;
        end
    end
    tenPercent = fix(bbox_faces(ind,3) * 0.1);
    face = imcrop(I, [bbox_faces(ind,1)+tenPercent, bbox_faces(ind,2), ... 
                    bbox_faces(ind,3)-2*tenPercent, bbox_faces(ind,4)]);
%     figure; imshow(face);
    
    %Convert RGB image to grayscale
    grayImg = rgb2gray(face);
    
    %Convert grayscale image to binary to make edge detection easier
    bw = im2bw(grayImg, 0.5);
%     figure; imshow(bw);

    %Use a median filter to reduce the amount of noise in the image
    filterImg = medfilt2(bw);

    %Use a Canny Edge Detector 
    edgeImg = edge(filterImg, 'canny', 0.1);
%     figure; imshow(edgeImg)
    
    % Count the number of edges in terms of 8-connected components
    cc = bwconncomp(edgeImg);
    edgeNum = cc.NumObjects;
%     disp(edgeNum);
end