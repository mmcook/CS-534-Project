%Used values from paper "Skin color segmentation based Face-Detection using
%Multi-Color Space
function BW_image = segmentFeatures(img)
    BW_image = zeros(size(img,1), size(img,2));
    for i = 1:size(img,1)
        for j = 1:size(img,2)
            R = img(i,j,1);
            G = img(i,j,2);
            B = img(i,j,3);

            if R > 95 && G > 40 && B > 20 && (max(v) - min(v)) > 15 ...
                abs(R-G) > 15 && R > G && R > B
                BW_image(i,j) = 1;
            end
        end
    end
end