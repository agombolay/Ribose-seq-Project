#!/usr/bin/env bash

#Author: Alli Gombolay
#This program bins rNMPs into 2.5kb windows in reference genome

#COMMAND LINE OPTIONS

#Usage statement of the program
function usage () {
	echo "Usage: 4_Poisson.sh [-i] 'Sample' [-r] 'Reference' [-s] 'Subset' [-d] 'Directory' [-h]
	-i Sample name (FS1, etc.)
	-s Subset of genome (sacCer2, nuclear, chrM, etc.)
	-r Reference genome assembly version (sacCer2, etc.)
	-d Local directory (/projects/home/agombolay3/data/repository/Ribose-seq-Project)"
}

#Use getopts function to create the command-line options ([-i], [-s], [-r], [-d], and [-h])
while getopts "i:s:r:d:h" opt; do
    case $opt in
        #Specify input as arrays to allow multiple input arguments
        i ) sample=($OPTARG) ;;
	#Specify input as variable to allow only one input argument
	s ) subset=$OPTARG ;;
	r ) reference=$OPTARG ;;
	d ) directory=$OPTARG ;;
        #If user specifies [-h], print usage statement
        h ) usage ;;
    esac
done

#Exit program if user specifies [-h]
if [ "$1" == "-h" ]; then
        exit
fi

#Input files
referenceBED=$directory/ribose-seq/reference/$reference.bed
coordinates=$directory/ribose-seq/results/$reference/$sample/Coordinates/$subset/$sample.rNMP-coordinates.bed

#Output directories
output1=$directory/ribose-seq/reference/
output2=$directory/ribose-seq/results/$reference/$sample/Poisson

#Create directory if not present
mkdir -p $output1 $output2

#Output files
binnedData=$output2/$sample.binned.data.bed
referenceWindows=$output1/$reference.windows.bed
sortedBED=$output2/$sample.rNMP-coordinates.sorted.bed

#Separate reference genome into 2.5 kb (2,500 bp) windows
bedtools makewindows -g $referenceBED -w 2500 > $referenceWindows

#Sort ribonucleotide coordinates
sort -k1,1 -k2,2n $coordinates > $sortedBED

#Select only data of interest
if [ $subset == "nuclear" ]; then
	#For nuclear data, remove mitochondria data
	#Determine regions of the two BED files that intersect with one another and count number of overlaps
	bedtools intersect -a $referenceWindows -b $sortedBED -c -sorted -nonamecheck | grep -v 'chrM' - > $binnedData
elif [ $subset == "chrM" ]; then
	#For mitochondria data, remove nuclear data
	#Determine regions of the two BED files that intersect with one another and count number of overlaps
	bedtools intersect -a $referenceWindows -b $sortedBED -c -sorted -nonamecheck | grep 'chrM' - > $binnedData
fi
