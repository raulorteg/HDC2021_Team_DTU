function deblur(inputFolder, outputFolder, filename, step)
    
    %%% Parameters for the Deblurring algorithm
    parameters = readtable('lookup_table.csv');
    mu_r = parameters(step+1,:).radius;
    lambda_final = parameters(step+1,:).lambda_final; % 
    lambda_tv = parameters(step+1,:).lambda_tv;
    delta_r = parameters(step+1,:).delta_r;
    Sr = 100;
    y = 800;
    K = 10;
    
    %%% Prepare the algorithm: Rescale the image and initialize x, b
    im = im2double(imread(join([inputFolder, '/', filename])));
    
    if step == 0
        savePNG(im, outputFolder, filename);
        return
    end
    
    sigma_e = 0.0241;
    
    %%% boolean flag to chose if use cholesky, and verbosity
    use_chol = 1;
    verbose = 0;
%     if use_chol == 0
%         lambda_tv = lambda_tv*sigma_e^2;
%     end
    
    % b = rescale(im_blurred_noise); % scale between 0 and 1.
    b = im(y,:);
    
    % Initial guess
    x = zeros(size(b));
    
    %%% Execution of the algorithm
    % ----------------------------------------------------------
    if verbose == 1
        fprintf('iter: %s/%s, mu_r: %s, delta_r: %s\n', num2str(0), num2str(K), num2str(mu_r), num2str(delta_r));
    end
    
    % arrays to store partial results in execution
    mu_r_hist = zeros(1,K+1); mu_r_hist(1) = mu_r;
    delta_r_hist = zeros(1,K+1); delta_r_hist(1) = delta_r;
    for k = 1:K
        
        %%% Update x:
        % Given the previous x, radious, noise estimations
        % condtions perform the new update of x, and return the value of the
        % objective function f_vec
        x = x_update(x, mu_r, delta_r, b, sigma_e, Sr, lambda_tv, use_chol);
        
        % Apply a smoothing filter to reduce the noise before feeding
        % the processed image to the radious and noise estimation function
        x = medfilt1(x, 5, 'truncate');
        % x = imbilatfilt(x,2*sigma_e,4);
        
        %%% Update r:
        % Given the previous x, radious, noise estimations
        % condtions perform the new update of the mu_r, delta_r
        [mu_r, delta_r] = r_update_1d(x, b, mu_r, delta_r, sigma_e, Sr);
        
        % print progress
        if verbose == 1
            fprintf('iter: %s/%s, mu_r: %s, delta_r: %s\n', num2str(k), num2str(K), num2str(mu_r), num2str(delta_r));
        end
        
        % append partial results to the history vectors to keep track
        % of progress
        mu_r_hist(k+1) = mu_r;
        delta_r_hist(k+1) = delta_r;
    end
    
    x0 = zeros(size(im));
    final = FISTA_TVsmooth(mu_r, im, lambda_final, x0);
    final = imsharpen(final);
    
    % Save image
    savePNG(final, outputFolder, filename);
end