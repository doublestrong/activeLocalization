function pdf = kde(x, supports, kernel_bandwidth)
    %% Information
    % The function uses Gaussian kernel to reconstruct the pdf
    % Inputs
    %   x - the locations at which the pdf should be evaluated
    %       Each row is a sample
    %       Each  is a dimension
    %   supports - the locations of samples for kernel density estimation
    %       Each row is a sample
    %       Each column is a dimension
    %   kernel_bandwidth - the standard deviation of the kernel
    % Output
    %   pdf - the probability density at x
    %       A column vector
    % Notes
    %   The function does not check if dimensionality is correct
    
    %% Computation
    num_locations = size(x, 1);
    num_supports = size(supports, 1);
    dim = size(x, 2);
    pdf = exp(-sum((reshape(x, num_locations, 1, dim) ...
        - reshape(supports, 1, num_supports, dim)).^2, 3) ...
        / (2 * kernel_bandwidth^2));
    pdf = sum(pdf, 2) / num_supports ...
        / (sqrt(2 * pi) * kernel_bandwidth)^dim;
end