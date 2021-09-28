function savePNG(final, outputFolder, filename)
    temp = split(filename, '.');
    filename = char(temp(1,:));
    savepath = join([outputFolder, '/', filename, '.png']);
    imwrite(final, savepath);
end