# uptube
simple bash bot which converts audio files to video and uploads them to youtube

# HowTo

* Start the script from within the directory where the subject audio files exist.
* Inside that direcory there must live one background image bg.jpg with a resolution
	of 1920x1080 and one foreground image fg.jpg with 1080x1080. If they have another
	resolution they will get resized.
* The script asks for your youtube login information and upload related stuff.
* With the "searchterms" you provide, it will create a list of keywords to apply
	on the video upload.
* A playlist with the directory name will get created and all videos will be
	queued in it.
* The description for the videos must be in a file called ripping.log
	(That is the standard log file of the rubyripper, but any content will do it,
	except some special chars which interfere with the youtube-upload internals)

Thats about it.

# Dependencies
youtube-upload, cewl, lynx, ffmpeg, rm, sed, echo, awk, tr, cat, cut, sort

# If you spot one or more mistakes i made, please let me know about it,
# but for me it works so far.