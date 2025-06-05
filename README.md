# Decon_clij

ImageJ Macro to deconvolve data using CLIJ Richardson Lucy implementation. 

## Requirements
Install CLIJ2 and optional extensions in Fiji: [https://clij.github.io/clij-docs/installationInFiji.html](https://clij.github.io/assistant/installation)

Install OMERO batch plugin (optional, needed for batch processing): https://github.com/GReD-Clermont/omero_batch-plugin?tab=readme-ov-file 

## Data
Requires PSF image file with same number of channels as the image to be deconvolved. This should be saved locally.

## Usage Instructions
To run on a single local image (can be useful for testing input arguments):
1. Open the image and the macro in Fiji.
2. Click run on the macro. You will be asked for PSF files - you will need one for each channel and they need to be entered in the order of the channels. You will also need to enter the number of iterations to run the algorithm and optionally you can choose to save the results after x interations. If you just want the final result set this to 0.
3. After processing the deconvolved image will show

To run with the OMERO batch plugin: 
1. Open the OMERO batch plugin (Plugins > OMERO > Batch process...)
2. Select if your data is local on OMERO.
3. Select your input data.
4. Select the macro (CLIJ_decon.ijm) and click set arguments. A dialog box will appear and you can select your PSF files and how many iterations as above.
5. The macro returns new image and a log file, tick these two boxes.
6. Choose a suffix for your files if you wish (the macro prefix the file names with "Decon")
7. Choose whether to save the files locally or on to OMERO and where you want to save them
8. Click start and wait for processing. A log file will show progress and each files are saved as it is processed.

## References
Robert Haase, Loic Alain Royer, Peter Steinbach, Deborah Schmidt, Alexandr Dibrov, Uwe Schmidt, Martin Weigert, Nicola Maghelli, Pavel Tomancak, Florian Jug, Eugene W Myers. CLIJ: GPU-accelerated image processing for everyone. Nat Methods 17, 5–6 (2020) doi:10.1038/s41592-019-0650-1

Pouchin P, Zoghlami R, Valarcher R et al. Easing batch image processing from OMERO: a new toolbox for ImageJ [version 2; peer review: 2 approved]. F1000Research 2022, 11:392 (https://doi.org/10.12688/f1000research.110385.2)

Schindelin, J., Arganda-Carreras, I., Frise, E., Kaynig, V., Longair, M., Pietzsch, T., … Cardona, A. (2012). Fiji: an open-source platform for biological-image analysis. Nature Methods, 9(7), 676–682. doi:10.1038/nmeth.2019
