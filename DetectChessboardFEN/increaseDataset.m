function increaseDataset(datasetPath)
    folders = dir(datasetPath);
    for f = 3:length(folders)
        folderName = folders(f).name;
        if ~isequal(folderName,'EmptySquare') %Skip for empty squares(there are already many)
            fprintf('Increasing %s\n',folderName);
            directory = strcat(datasetPath,'/',folderName);
            images = dir(directory);
            for i = 3:length(images)
                imageName = images(i).name;
                name = imageName(1:(length(imageName))-4);
                extension = imageName((length(imageName)-3):length(imageName));
                image = imread(strcat(directory,'/',imageName));
                increaseImage(directory,image,name,extension);            
            end
        end
    end
end

function increaseImage(imageDirectory, imageCell, imageName, imageExtension)
    if size(imageCell,3) ~= 1
        imageCell = rgb2gray(imageCell);
    end
    gamma = 0.5;
    while gamma <= 2
        im = imadjust(imageCell,[],[],gamma);
        s = strcat(imageDirectory,'/',imageName,'-Gamma-',num2str(gamma),imageExtension);
        imwrite(im, char(s));
        gamma = gamma + 1;
    end
    
    filterSize = 3;
    f = fspecial('average',filterSize);
    im = imfilter(imageCell,f);
    s = strcat(imageDirectory,'/',imageName,'-Average-',num2str(filterSize),imageExtension);
    imwrite(im, char(s));
    
    sigma = 0.5;
    while sigma <= 2 
        im = imgaussfilt(imageCell, sigma);
        s = strcat(imageDirectory,'/',imageName,'-Gaussian-',num2str(sigma),imageExtension);
        imwrite(im, char(s));
        sigma = sigma + 0.5;
    end
    
    filterSize = 3; 
    im = medfilt2(imageCell, [filterSize filterSize]);
    s = strcat(imageDirectory,'/',imageName,'-Median-',num2str(filterSize),imageExtension);
    imwrite(im, char(s));
        
    f = fspecial('laplacian',0.2);
    im = imfilter(imageCell,f);
    sharpened = imageCell - im;
    s = strcat(imageDirectory,'/',imageName,'-Laplacian',imageExtension);
    imwrite(sharpened, char(s));
end