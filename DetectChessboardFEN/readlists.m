function [images,labels]=readlists()
  if ~(exist('images.list','file') == 2) || ~(exist('labels.list','file') == 2)
      createImagesList
  end
  f=fopen('images.list');
  z = textscan(f,'%s');
  fclose(f);
  images = z{:}; 

  f=fopen('labels.list');
  l = textscan(f,'%s');
  labels = l{:};
  fclose(f);
end