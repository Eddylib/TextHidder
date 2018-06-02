function [  ] = write_to_file( filename,data )
%WRITE_TO_FILE 此处显示有关此函数的摘要
%   此处显示详细说明
    fid = fopen(filename,'w');
    fprintf(fid,data);
    fclose(fid);
end
