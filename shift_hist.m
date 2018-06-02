function [ img,num ] = shift_hist(img,P)
%SHIFT_HIST �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    num = sum(sum(abs(img - P) < 0.005));
    if(P >= 0)
        img(img > P) = img(img > P) + 1;
    elseif(P < 0)
        img(img < P) = img(img < P) - 1;
    end
end