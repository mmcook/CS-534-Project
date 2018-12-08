function trainSampleData()
% We will train the age classfier by going though sample images collected 
% for each age group (divide by each decade,from 0 to 80)
% The data is stored in data.mat, and will be accessed for comparison in
% the main file
    fprintf("Begin training based on sample data...\n");

    data = load('data.mat');
    edges = data.edges;
    ratio = data.ratio;

    sampleFileName = 'sample';
    topLevelFolder = sampleFileName;
    if topLevelFolder == 0
        return;
    end
    allSubFolders = genpath(topLevelFolder);
    % Parse into a cell array.
    ageGroups = allSubFolders;
    listOfFolderNames = {};
    while true
        [singleSubFolder, ageGroups] = strtok(ageGroups, ';');
        if isempty(singleSubFolder)
            break;
        end
        listOfFolderNames = [listOfFolderNames singleSubFolder];
    end
%     disp(listOfFolderNames);
    numberOfFolders = length(listOfFolderNames);
    
    %Gather data for each age group
    for i = 2:numberOfFolders
        % Access folder based on order
       thisFolder = listOfFolderNames{i};
       fprintf("Processing folder: %s\n", thisFolder);
       filePattern = sprintf('%s/*.jpg', thisFolder);
       baseFileNames = dir(filePattern);
       numberOfImageFiles = length(baseFileNames);
       
        %Store number of edges for each image, then sort by ascending order
%         e = zeros(1, numberOfImageFiles);
        e = [];
        for j = 1:numberOfImageFiles
            img = fullfile(thisFolder, baseFileNames(j).name);
            img = imread(img);
            edge = countEdges(img);
            if edge ~= 0
                e = [e edge];
            end
        end
        av_edge = sum(e) / size(e,2);
        
        % Find the upper quantile and lower quantile of the number of edges
        % within the age group
%         lower = fix((numberOfImageFiles + 1) / 4);
%         upper = fix(3 * (numberOfImageFiles + 1) / 4);
        edges(i-1,1) = av_edge;
%         edges(i-1,2) = E(1,upper);
%         
        %Do the same process above for face ratios
%         r = zeros(4, numberOfImageFiles);
        r = [];
        for j = 1:numberOfImageFiles
            img = fullfile(thisFolder, baseFileNames(j).name);
            img = imread(img);
            orig_ratio = faceRatio(img);
            if sum(orig_ratio) ~= 0
                r = [r orig_ratio];
%                 disp(r);
            end
        end
        for j = 1:4
            ratio(i-1,j) = sum(r(j,:)) / size(r,2);
        end
%         av_ratio = sum(r,) / size(r,2);
%         ratio(i-1,:) = av_ratio(1,:);
        % Sort each row of the collection of ratios
%         R = sort(r,2);
%         for j = 1:4
%             ratio(i-1, j*2-1) = R(j,lower);
%             ratio(i-1, j*2) = R(j,upper);
%         end
    end
%     disp(edges);
%     disp(ratio);
    
    fprintf("Training finished!\n");
    save data.mat edges ratio;
end