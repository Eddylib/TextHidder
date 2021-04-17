function [ bit] = pop_bit( str,bitidx )
%STR2BIN 此处显示有关此函数的摘要
%   此处显示详细说明
     charidx = floor(bitidx/16)+1;
     bitidx_ = 15-mod(bitidx,16);
     char_ = int32(str(int32(charidx)));
     char_s = bitshift(char_,-1*bitidx_);
     bit = mod(char_s,2);
end

