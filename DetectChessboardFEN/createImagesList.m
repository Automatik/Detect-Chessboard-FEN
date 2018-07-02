%For every image(chessboard's cell) in the dataset writes in images.list
%the path of that image and in the file labels.list the class of that piece
%(es. Bishop, EmptySquare, ecc..)

if exist('images.list', 'file') == 2
    delete('images.list');
end
if exist('labels.list', 'file') == 2
    delete('labels.list');
end
fi = fopen('images.list','a');
fl = fopen('labels.list','a');
cd Dataset
folders = dir;
for i = 3:length(folders) %To avoid directories '.' e '..'
    name = folders(i).name;
    files = dir(folders(i).name);
    n = length(files);
    images = string([n-2,1]);
    names = strings([n-2,1]);
    for j = 3:n
        file = files(j).name;
        extension = file((length(file)-2):length(file));
        
        images(i) = "Dataset/"+name+"/"+files(j).name;
        names(i) = name;
        fprintf(fi,'%s\n',images(i));
        fprintf(fl,'%s\n',names(i));
    end
end

fclose(fi);
fclose(fl);
cd ..