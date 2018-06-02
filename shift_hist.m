function [ img,num ] = shift_hist(img,P)
%SHIFT_HIST 此处显示有关此函数的摘要
%   此处显示详细说明
    num = sum(sum(abs(img - P) < 0.005));
    if(P >= 0)
        img(img > P) = img(img > P) + 1;
    elseif(P < 0)
        img(img < P) = img(img < P) - 1;
    end
end