#!/usr/bin/env bash

#Author: Alli Gombolay
#Adapted from Jay Hesselberth's code located at https://github.com/hesselberthlab/modmap/tree/snake
#This program removes UMI's from sequencing reads, aligns reads to reference genome, and deduplicates reads.

for sample in ${input[@]}; do

	#VARIABLE SPECIFICATION
	#Length of UMI (Unique Molecular Identifiers)
	UMI=NNNNNNNN

	#INPUT FILES
	#Location of raw .fastq.gz sequencing files
	fastq=$directory/ribose-seq/fastq/$sample.fastq

	#OUTPUT
	#LOCATION OF OUTPUT FILES
	output=$directory/ribose-seq/results/$sample/alignment

	#CREATE DIRECTORY STRUCTURE FOR OUTPUT FILES
	if [[ ! -d $output ]]; then
    		mkdir -p $output 
	fi

	#Location of files with trimmed UMI
	umiTrimmed=$directory/$output/$sample.umiTrimmed.fastq.gz

	#Intermediate files
	intermediateSAM=$directory/$output/$sample.intermediate.sam
	intermediateBAM=$directory/$output/$sample.intermediate.bam

	sortedBAM=$directory/$output/$sample.sorted.bam

	#Main output BAM files
	finalBAM=$directory/$output/$sample.bam

	#Output file detailing Bowtie alignment statistics
	statistics=$directory/$output/$sample.statistics.txt

	#Final output BED file
	BED=$directory/$output/$sample.bed.gz

	#ALIGNMENT
	
	#1. Trim UMI from input .fastq files and compress output files
	python2.7 umitools.py trim $fastq $UMI | gzip -c > $umiTrimmed

	#2. Align UMI trimmed reads to reference genome and output alignment statistics
	zcat $umiTrimmed | bowtie --uniq --sam $reference - 2> $statistics 1> $intermediateSAM

	#Bash functions used above:
	#"-": standard input
	#2>: Redirect standard error to file
	#1>: Redirect standard output to file
	
	#Bowtie options used above:
	#"-m 1": Return only unique reads
	#"--sam": Print alignment results in SAM format
	#reference: Basename of Bowtie index to be searched
	
	#Convert intermediate SAM files to intermediate BAM files
	samtools view -bS $intermediateSAM > $intermediateBAM

	#Explanation of options used in step above:
	#"-b": Output in BAM format
	#"-S": Input in SAM format

	#Sort intermediate BAM files
	samtools sort $intermeidateBAM > $sortedBAM

	#3. De-duplicate reads based on UMI information and compress BED files
	python2.7 umitools.py rmdup $sortedBAM $finalBAM | gzip -c > $BED
	
	#Remove intermediate SAM and BAM files
	rm $intermediateSAM $intermediateBAM

done
