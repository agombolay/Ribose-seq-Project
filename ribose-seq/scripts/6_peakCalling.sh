#! /usr/bin/env bash

#Author: Alli Gombolay
#This script using the "MACS2 callpeak" program to analyze the peaks from the alignment results
#Adapted from Jay Hesselberth's code located at https://github.com/hesselberthlab/modmap/tree/snake

#COMMAND LINE OPTIONS

#Name of the program (6_peakCalling.sh)
program=$0

#Usage statement of the program
function usage () {
        echo "Usage: $program [-i] '/path/to/file1.bam etc.' [-d] 'Ribose-seq directory' [-h]
          -i Filepaths of input BAM files 
          -d Location to save local Ribose-seq directory"
}

#Use getopts function to create the command-line options ([-a], [-b], [-o], and [-h])
while getopts "i:d:h" opt;
do
    case $opt in
        #Specify input as arrays to allow multiple input arguments
        i ) BAM=($OPTARG) ;;
        #If user specifies [-h], print usage statement
        h ) usage ;;
    esac
done

#Exit program if user specifies [-h]
if [ "$1" == "-h" ];
then
        exit
fi

#DEFINE VARIABLES

#Define DNA strands as either positive or negative
strands=("positive" "negative")

#Define forward and reverse flags for SAMtools
#"-F 0x10" = forward and "-f 0x10" = reverse
flags=("-F 0x10" "-f 0x10")

for samples in ${BAM[@]};
do

	#Extract sample names from filepaths
	filename=$(basename "$BAM")
	samples="${filename%.*}"
	
	#Extract input directories from filepaths
	inputDirectory=$(dirname "${BAM}")
	
	#INPUT
	#Location of input BAM files
	input=$inputDirectory/$samples.final.bam
	
	#OUTPUT
	#Location of output "ribose-seq" peaks directory
	output=$directory/ribose-seq/results/$samples/peaks

	#Create output directory if it does not already exist
	if [[ ! -f $output ]]; then
		mkdir -p $output
	fi
	
		for index in ${!strands[@]};
		do
	
			#Define variables for output BAM files
			strandBAM=$output/$samples.${strands[index]}.strand.bam
        
			#Create BAM files for positive and negative strands
			samtools view -hb ${flags[$index]} $input > $strandBAM
	
			#Define name of experiment for output files of MACS2
			experiment=$samples.${strands[index]}.strand
	
			#Define name of narrowPeak files generated by MACS2
			narrowPeak=${experiment}_peaks.narrowPeak

			#Run MACS2's callpeak program on BAM files of positive and negative strands

			#"-t": specifies input filename
			#"-n": specifies name of experiment
        		#"-s": specifies size of the sequencing tags
			#"--nomodel": specifies shifting model should not be built
			#"--extsize": extends reads in 5'->3' direction to fixed-size fragments
			#"--keep-dup all": keeps all duplicate tags that are located at same place   
			#"--call-summits": deconvolves subpeaks by reanalyzing signal profile shape

			macs2 callpeak -t $strandBAM -n $experiment -s 25 --keep-dup all --nomodel --extsize 5 --call-summits
		done
done
