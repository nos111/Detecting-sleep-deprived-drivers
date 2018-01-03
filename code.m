Project script
clear all; %close any video or connection to the robot
video=webcam; %intiaite the camera variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% This part of the code calibrates the threshold and formfactor of the %
% eyes to be used during the continues control of the eyes detection %
% %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
display('open your eyes'); %ask the user to open his eyes for the calibration
pause(1); % wait for one second till the user open his eyes
threshold = 0.0; %initiate the threshold variable
im=snapshot(video); %take a photo with the eyes open
%detect a pair of eyes
EyeDetect = vision.CascadeObjectDetector('EyePairBig');
%find the eyes coordinates in the photo
BB=step(EyeDetect,im);
try % try to find the eyes
im = imcrop(im,BB); %crop the photo with only the eyes
im = rgb2gray(im); %convert it to RGB image
catch …
display('failed code 1'); %if we couldn’t find the eyes display the error and quit
return
end
numlabels = 0; %initiate the number of labels variable
thresholdStep = 0.005; %the threshold will be increased by this number in the loop
% Calibrate
while numlabels < 2 %while we have less than 2 BLOBS
%convert the image to black and white with the threshold
im2 = im2bw(im, threshold);
%complement the image
im3 = imcomplement(im2);
%apply the morphological filter with disk
im4 = imclose(im3,strel('disk',6));
%check the number of labels
[labels,numlabels] = bwlabel(im4);
%increase the threshold for the next loop
threshold = threshold + thresholdStep;
end
incEyesSize = 0.05; %will be used to increase threshold for biggers eyes size
threshold = threshold + incEyesSize; % increase the threshold to be used
% Start of formfactor calibration
display('open your eyes'); %ask the user to open his eyes
pause(1); %wait for them to respond
im=snapshot(video); %take a photo with the eyes open
%detect a pair of eyes
EyeDetect = vision.CascadeObjectDetector('EyePairBig');
BB=step(EyeDetect,im); %find the eyes position
try %try to crop the image with the coordinates
im = imcrop(im,BB); %crop the image
im = rgb2gray(im); %convert RGB image
catch ...
display('failed code2'); %if no eyes are found quit
return
end
im2 = im2bw(im, threshold); %coner the image to black and white
im3 = imcomplement(im2); %complement the image
im4 = imclose(im3,strel('disk',6)); %apply morphological filter
[labels,numlabels] = bwlabel(im4); %count the BLOBS
stats = regionprops(labels, 'all'); %make array of blobs
fOpen1 = 4*pi*stats(1).Area/((stats(1).Perimeter)^2); %calculate the form factor eye1
fOpen2 = 4*pi*stats(2).Area/((stats(2).Perimeter)^2); %calculate the form factor eye1
imshow(im4); %show the image
display(fOpen1); %display the first form factor
display(fOpen2); %display the second form factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%decide the eyes state and control the robot
ratio = 0.0; %initiate the state of the eyes ratio variable
eyesOpen = 1.0; %initiate the eyes open state variable
eyesClosed = 1.0; %initiate the eyes closed state variable
counter = 0; %initiate the loop counter
speed = 30; %initate the robot speed
%open interaction with NXT robot
COM_CloseNXT('all');
close all
h = COM_OpenNXT();
COM_SetDefaultNXT(h);
%open the light sensors to stay on the track
OpenLight(SENSOR_1,'ACTIVE');
OpenLight(SENSOR_2,'ACTIVE');
%start the motors of the NXT robot
mA = NXTMotor('A','Power',speed);
mC = NXTMotor('C','Power',speed);
whiteThreshold = 250;
while true
while true
im=snapshot(video); % take a photo
%every ten cycles check if driver is sleeping
counter = counter+1; %increment the loop counter
%each five loops calculate the results
if (counter >= 5)
counter = 0; %reset the counter
ratio = (eyesOpen/eyesClosed); %calculate the ratio of the state of the eyes
eyesOpen = 1.0; %reset the eyes open and closed variables
eyesClosed = 1.0;
if (ratio <= 2.0 )
display ('sleep'); %display the state of the eyes
NXT_PlayTone(440,100); %play a warning tone
speed = speed - 5; %decrement the speed
if speed < 0 %stop decrementing if it’s 0
speed = 0;
end
else
display('awake'); %display the state of the eyes
speed = 30; %reset the speed
end
end
%send the updated speed to the motors
mA = NXTMotor('A','Power',speed);
mC = NXTMotor('C','Power',speed);
if GetLight(SENSOR_1) < 250
mA = NXTMotor('A','Power',0);
end
if GetLight(SENSOR_2) < whiteThreshold %if we detect black turn
mC = NXTMotor('C','Power',0);
end
mA.SendToNXT();
mC.SendToNXT();
% try to capture the eyes from the photo
try
EyeDetect = vision.CascadeObjectDetector('EyePairBig');
BB=step(EyeDetect,im);
%if we don’t detect the eyes increment the eye’s closed variable
if isempty(BB)
eyesClosed = eyesClosed+1;
break
end
% filters to capture if the eyes are open or closed
im2 = imcrop(im,BB);
im3 = rgb2gray(im2);
im4 = im2bw(im3, threshold);
im5 = imcomplement(im4);
im6 = imclose(im5,strel('disk',6));
[labels,numlabels] = bwlabel(im6);
stats = regionprops(labels, 'all');
open = false;
imshow (im6);
%check all the labels in the snapshot
for n = 1:numlabels
%calculate the form factor from the new photos and compare it with the open eyes
f = 4*pi*stats(n).Area/((stats(n).Perimeter)^2);
errorMargin = 0.3;
if (f < fOpen1 + errorMargin && f > fOpen1 - errorMargin )
open = true;
eyesOpen = eyesOpen+1;
break
elseif (f < fOpen2 + errorMargin && f > fOpen2 - errorMargin )
open = true;
eyesOpen = eyesOpen+1;
break
end
end
%if the eyes were not detected as open
if open == false
eyesClosed = eyesClosed+1;
break
end
%in case failed to detect the eyes
catch
display('no eyes');
break
end
end
end