function trainSampleData()
% We will train the age classfier by going though sample images collected 
% for each age group (divide by each decade,from 0 to 80)
% The data is stored in data.mat, and will be accessed for comparison in
% the main file
    fprintf("Begin training based on sample data...\n");

    data = load('data.mat');
    edges = zeros(3,2)
    ratio = zeros(3,8);

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
        e = [];
        numEdges = 0;
        for j = 1:numberOfImageFiles
            img = fullfile(thisFolder, baseFileNames(j).name);
            img = imread(img);
            edge = countEdges(img);
            if edge ~= 0
                e = [e edge];
                numEdges = numEdges + 1;
            end
        end
        % Find the median and the Median absolute deviation number of edges
        % within the age group
%         edges(i-1,1) = sum(e) / size(e,2);
        if rem(numEdges, 2) == 1
            edgeMedian = (numEdges + 1) / 2;
        else
            edgeMedian = numEdges/2 + 1;
        end
        E = sort(e);
        edges(i-1,1) = E(1,edgeMedian);
        edges(i-1,2) = mad(E,1);
        
        %Do the same process above for face ratios
        r = [];
        numRatios = 0;
        for j = 1:numberOfImageFiles
            img = fullfile(thisFolder, baseFileNames(j).name);
            img = imread(img);
            orig_ratio = faceRatio(img);
            if sum(orig_ratio) ~= 0
                r = [r orig_ratio];
                numRatios = numRatios + 1;
            end
        end
        
        if rem(numRatios, 2) == 1
            ratioMedian = (numRatios + 1) / 2;
        else
            ratioMedian = numRatios/2 + 1;
        end
        R = sort(r,2);
        
        for j = 1:4
%             ratio(i-1,j) = sum(r(j,:)) / size(r,2);
            ratio(i-1,j*2-1) = R(j,ratioMedian);
            ratio(i-1,j*2) = mad(r(j,:),1);
        end
    end
%     disp(edges);
%     disp(ratio);
    
    fprintf("Training finished!\n");
    save data.mat edges ratio;
end