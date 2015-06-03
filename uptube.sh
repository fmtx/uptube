#!/bin/bash
# Author: Femtox - research at femtox dot de
# License: MIT
# simple bash bot which converts audio files to video and uploads them to youtube

infrmtion() {
	read -p "youtube email or username: " usrnme
	read -p "youtube password: " psswrd
	read -p "some searchterms for keyword generation (seperated by whitespace): " srchtrm
	echo -e "\ncategories: Tech Education Animals People Travel Entertainment Howto Sports Autos Music News Games Nonprofit Comedy Film"
	read -p "category: " ctgry
	read -p "keep video files after upload? y/n: " kvf
}

# keyword generation
kw() {
	srchtrm=$(echo $srchtrm | sed  -e  's/\ /%20/g')
	lynx -dump 'http://www.google.com/search?q='${srchtrm}'&num=50' | grep -avi 'google\|youtube\|\.\.\.' | \
		grep -ai www | awk '{print $1}' > links.data
	i=1
	while [[ $i -ne 9 ]]
	do
		search=`awk NR==$i links.data`
		cewl -d0 -c -w tmp${i}.data $search
		((i++))
	done
	keywords=$(cat tmp*.data | awk '{print $2 " " $1}' | sort -rh | awk '{print $2}' | tr [:upper:] [:lower:] | \
		awk '!seen[$0]++' | tr -d '\n' | cut -c-419 | sed 's/\w*[^,]$//')
	rm tmp*.data links.data
}

# convert to video and upload
caup() {
	ffmpeg -i bg.jpg -vf scale=1920:1080 bghd.jpg
	ffmpeg -i fg.jpg -vf scale=1080:1080 fghd.jpg
	i=1
	sed -i 's/>//g' ripping.log
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	for audiofile in $(ls *.{m4a,mp3,flac,wav,ogg} 2> /dev/null)
	do
		if [[ $(echo $audiofile | awk -F . '{print $NF}') == flac ]]
		then
			ffmpeg  -loop 1 -framerate 1 -i bghd.jpg -i fghd.jpg -i $audiofile -shortest -filter_complex "overlay=(W-w)/2:,format=yuv420p" \
				-c:v libx264 -r 18 -preset slower -tune stillimage -c:a aac -strict -2 -movflags +faststart ${audiofile%.*}.mp4
		else
			ffmpeg  -loop 1 -framerate 1 -i bghd.jpg -i fghd.jpg -i $audiofile -shortest -filter_complex "overlay=(W-w)/2:,format=yuv420p" \
				-c:v libx264 -r 18 -preset slower -tune stillimage -c:a copy -movflags +faststart ${audiofile%.*}.mp4
		fi
		if [[ $i == 1 ]]
		then
			playlst=$(youtube-upload -m $usrnme -p $psswrd --create-playlist=$(echo "'`pwd`'" | xargs basename) | sed 's/https/http/g')
		fi
		lnk=$(youtube-upload -m $usrnme -p $psswrd -c $ctgry -t ${audiofile%.*} --description="$(< \ripping.log)"\
			--keywords $keywords $(pwd)/${audiofile%.*}.mp4)
		youtube-upload -m $usrnme -p $psswrd  --add-to-playlist=$playlst $lnk
		if [[ $kvf == n || $kvf == N || $kvf == no || $kvf == No || $kvf == NO ]]
		then
			rm ${audiofile%.*}.mp4
		fi
		((i++))
	done
	rm bghd.jpg fghd.jpg
	IFS=$SAVEIFS
}

main() {
	infrmtion
	kw
	caup
	exit 0
}

main
exit 1
