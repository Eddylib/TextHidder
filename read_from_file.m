function [ data ] = read_from_file( filename )
%READ_FROM_FILE �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    fid = fopen(filename,'r','n','UTF-8');
    data = fread(fid)';
    data = native2unicode(data,'UTF-8');
    write_to_file('result.txt',data);
end

