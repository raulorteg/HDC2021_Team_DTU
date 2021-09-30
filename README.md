# HDC2021_Team_DTU

## About
This repository contains the submission for the Helsinki Deblur Challenge 2021 (HDC2021) from Team 2 of Techinal University of Denmark (DTU), Kongens Lyngby, Denmark.
The authors of this repository are Frederik Hagsholm Pedersen, Mads Emil Dahlgaard, Mads Thorstein Roar Henriksen and Raul Ortega Ochoa.

## Description of the algorithm.

According to the work introduced in [1], we apply it for image deblurring problem with uncertain point spread function (PSF).
Since the competition dataset as well as PSFs were taken by camera, PSFs are not accurate, which would influence the deblurring results significantly.
Our focus is to test the idea from [1] on image deblurring problem and to see how to estimate PSF from degraded images.

We assume that the blurring process is the out-of-focus blur, and PSF is a normalized disk with the radius 
$r \in R$. We apply the method proposed in [1] to estimate the radius r. The method combines the idea of the approximation error
approach in Bayesian framework with the variational methods, and quantifies the uncertainty in r via a model-discrepancy term.

Due to the high resolutions, in order to reduce the computational complexity, we apply the method in [1] on 1D signals,
which are several rows drawn from the degraded image. After the radius is estimated, in principle we can apply any
variational methods to deblur the image. Here, we simply utilize the L2-TV method followed by image enhancement technique.

## Installation 
Clone the repository ```git clone https://github.com/raulorteg/HDC2021_Team_DTU ```

## Usage
Run in Matlab ``` main(inputfolder, outputfolder, step)```

where:
* ```inputfolder```: string path to the folder with the blurred images (e.g 'blurred/step8_examples')
* ```outputfolder```: string path to the folder where the deblurred images are to be saved (e.g 'deblurred/step8_examples')
* ```step```: int variable of the step level of the competition

```main(...)``` lists all *.tif files in the <inputfolder> directory and calls
``` deblur(...) ``` on each of this *.tif files, this function then does the deblurring
and saves the resulting deblurred image with the same filename on the <outputfolder>

## Examples

Below, examples for different step difficulties can be seen together with the deblurred images outputted from the algorithm.

![examples](files/steps_examples.png)

## References
[1] Nicolai Andre Brogaard Riis, Yiqiu Dong and Per Christian Hansen, Computed tomography with view angle estimation using uncertainty quantification, Inverse Problems, Vol. 37, pp. 065007, 2021.


