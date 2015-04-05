function [image_matrix,image_names]=load_all_images_from_dir(directory)

dir_name=dir(directory);
counter_temp=0;

for i = 1:length(dir_name)
    curr_file_name=dir_name(i).name;
    vext = strfind(curr_file_name,'.bmp');
    if isempty(vext)
        vext = strfind(curr_file_name,'.BMP');
    end
    if ~isempty(vext)
        counter_temp=counter_temp+1;
        image_matrix(counter_temp,:,:,:)=mat2gray(double(imread(curr_file_name)));
        eval(sprintf('image_names(%s)={''%s''};',num2str(counter_temp),curr_file_name));
    end

    %image_names;
end
