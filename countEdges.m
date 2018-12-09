function edgeNum = countEdges(img, bbox_faces)
% Calculate the amount of edges (which positively correlates with age due 
% to the amount of wrinkles which increases with age) by performing a Canny
% edge detection on the face.
% We will use the method presented in the paper "Estimating The Age of
% Human Face In Image Processing Using Matlab"
%
% INPUT:
%   img = The image given by user
%   bbox_faces = The matrix which contains the x-cord, y-cord, width,
%       the height of the face of the image. By selecting the face, we 
%       reduce amount of noise and objects other than the face (such as 
%       hair, clothing, background) which can alter the results
% OUTPUT:
%   edgeNum = The total number of edges in an image. One edge object is a
%       connected component by 8.
%       It will return 0 if there are any errors.
%   e_trans = List of images depicting the transformation steps to retrieve
%       the numer of edge objects within received image.
    
    edgeNum = 0;
    if size(bbox_faces,1) == 0
        return
    end
    
    % Additionally crop another 10 percent of the face vertically to
    % remove additional background/hair/noise from image which can alter
    % the result
    tenPercent = fix(bbox_faces(1,3) * 0.1);
    face = imcrop(img, [bbox_faces(1,1)+tenPercent, bbox_faces(1,2), ... 
                    bbox_faces(1,3)-2*tenPercent, bbox_faces(1,4)]);
%     figure; imshow(face);
    
    %Convert RGB image to grayscale
    grayImg = rgb2gray(face);
    
    %Convert grayscale image to binary to make edge detection easier
    bw = im2bw(grayImg, 0.5);
%     figure; imshow(bw);

    %Use a median filter to reduce the amount of noise in the image
    filterImg = medfilt2(bw);
%     figure; imshow(filterImg);

    %Use a Canny Edge Detector 
    edgeImg = edge(filterImg, 'canny', 0.1);
%     figure; imshow(edgeImg)
    
    % Count the number of edges in terms of 8-connected components
    cc = bwconncomp(edgeImg);
    edgeNum = cc.NumObjects;
%     disp(edgeNum);
end