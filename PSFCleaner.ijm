Stack.getDimensions(width, height, channels, slices, frames);
run("Duplicate...", "duplicate");
run("Median 3D...", "x=3 y=3 z=3");
run("Reslice [/]...", "start=Top avoid");
//Array of slices?
run("Make Substack...", "slices=1,2,3,4,5,6,7,8,9,10,218,219,220,221,222,223,224,225,226,227");

run("Duplicate...", "duplicate");
run("Abs", "stack");
run("Macro...", "code=abs(v-100) stack");
run("Square Root", "stack");
run("Z Project...", "projection=[Max Intensity]");
run("Multiply...", "value=3.000");

selectImage("Substack (1,2,3,4,5, ... 227)");
run("Z Project...", "projection=[Average Intensity]");
imageCalculator("Add create 32-bit", "AVG_Substack (1,2,3,4,5, ... 227)","MAX_Substack (1,2,3,4,5, ... 227)-1");

selectImage("Result of AVG_Substack (1,2,3,4,5, ... 227)");

imageCalculator("Subtract create 32-bit stack", "Reslice of PSF_CH0-1","Result of AVG_Substack (1,2,3,4,5, ... 227)");
selectImage("Result of Reslice of PSF_CH0-1");
run("Reslice [/]...", "output=0.104 start=Top avoid");

run("Duplicate...", "duplicate");
run("Macro...", "code=[if(v<=0) v=0] stack");

run("CLIJ2 Macro Extensions","cl_device=");
image1 = "Reslice of Result-1";
Ext.CLIJ2_push(image1);
image2 = "greater_constant";
constant = 1.0;
Ext.CLIJ2_greaterConstant(image1, image2, constant);
image3 = "connected_components_label";
Ext.CLIJ2_connectedComponentsLabelingBox(image2, image3);
Ext.CLIJ2_pull(image3);
run("Keep Largest Label");
run("3D Binary Close Labels", "radiusxy=3 radiusz=3 operation=Close");

selectImage("AVG_Substack (1,2,3,4,5, ... 227)");
run("Reslice [/]...", "output=0.104 start=Top avoid");
run("Z Project...", "projection=[Average Intensity]");
run("Size...", "width=512 height=227 depth=62 interpolation=None");
imageCalculator("Multiply create 32-bit stack", "PSF_CH0.tif","CloseLabels");
imageCalculator("Subtract create 32-bit stack", "Result of PSF_CH0.tif","AVG_Reslice of AVG_Substack(1,2,3,4,5,..");
run("Macro...", "code=[if(v<=0) v=0] stack");

run("3D Maxima Finder", "minimmum=1 radiusxy=10 radiusz=10 noise=100");
selectWindow("Result of Result of PSF_CH0.tif")
psf_raw=getTitle();
max_int_peak_x = getResult('X', 0);
max_int_peak_y = getResult('Y', 0);
max_int_peak_z = getResult('Z', 0);

zshift=floor((slices-(max_int_peak_z*2))/2);

if (zshift > 0) {
run("Duplicate...", "duplicate range="+(slices-zshift+1)+"-"+slices);
selectImage(psf_raw);
run("Duplicate...", "duplicate range=1-"+(slices-zshift));
} else if (zshift < 0 ) {
run("Duplicate...", "duplicate range="+abs(zshift+1)+"-"+slices);
selectImage(psf_raw);
run("Duplicate...", "duplicate range=1-"+abs(zshift));
}
run("Concatenate...", "open image1=[Result of Result of PSF_CH0-1.tif] image2=[Result of Result of PSF_CH0-2.tif] image3=[-- None --]");

selectImage("Untitled");
xshift=floor((width-(max_int_peak_x*2))/2);
if (xshift < 0) {
	makeRectangle(0, 0, abs(xshift), height);
	run("Duplicate...", "duplicate");
} else if (xshift > 0) {
	makeRectangle(width-xshift, 0, width, height);	
	run("Duplicate...", "duplicate");
}
selectImage("Untitled");
run("Make Inverse");
run("Crop");
if (xshift < 0) {
	run("Combine...", "stack1=Untitled stack2=Untitled-1");
} else if (xshift > 0) {
	run("Combine...", "stack1=Untitled-1 stack2=Untitled");
}

selectImage("Combined Stacks");
yshift=floor((height-(max_int_peak_y*2))/2);
if (yshift < 0) {
	makeRectangle(0, 0, width, abs(yshift));
	run("Duplicate...", "duplicate");
} else if (yshift > 0) {
	makeRectangle(0, height-yshift, width, height);	
	run("Duplicate...", "duplicate");
}
selectImage("Combined Stacks");
run("Make Inverse");
run("Crop");
if (yshift < 0) {
	run("Combine...", "stack1=[Combined Stacks] stack2=[Combined Stacks-1] combine");
} else if (yshift > 0) {
	run("Combine...", "stack1=[Combined Stacks-1] stack2=[Combined Stacks] combine");
}



