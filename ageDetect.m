function [final_img, e_trans,r_trans] = ageDetect(img)
% We will attempt to determine the age of a person using the number of
% edge objects and the ratio of different parts of faces given by
% countEdges and faceRatio function. Then, we use the Median Absolute
% Deviation to determine if the range to classify the age group for the
% face. 
%
% INPUT:
%   img = The image given by user
% OUTPUT:
%   final_img = The image annotated with boundary boxes around the face,
%       along with the age group classified according to the program.
%   e_trans = List of images depicting the transformation steps to retrieve
%       the numer of edge objects within received image.
%   r_trans = List of images which annotate the measurements taken to
%       calculate the ratios used.
    
    final_img = 0;
    
    % Load the sample data for edges and face ratio from the database
    data = load('data.mat');
    edges = data.edges;
    ratio = data.ratio;
    
    % Detect face of the image using Viola-Jones algorithm
    faceDetector = vision.CascadeObjectDetector;
    
    % Contains x-cord, y-cord, width, height of the location of the face in
    % an image.
    bbox_faces = faceDetector(img);
    if size(bbox_faces,1) == 0
        return
    end
%     disp(size(bbox_faces,1));

    
    % Record the age group for each face
    ageGroup = zeros(1,size(bbox_faces,1));
    
    % Classify the age group of each face in the picture
    for i = 1:size(bbox_faces, 1)
        % Calculate number of edges and the different ratios of the face
        [e, e_trans] = countEdges(img, bbox_faces(i,:));
        [r, r_trans] = faceRatio(img, bbox_faces(i,:));

        % If you cannot detect the edges/ratio correctly, continue to next
        % loop iteration (leave as 0)
        if sum(e) == 0 || sum(r) == 0
            continue
        end

        % We will use the Median Absolute Deviation of the face ratio to
        % determine if the face is a baby or adult/senior
        r2 = r(1,1) < (ratio(1,1) + ratio(1,2));
        r3 = r(2,1) < (ratio(1,3) + ratio(1,4));
        r5 = r(3,1) < (ratio(1,5) + ratio(1,6));
        r6 = r(4,1) < (ratio(1,7) + ratio(1,8));
        ed = e < (edges(2,1) + edges(2,2));
        
        if r2 && r3 && r5 && r6
            ageGroup(1,i) = 1;
        else
            % Then we will again use the Median Absolute Deviation of the
            % number of edges to determine if the face is an adult or a
            % senior
            if ed == 1
                ageGroup(1,i) = 2;
            else
                ageGroup(1,i) = 3;
            end
        end    
    end
    
    % Annotate face on each image based on age group (ignore faces that we
    % could not classify)
    final_img = img;
    for i = 1:size(bbox_faces,1)
        if ageGroup(1,i) == 1
            final_img = insertObjectAnnotation(final_img, 'rectangle', ...
                bbox_faces(i,:), 'Baby');
        elseif ageGroup(1,i) == 2
            final_img = insertObjectAnnotation(final_img, 'rectangle', ...
                bbox_faces(i,:), 'Adult');                
        elseif ageGroup(1,i) == 3
            final_img = insertObjectAnnotation(final_img, 'rectangle', ...
                bbox_faces(i,:), 'Senior');                
        end
    end
    imshow(final_img);
end