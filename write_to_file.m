function [  ] = write_to_file( filename,data )
%WRITE_TO_FILE �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    fid = fopen(filename,'w');
    fprintf(fid,data);
    fclose(fid);
end
