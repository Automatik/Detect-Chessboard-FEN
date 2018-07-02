function createDescriptorFile()
  %Calculate the images' descriptors and save them to file
  
  %Read the images' paths contained in the dataset
  [images, ~] = readlists();
  
  nimages = numel(images);
  
  %Parameters used by the function to extract HOG features and to know how
  %many zeros to allocate for the matrix hogFeatures
  ImageSize = [125 125];
  CellSize = [16 16];
  BlockSize = [4 4];
  BlockOverlap = ceil(BlockSize/2);
  NumBins = 9;
  BlocksPerImage = floor((ImageSize./CellSize - BlockSize)./(BlockSize - BlockOverlap) + 1);
  N = prod([BlocksPerImage, BlockSize, NumBins]);
  
  hogFeatures = zeros(nimages,N);
  
  
  for n = 1 : nimages
    
    im = imread([images{n}]);
    if size(im,3) ~= 1
        im = rgb2gray(im);
    end
  
    %Extracting HOG features
    hogFeatures(n,:)= extractHOGFeatures(im,'CellSize',CellSize,'BlockSize',BlockSize);
  
  end
     
  %Saving descriptors to file
  save('descriptors.mat','hogFeatures');

end