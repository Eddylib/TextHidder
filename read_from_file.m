function [ data ] = read_from_file( filename )
%READ_FROM_FILE 此处显示有关此函数的摘要
%   此处显示详细说明
    fid = fopen(filename,'r','n','UTF-8');
    data = fread(fid)';
    data = native2unicode(data,'UTF-8');
    write_to_file('result.txt',data);
end

