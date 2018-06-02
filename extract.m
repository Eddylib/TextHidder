function [ data,img_reconstructed ] = extract(embaded)
%EXTRACT 此处显示有关此函数的摘要
%   此处显示详细说明
    LS = liftwave('cdf2.2','Int2Int');
    [CA,CH,CV,CD] = lwt2(embaded,LS);
    [~,wori] = size(CH);
    mat_merged = [CH,CV,CD];
    Tembaded = 3;
%     figure,histogram(mat_merged,'BinWidth',1)
    S = find_s(mat_merged);
    if(S == 99999)
        disp('error cannot find start sequence.')
        return
    end
    mat_merged = clear_start_mark(mat_merged,S);
    Peak = S;
    data = [];
    bit_extracted = 0;
    while(1)
%         figure,histogram(mat_merged,'BinWidth',1)
        [ mat_merged,bit_ret,bit_extracted] = extract_one_shift(mat_merged,Peak,bit_extracted);
        data = [bit_ret,data];
        [mat_merged,~] = shift_hist_reverse(mat_merged,Peak);
        if(Peak == Tembaded)
            break;
        end
        if(Peak > 0)
            Peak = -1*Peak - 1;
        else
            Peak = -1*Peak;
        end
    end
    data = buff2_str(data,length(data));
    CH = mat_merged(:,1:wori);
    CV = mat_merged(:,wori+1:2*wori);
    CD = mat_merged(:,2*wori+1:end);
    img_reconstructed = ilwt2(CA,CH,CV,CD,LS);
end
function [ mat_emb,bit_seq_ret,bit_extracted ] = extract_one_shift(mat_emb,Z,bit_extracted)
        [h,w] = size(mat_emb);
        buff = zeros(1,h*w);
        bit1_cont = 0;
        endloop = 0;
        buff_idx = 1;
        cnt = 0;
        for ii = 1:h
            for jj = 1:w
                if(mat_emb(ii,jj) == Z+sign(Z) || mat_emb(ii,jj) == Z)
                    if(cnt >= 64)
                        if(mat_emb(ii,jj) == Z+sign(Z))
                            bit = 1;
                            mat_emb(ii,jj) = Z;
                            bit1_cont = bit1_cont + 1;
                        elseif(mat_emb(ii,jj) == Z)
                            bit = 0;
                            bit1_cont = 0;
                        end
                        buff(buff_idx) = bit;
                        buff_idx = buff_idx + 1;
                        if(bit1_cont >= 32)
                            endloop = 1;
                        end
                    end
                    cnt = cnt + 1;
                end
                if(endloop == 1)
                    break;
                end
            end
                if(endloop == 1)
                    break;
                end
        end
        bit_extracted = bit_extracted + buff_idx - 1;
        bit_seq_ret = buff(1:buff_idx-1);
%         str_ret = buff2_str(buff,buffidx);
end

function [ str_ret ] = buff2_str(buff,len)
    double_ret = linspace(0,0,len/8);
    double_idx = 1;
    double_value = 0;
    bit_idx = 0;
    for ii = 1:len
        double_value = double_value * 2 + buff(ii);
        bit_idx = bit_idx + 1;
        if(bit_idx == 16)
            if(double_value == 65535)
                break;
            end
            double_ret(double_idx) = double_value;
            double_value = 0;
            double_idx = double_idx + 1;
            bit_idx = 0;
        end
    end
    str_ret = char(double_ret);
end
function [S] = find_s(mat_emb)
    for Z=-30:30
        if_start = if_start_here(mat_emb,Z);
        if(if_start == 1)
            S = Z;
            break
        end
    end
end
function [if_start] = if_start_here(mat_emb,Z)
    if_start = 9999999;
    cnt = 0;
    next_should = 1;
    [h,w] = size(mat_emb);
    for ii = 1:h
        for jj = 1:w
            if(mat_emb(ii,jj) == Z+sign(Z) || mat_emb(ii,jj) == Z)
                if(mat_emb(ii,jj) == Z+sign(Z))
                    bit = 0;
                elseif(mat_emb(ii,jj) == Z)
                    bit = 1;
                end
                if(bit ~= next_should)
                    return
                else
                    next_should = ~next_should;
                end
                cnt = cnt + 1;
                if(cnt == 16)
                    if_start = 1;
                    return
                end
            end
        end
    end
end
function [mat_emb] = clear_start_mark(mat_emb,Z)
    cnt = 0;
    [h,w] = size(mat_emb);
    for ii = 1:h
        for jj = 1:w
            if(mat_emb(ii,jj) == Z+sign(Z) || mat_emb(ii,jj) == Z)
                if(mat_emb(ii,jj) == Z+sign(Z))
                    mat_emb(ii,jj) = Z;
                elseif(mat_emb(ii,jj) == Z)
                end
                cnt = cnt + 1;
                if(cnt == 64)
                    return
                end
            end
        end
    end
end
