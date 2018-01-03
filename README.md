<p style="text-align: left;"><span style="font-weight: 400;">DETECTING SLEEPING DRIVERS</span></p>
<h2 style="text-align: left;"><span style="font-weight: 400;">By</span></h2>
<h2 style="text-align: left;"><span style="font-weight: 400;">Nour Din Saffour, Yann Regev, Ilmari Kaskia</span></h2>
<h1 style="text-align: left;"><span style="font-weight: 400;">Introduction </span></h1>
<p style="text-align: left;"><span style="font-weight: 400;">Sleep-deprived driving is a common phenomenon, that is a factor in more than 100.000 car crashes, resulting in approximately 6500 deaths and 80.000 injuries annually. Our project is to create a system that detects if the driver of a car is falling asleep behind the wheel through eye detection, and warn the driver with a sound, and if that fails, turn the warning lights on and slow the car down. The aim of this system is to reduce the risk of accidents on the road caused by drowsy and inattentive drivers.</span></p>
<h1 style="text-align: left;"><span style="font-weight: 400;">Block diagram:</span><br /><img src="https://github.com/nos111/Detecting-sleep-deprived-drivers/blob/master/photos/blockdiagram1.jpg?raw=true" alt="" width="1468" height="686" /></h1>
<h1 style="text-align: left;"><span style="font-weight: 400;">System design</span></h1>
<h2 style="text-align: left;"><span style="font-weight: 400;">First steps:</span></h2>
<p style="text-align: left;"><span style="font-weight: 400;">Our first step was to read the literature so we can learn from the experiences of those who have done something like this before. After that, we began designing our system in earnest.</span></p>
<h2 style="text-align: left;"><span style="font-weight: 400;">Recognizing the eyes:</span></h2>
<p style="text-align: left;"><span style="font-weight: 400;">The first step was to recognise the eyes of the user. For that, we needed to detect the face of the user in an image and then extract a picture of the eyes from that image. We found a Matlab code to find the eyes in a picture and draw a rectangle around them. From that, it was easy to use the dimensions of the rectangle to crop the picture to include only the eyes:</span></p>
<h1 style="text-align: left;">&nbsp;</h1>
<p style="text-align: left;"><span style="font-weight: 400;">EyeDetect = vision.CascadeObjectDetector('EyePairBig');</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">BB=step(EyeDetect,im);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im2 = imcrop(im,BB);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">A cropped image with the eyes only from the program</span></p>
<h1 style="text-align: left;"><img src="https://github.com/nos111/Detecting-sleep-deprived-drivers/blob/master/photos/eyes1.jpg?raw=true" alt="" width="640" height="216" /></h1>
<h2 style="text-align: left;"><span style="font-weight: 400;">Detecting the eyes in different lighting situations:</span></h2>
<p style="text-align: left;"><span style="font-weight: 400;">Taking into consideration the different lighting in every environment, We tried to overcome this problem by calibrating when the program starts.</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">At the beginning of the program the user will be asked to keep their eyes open while we detect the right threshold which will provide us with only two BLOBs.</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">After we have decided the threshold we will calculate the formfactor of the eyes in the open state. We will use this form factor to decide whether the eyes are open or closed. &nbsp;</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">Matlab Code:</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">video=webcam;</span> <span style="font-weight: 400;">%start the video camera</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">display('open your eyes');</span> <span style="font-weight: 400;">%ask the user to open their eyes</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">pause(1);</span> <span style="font-weight: 400;">%wait until they react</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">threshold = 0.0;</span> <span style="font-weight: 400;">%initiate the threshold variable</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im=snapshot(video);</span> <span style="font-weight: 400;">%take a photo </span></p>
<p style="text-align: left;"><span style="font-weight: 400;">EyeDetect = vision.CascadeObjectDetector('EyePairBig');</span> <span style="font-weight: 400;">%detect the eyes</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">BB=step(EyeDetect,im);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">try</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im = imcrop(im,BB);</span> <span style="font-weight: 400;">%crop the eyes image</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im = rgb2gray(im);</span> <span style="font-weight: 400;">%turn it into grey image</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">catch ...</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">display('failed code 1');</span> <span style="font-weight: 400;">%if the eyes weren&rsquo;t detected display it</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">return &nbsp;&nbsp;</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">end &nbsp;&nbsp;&nbsp;</span></p>
<h1 style="text-align: left;">&nbsp;</h1>
<p style="text-align: left;"><span style="font-weight: 400;">numlabels = 0;</span> <span style="font-weight: 400;">%initiate the number of labers</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">%if the number of labels is smaller than 2 keep trying to detect to get to 2 labels</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">while numlabels &lt; 2</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im2 = im2bw(im, threshold);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im3 = imcomplement(im2);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im4 = imclose(im3,strel('disk',6));</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">[labels,numlabels] = bwlabel(im4);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">threshold = threshold + 0.005;</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">end</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">threshold = threshold + 0.04; % this number was tested to be the best</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">display('open your eyes');</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">pause(1);</span></p>
<h1 style="text-align: left;"><br /><br /></h1>
<p style="text-align: left;"><span style="font-weight: 400;">%take a photo with the new threshold and calculate the form factor to be used in the program</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im=snapshot(video);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">EyeDetect = vision.CascadeObjectDetector('EyePairBig');</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">BB=step(EyeDetect,im);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">try</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im = imcrop(im,BB);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im = rgb2gray(im);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">catch ...</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">display('failed code2');</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">return &nbsp;&nbsp;</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">end &nbsp;&nbsp;&nbsp;</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im2 = im2bw(im, threshold);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im3 = imcomplement(im2);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">im4 = imclose(im3,strel('disk',6));</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">[labels,numlabels] = bwlabel(im4);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">stats = regionprops(labels, 'all');</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">fOpen1 = 4*pi*stats(1).Area/((stats(1).Perimeter)^2);</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">fOpen2 = 4*pi*stats(2).Area/((stats(2).Perimeter)^2);</span></p>
<h1 style="text-align: left;">&nbsp;</h1>
<h2 style="text-align: left;"><span style="font-weight: 400;">Detecting the state of the eyes:</span></h2>
<p style="text-align: left;"><span style="font-weight: 400;">Now that we have the picture of the eyes we needed to detect the state of the eyes. We used the skills we learned from the labs. We obtained a usable picture via the following steps:</span></p>
<ul style="text-align: left;">
<li style="font-weight: 400;"><span style="font-weight: 400;">Converted the image to a grey image.</span></li>
</ul>
<p style="text-align: left;"><span style="font-weight: 400;">A grey image with the eyes only from the program</span><span style="font-weight: 400;"><img src="https://github.com/nos111/Detecting-sleep-deprived-drivers/blob/master/photos/eyes2.jpg?raw=true" alt="" width="816" height="233" /></span></p>
<h1 style="text-align: left;">&nbsp;</h1>
<p style="text-align: left;">&nbsp;</p>
<ul style="text-align: left;">
<li style="font-weight: 400;"><span style="font-weight: 400;">Measured the threshold we needed to get only two BLOBs. After that we converted the image to a black and white image using the threshold we measured.</span></li>
</ul>
<p style="text-align: left;"><span style="font-weight: 400;">A black and white image from the program</span></p>
<p style="text-align: left;">&nbsp;</p>
<p style="text-align: left;"><span style="font-weight: 400;"><img src="https://github.com/nos111/Detecting-sleep-deprived-drivers/blob/master/photos/eyes3.jpg?raw=true" alt="" width="528" height="128" /></span></p>
<p style="text-align: left;">&nbsp;</p>
<ul style="text-align: left;">
<li style="font-weight: 400;"><span style="font-weight: 400;">Complemented the image to flip the colors</span></li>
</ul>
<p style="text-align: left;">The black and white image after complementing the colors</p>
<h1 style="text-align: left;"><img src="https://github.com/nos111/Detecting-sleep-deprived-drivers/blob/master/photos/eyes4.jpg?raw=true" alt="" width="617" height="233" /></h1>
<ul style="text-align: left;">
<li style="font-weight: 400;"><span style="font-weight: 400;">Applied the morphological closing filter using a disk shape.</span></li>
</ul>
<p style="text-align: left;"><span style="font-weight: 400;">A final phase photo from the program with the eyes open</span></p>
<h1 style="text-align: left;"><img src="https://github.com/nos111/Detecting-sleep-deprived-drivers/blob/master/photos/eyes5.jpg?raw=true" alt="" width="528" height="178" /></h1>
<p style="text-align: left;"><span style="font-weight: 400;">A final phase photo from the program with the eyes closed</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"><img src="https://github.com/nos111/Detecting-sleep-deprived-drivers/blob/master/photos/eyes6.jpg?raw=true" alt="" width="587" height="168" /></span></p>
<p style="text-align: left;"><span style="font-weight: 400;">Now that we have everything set up we will measure the form factor of the two shapes and depending on the values we will get the program will decide whether the eyes are open or closed.</span></p>
<h2 style="text-align: left;"><span style="font-weight: 400;">Deciding the state of the driver:</span></h2>
<p style="text-align: left;"><span style="font-weight: 400;">The fact that the eyes are closed or open in one image doesn&rsquo;t mean the driver is sleeping or awake. The driver might blink or turn his head left and right which will reflect on the detected state. We decided to judge the state of the driver using a ratio of the open and closed images according to the following parameters:</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">Samples = 5</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">Ratio = Eyes open frames / Eyes closed frames</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">If the ratio is bigger than or equal to 2, the driver is awake.</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">if it's lower, the driver is sleeping</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">Matlab code:</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">if (counter &gt;= 5)</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style="font-weight: 400;">counter = 0;</span> <span style="font-weight: 400;">%reset the counter</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style="font-weight: 400;">result = (eyesOpen/eyesClosed);</span> <span style="font-weight: 400;">%calculate the ratio</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style="font-weight: 400;">eyesOpen = 1.0;</span> <span style="font-weight: 400;">%reset the variables</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style="font-weight: 400;">eyesClosed = 1.0;</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style="font-weight: 400;">if (result &lt;= 2.0 )</span> <span style="font-weight: 400;">%decide the state of the eyes</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style="font-weight: 400;">display ('Sleeping&rsquo;');</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style="font-weight: 400;">sound(y,fs);</span> <span style="font-weight: 400;">%sound the alarm</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style="font-weight: 400;">speed = 0;</span> <span style="font-weight: 400;">%stop the car</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style="font-weight: 400;">else</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style="font-weight: 400;">display('awake&rsquo;');</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style="font-weight: 400;">speed = 30;</span> <span style="font-weight: 400;">%keep on driving</span></p>
<p style="text-align: left;"><span style="font-weight: 400;"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <span style="font-weight: 400;">end</span></p>
<h2 style="text-align: left;"><span style="font-weight: 400;">Controlling the car:</span></h2>
<p style="text-align: left;"><span style="font-weight: 400;">Due to the scope of the project, we did not have access to an actual car, so we simulated our system using a Lego Mindstorms NXT robot. The control specifics of the systems were a big question from the start. Should the car come to a complete stop, how long should the delay between the eyes closing and the system reacting? At what rate should the car slow down? Should the car pull over, or keep it&rsquo;s lane? In a suburban or urban area the car needs to slow down fast since there could be pedestrians nearby, while on a highway stopping too fast would pose a danger to the other drivers. In the end we decided to simulate an urban setting, where the car needs to stop quickly if the driver does not maintain control of the car.</span></p>
<h2 style="text-align: left;"><span style="font-weight: 400;">Risk analysis</span></h2>
<ul style="text-align: left;">
<li style="font-weight: 400;"><span style="font-weight: 400;">Detecting eyes is easy through matlab, but reliably detecting if eyes are open or closed is much more difficult. Our primary aim is to get it to working at an acceptable level for all eyes.</span></li>
<li style="font-weight: 400;"><span style="font-weight: 400;">Eye detection can be compromised if the user is wearing glasses, or shades. Possible problems with deformed eyes or only one eye.</span></li>
<li style="font-weight: 400;"><span style="font-weight: 400;">Different skin colours and lighting conditions might also affect the eye detection</span></li>
</ul>
<p style="text-align: left;"><span style="font-weight: 400;">To mitigate these risks, our first aim is to make the eye detection work on an acceptable level before moving on to other parts of the system. The largest part of our project is that we can detect if the user&rsquo;s eyes are open or closed.</span></p>
<h1 style="text-align: left;">&nbsp;</h1>
<h1 style="text-align: left;"><span style="font-weight: 400;">Testing</span></h1>
<p style="text-align: left;"><span style="font-weight: 400;">After we had the code in a state we deemed ready, we started testing in earnest. We decided to test it by each of us running the system for approximately 60 seconds, or 60 &ldquo;frames&rdquo;, and counting how many misses we had in the test period. A miss constituted as the system either detecting no eyes, or detecting the eyes open when they were closed, or vice versa. We received the following results:</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">Yann round 1: 1 miss/60 frames</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">Nour round 1: 2 miss/60 frames</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">Ilmari round 1:3 miss/60 frames</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">For round 1, we had very few misses within one minute, the whole system having a &lt;5% miss rate.</span></p>
<p style="text-align: left;">&nbsp;</p>
<p style="text-align: left;"><span style="font-weight: 400;">Yann round 2:5 miss/60 frames</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">Nour round 2: 11 miss/60 frames</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">Nour round 2 retry:1 miss/60 frames</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">Ilmari round 2: 6 miss/60 frames</span></p>
<h1 style="text-align: left;">&nbsp;</h1>
<p style="text-align: left;"><span style="font-weight: 400;">For round 2, we had a bit more misses, but still generally remained within &lt;10% miss rate. For Nour round 2, we got to almost a 20% miss rate, which we deemed unacceptable; we deduced that this was because of bad calibration. We tried again, and got it down to only 1 miss.</span></p>
<h1 style="text-align: left;">&nbsp;</h1>
<p style="text-align: left;"><span style="font-weight: 400;">We deemed that a miss rate of less than 10% is acceptable for our system, since the rate of pictures taken would be very fast, and if only 1 picture in 10 would be a miss, it would not pose a serious issue regarding correct performance of the system.</span><br /><br /><br /></p>
<h1 style="text-align: left;"><span style="font-weight: 400;">Ethics</span></h1>
<p style="text-align: left;"><span style="font-weight: 400;">First and foremost, we are creating this system with road safety in mind. Driving when tired, or being inattentive behind the wheel are real problems that we want to mitigate. However, this system, if implemented in real life situations, is not a catch-all solution to address this problem. The causes behind it (long working hours/unconventional working hours, not enough rest for drivers, very long trips) need to be addressed properly to fix the problem. The idea behind this project is not to provide a solution to all the underlying problems, only mitigate the effects.</span></p>
<h1 style="text-align: left;">&nbsp;</h1>
<p style="text-align: left;"><span style="font-weight: 400;">With cameras and filming people, there is always a question of privacy. We seek to get around this problem by having a closed system with no outside connection, and by not saving any data of the user - the system must only sense the immediate situation and react to it. It doesn&rsquo;t need to remember what has happened before, or anticipate what is going to happen.</span></p>
<h1 style="text-align: left;">&nbsp;</h1>
<p style="text-align: left;"><span style="font-weight: 400;">Lastly, there is the question of giving a machine control over your car with people inside. This is not a completely self-driving car with it&rsquo;s myriad of ethical issues, but it does skirt the surface of this issue. For instance, if the system malfunctions and accidentally stops the car even when the driver is attentive and awake, and thus causes an accident, or even just leaves the driver stranded, is it considered an unfortunate circumstance, or will the creators of the system be held responsible? Or, if the system does not work, the driver falls asleep and causes an accident, is it the system&rsquo;s fault, or the driver&rsquo;s, as it would have been if the system was not installed? Is the system considered reliable enough to be held responsible for the accident, or is it only a mitigating factor, with the blame landing on the driver himself?</span></p>
<p style="text-align: left;"><span style="font-weight: 400;">These are issues that would need to be resolved before the system could be released for commercial use.</span></p>
<h1 style="text-align: left;"><br /><br /><br /><br /></h1>