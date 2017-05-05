#!/bin/bash

NAME=$1
NAME2="${NAME}-n10-l8-c3.5-g0.5_fastavg_nnrm"

set -x

if [ ! -e "${NAME2}.landmarks.sim" ]; then
   #run glosim with landmark selection. The output is a square matrix with the 300 selected landmarks and a rectangular matrix 2080x300.
   glosim.py ${NAME}.xyz -n 10 -l 8 -c 3.5 --kernel fastavg --distance  --periodic --nonorm --np 2 --nlandmarks 300
fi

#remove header to feed sketchmap and dimproj
grep -v "#" "${NAME2}.landmarks.sim" > "${NAME2}.landmarks-nohead.sim"
grep -v "#" "${NAME2}.oos.sim" > "${NAME2}-nohead.oos.sim"

#run sketchmap on the landmarks
./sketch-map-auto.sh 300 "${NAME2}.landmarks-nohead.sim" "${NAME2}.landmarks" 0.039 3 3 0.039 3 3

#remove header and 3rd column
grep -v "#" "${NAME2}.landmarks.gmds" | awk '{print $1, $2}' > smap.landmark

#project the dataset on the landmarks
./dimproj.sh dimproj 300 "${NAME2}.landmarks-nohead.sim" smap.landmark 0.039 3 3 0.039 3 3 "${NAME2}-nohead.oos.sim" "${NAME2}.OOS.colvar" 0.1 21 201 2> dimproj.log

grep -v "#" "${NAME2}.OOS.colvar" | awk '{print $1, $2}' > smap

#EOF