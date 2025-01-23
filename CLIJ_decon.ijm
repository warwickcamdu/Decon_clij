// To make this script run in Fiji, please activate 
// the clij and clij2 update sites in your Fiji 
// installation. Read more: https://clij.github.io

// Generator version: 2.5.1.6

//Designed to work with OMERO batch process plugin: https://github.com/GReD-Clermont/omero_batch-plugin?tab=readme-ov-file

//Define inputs: path to psf file and number of iterations of Richardson-Lucy Deconvolution
#@ File (label = "Select PSF file:", style = "file") psf_path
#@ Integer (label = "Iterations:", min=0, max=5000, value=10) num_iterations

// Init GPU
run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();

Ext.CLIJ2_getGPUProperties(gpu, memory, opencl_version);
print("GPU: " + gpu);
print("Memory in GB: " + (memory / 1024 / 1024 / 1024) );
print("OpenCL version: " + opencl_version);

// Load image
image_stack = getTitle();
Stack.getDimensions(width, height, image_channels, slices, frames);
run("Split Channels");

// Load psf
open(psf_path);
psf_stack = getTitle();
print("PSF: "+psf_stack);
print("Number of iterations: "+num_iterations);
Stack.getDimensions(width, height, psf_channels, slices, frames);
run("Split Channels");

if (psf_channels != image_channels){
	exit("Number of channels in image and psf are different");
}

//Initialise string for merging channels
merge_string="";
//Deconvolve all channels one at a time
for (i = 1; i <= image_channels; i++) {
image="C"+i+"-"+image_stack;
selectWindow(image);
//Get current LUT of channel
getLut(reds, greens, blues);
psf="C"+i+"-"+psf_stack;
time=getTime();
Ext.CLIJ2_push(image);
Ext.CLIJ2_push(psf);
print("Pushing image and psf took " + (getTime() - time) + " msec");

// Richardson Lucy Deconvolution
time = getTime();
Ext.CLIJx_imageJ2RichardsonLucyDeconvolution(image, psf, output_image, num_iterations);
print("Deconvolution took " + (getTime() - time) + " msec");
Ext.CLIJ2_release(image);
close(image);
Ext.CLIJ2_release(psf);
close(psf);
Ext.CLIJ2_pull(output_image);
Ext.CLIJ2_release(output_image);

rename("CLIJx_Decon_"+image);
//Apply LUT from original image
setLut(reds, greens, blues);
merge_string = merge_string + "c"+i+"=[CLIJx_Decon_"+image+"] ";
}

//Merge deconvolved channels back together
run("Merge Channels...", merge_string+"create");
rename("Decon_"+image_stack);
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Deconvolved with CLIJx_imageJ2RichardsonLucyDeconvolution on "+year+"-"+month+1+"-"+dayOfMonth"
//Further processing steps



