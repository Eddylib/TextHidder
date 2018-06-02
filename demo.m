%% 程序配置，数据读取，转换
clear
clc
if_draw_figures = 1;
if_print_result = 1;
if_save_to_file = 1;

file_name_data_to_be_embaded = 'data.txt';
file_name_image = 'lenna.pgm';
file_name_extracted_result = 'result.txt';

data = read_from_file(file_name_data_to_be_embaded);
% disp(data)
img = double(imread(file_name_image));
[w,h] = size(img);

%%
%主要函数，嵌入数据，返回嵌入后的图片，以及模型内参数T
[img_embaded,S] = embaded(img,data,if_draw_figures);


%%
%主要函数，通过嵌入后的图片来提取数据
%说明：论文中S必须是已知的，
%不过可以在直方图的每个系数区嵌入数据时
%加入标识数据（64bit的01相间串）
%从而告知extract程序S的具体位置，
%所以我的实现，直接可以从图像中恢复数据而不需要S
[data_extracted,img_reconstructed] = extract(img_embaded);
write_to_file(file_name_extracted_result,data_extracted);

%%
%结果打印
if(if_draw_figures)
    figure,imagesc(img); 
    colormap gray;
    title('origin image')
    figure,imagesc(img_embaded);
    colormap gray;
    title('embaded image')
    figure,imagesc(img_reconstructed);
    colormap gray;
    title('reconstructed image')
    figure,imagesc(img-img_embaded); 
    colormap gray;
    title('origin image - embaded image')
end

peak_val = max(max(img));
MSE_o_e = sum(sum((img - img_embaded).^2))/(w*h);
PSNR = 10*log10(peak_val*peak_val/MSE_o_e);
MSE2_o_r = sum(sum((img - img_reconstructed).^2))/(w*h);

if(if_print_result)
    disp(['first 10 char extracted data from embaded image:', data_extracted(1:10)])
    disp(['PSNR: ' num2str(PSNR)])
    disp(['MSE of origin image and embaded image: ' num2str(MSE_o_e)])
    disp(['MSE of origin image and reconstracted image: ' num2str(MSE2_o_r)])
    disp(['origin image itensity range: ' ...
        num2str(min(min(img))) '-' ...
        num2str(max(max(img)))])
    disp(['embaded image itensity range: ' ...
        num2str(min(min(img_embaded))) '-' ...
        num2str(max(max(img_embaded)))])
end
