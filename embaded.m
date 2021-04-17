function [ img_embaded,S] = embaded(img,data,draw_band_histogram)
%EMBADED 此处显示有关此函数的摘要
%   此处显示详细说明
    LS = liftwave('cdf2.2','Int2Int');
    [CA,CH,CV,CD] = lwt2(img,LS);
    %把数据藏在CH,CV,CD合并起来的波段里
    mat_merged = [CH,CV,CD];
    [~,wori] = size(CH);
    [h_band,w_band] = size(mat_merged);
    data = strcat(data,[char(65535),char(65535)]);
    M = length(data)*16;
    %为了给起始标志位留出空间，假定数据都在-20~20波段内
    %规定数据不可超出最大空间减去预留位
    MaxSpace = w_band * h_band - 64*40;
    T = 3;
    if(M > w_band * h_band)
        disp('warnning: no enough space');
        disp(['max space: ',num2str(MaxSpace),' bits']);
        return
    else
        disp(['max space: ',num2str(MaxSpace),' bits']);
        disp(['to be embaded payload: ',num2str(M),' bits']);
    end
    while(sum(sum((mat_merged >= -1*T)  .* (mat_merged <= T))) < M)
        T = T + 1;
    end
    if(draw_band_histogram == 1)
        figure,histogram(mat_merged,'BinWidth',1)
        title('Wavelet (CDF(2,2)) subbands histogram of origing image')
    end
    Peak = T;
    bitembaded = 0;
    S = Peak;
    while(bitembaded < M)
        [mat_merged,~] = shift_hist(mat_merged,Peak);
        [ mat_merged,bitembaded ] = embaded_one_shift(mat_merged,data,bitembaded,Peak);
        if(bitembaded >= M)
            S = Peak;
            mat_merged = set_end_mark(mat_merged,S);
            break;
        end
        if(Peak > 0)
            Peak = -1*Peak;
        elseif(Peak < 0)
            Peak = -1*Peak - 1;
        else
            S = Peak;
            mat_merged = set_end_mark(mat_merged,S);
            disp('warnning: no enough space, data was not fully embaded. so data extraction might faild.');
            break;
        end
    end
    if(draw_band_histogram == 1)
        figure,histogram(mat_merged,'BinWidth',1);
        title('Wavelet (CDF(2,2)) subbands histogram of embaded image')
    end
    CH = mat_merged(:,1:wori);
    CV = mat_merged(:,wori+1:2*wori);
    CD = mat_merged(:,2*wori+1:end);
    img_embaded = ilwt2(CA,CH,CV,CD,LS);
end
function [ mat_emb,bitidx ] = embaded_one_shift(mat_emb,data,bitidx,Z)
        bitidx_max = length(data)*16 - 1;
        [h,w] = size(mat_emb);
        bit1_cont = 0;
        cnt = 0;
        for ii = 1:h
            for jj = 1:w
                if(mat_emb(ii,jj) == Z)
                    if(cnt < 64)
                        %前64bit用来存储prefix，给extract程序提示S的位置
                        %这里全部设置为全0，当结束时，embaded会在相应的
                        %Z处将这里全置为01相间的序列从而达到目的
                        cnt = cnt + 1;
                        continue
                    else
                        bit = pop_bit(data,bitidx);
                        if(bit == 1)
                            mat_emb(ii,jj) = Z + sign(Z);
                            bit1_cont = bit1_cont + 1;
                        else
                            bit1_cont = 0;
                        end
                        bitidx = bitidx + 1;
                        if(bitidx > bitidx_max)
                            return
                        end
                    end
                end
            end
        end
end

function [mat_emb] = set_end_mark(mat_emb,Z)
    cnt = 0;
    [h,w] = size(mat_emb);
    for ii = 1:h
        for jj = 1:w
            if(mat_emb(ii,jj) == Z)
                if(cnt < 16)
                    %前64bit用来存储prefix，给extract程序提示S的位置
                    %这里全部设置为全0，当结束时，embaded会在相应的
                    %Z处将这里全置为1从而达到目的
                    if(mod(cnt,2) == 1)
                        mat_emb(ii,jj) = Z + sign(Z);
                    end
                else
                    return
                end
                cnt = cnt + 1;
            end
        end
    end
end

