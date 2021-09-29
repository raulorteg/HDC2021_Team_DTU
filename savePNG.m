function savePNG(im, outputFolder, filename)
    [~, name, ~] = fileparts(filename);
    
    imwrite(im,[outputFolder, '/', [name, '.png']]);
end