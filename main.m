function main(inputFolder,outputFolder,categoryNbr)
    % List all png in the input Folder, deblur them and save the deblurred
    % images with the same filename as original in outputFolder
    %
    % inputFolder: string path to folder of blurred images
    % outputFolder: string path to folder where deblurred images are saved
    % categoryNbr: int level of the steage of the competition
    
    addpath('egrssMatlab');
    
    % Parameter validation.
    categoryNbr = floor(categoryNbr);
    if categoryNbr < 0 || categoryNbr > 20
        error('Invalid category number');
    end
    if ~isfolder(inputFolder)
        error('Input folder does not exist');
    end
    if ~isfolder(outputFolder)
        error('Output folder does not exist');
    end
    
    verbose = 1; % switch to 0 to remove prints
    listing = dir(join([inputFolder, '/*.tif']));
    if isempty(listing)
        error('No *.tif files found at <inputFolder> path. Is the path correct?');
    end
    tic
    for idx=1:length(listing)
        filename = listing(idx).name;
        if verbose == 1
            fprintf('Deblurring image %s (%s/%s)\n', filename, int2str(idx), int2str(length(listing)));
        end
        deblur(inputFolder, outputFolder, filename, categoryNbr);
    end
    fprintf('--- finished %.2f ---\n', toc);
end