// To make this script run in Fiji, please activate 
// the clij and clij2 update sites in your Fiji 
// installation. Read more: https://clij.github.io

// Generator version: 2.5.1.6

//Designed to work with OMERO batch process plugin: https://github.com/GReD-Clermont/omero_batch-plugin?tab=readme-ov-file

//Define inputs: path to psf file and number of iterations of Richardson-Lucy Deconvolution
#@ String (visibility=MESSAGE, value="<html>Select PSF file in order for each channel you want to deconvolve.</html>", required=false) msg
#@ File[] (label="Select PSF files", style="files") psf_paths
#@ Integer (label = "Iterations:", min=0, max=5000, value=10) num_iterations
#@ Integer (label = "Save output every x iterations, x:", min=0, max=50, value=1) out_iter
#@ String (visibility=MESSAGE, value="<html>To only output final result set x to 0.</html>", required=false) msg


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
if (image_channels > 1){
	run("Split Channels");
} else {
	selectWindow(image_stack);
	rename("C1-"+image_stack);
}

if (lengthOf(psf_paths) != image_channels){
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
psf_path=psf_paths[i-1];
open(psf_path);
psf = getTitle();
print("PSF: "+psf);
print("Number of iterations: "+num_iterations);
time=getTime();
Ext.CLIJ2_push(image);
Ext.CLIJ2_push(psf);
print("Pushing image and psf took " + (getTime() - time) + " msec");

// Richardson Lucy Deconvolution
time = getTime();
if (out_iter == 0) {
	out_iter = num_iterations;
}
num_decon=floor(num_iterations/out_iter);
extra_iterations=num_iterations-(out_iter*num_decon);
for (j = 1; j <= num_decon; j++){
	Ext.CLIJx_deconvolveRichardsonLucyFFT(image, psf, output_image, out_iter);
	Ext.CLIJ2_release(image);
	close(image);
	image=Ext.CLIJ2_pull(output_image);
	//run("Duplicate...", "title=CLIJx_Decon_iter"+(out_iter*j)+"_C"+i+"_"+image_stack+" duplicate");
	rename("CLIJx_Decon_iter"+(out_iter*j)+"_C"+i+"_"+image_stack);
	Ext.CLIJ2_push(image);
}
if (extra_iterations > 0) {
	Ext.CLIJx_deconvolveRichardsonLucyFFT(image, psf, output_image, extra_iterations);
}
print("Deconvolution took " + (getTime() - time) + " msec");
Ext.CLIJ2_release(image);
close(image);
Ext.CLIJ2_release(psf);
close(psf);
Ext.CLIJ2_pull(output_image);
Ext.CLIJ2_release(output_image);

rename("CLIJx_Decon_C"+i+"-"+image_stack);
//Apply LUT from original image
setLut(reds, greens, blues);
merge_string = merge_string + "c"+i+"=[CLIJx_Decon_C"+i+"-"+image_stack+"] ";
}

//Merge deconvolved channels back together
run("Merge Channels...", merge_string+"create");
rename("Decon_"+image_stack);
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Deconvolved with CLIJx_imageJ2RichardsonLucyDeconvolution on "+year+"-"+month+1+"-"+dayOfMonth);
//Further processing steps



