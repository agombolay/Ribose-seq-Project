#!/usr/bin/env bash

#© 2016 Alli Gombolay
#Author: Alli Lauren Gombolay
#E-mail: alli.gombolay@gatech.edu
#This program aligns trimmed reads to reference genome using Bowtie2 and de-duplicates reads based on UMI
#Note1: FASTQ files must be located in users's FASTQ-Files folder (/LocalDirectory/Ribose-Map/FASTQ-Files)
#Note2: rNMP is the reverse complement of the 5' base of the sequenced read in FASTQ file

#Usage statement
function usage () {
	echo "Usage: Alignment.sh [options]
		-s Sample name(s) (e.g., FS1, FS2, FS3)
		-a Input Read 1 FASTQ filename (forward)
		-b Input Read 2 FASTQ filename (reverse)
		-u Length of UMI (e.g., NNNNNNNN or NNNNNNNNNNN)
		-b Barcode contained within UMI (e.g., ..TGA......)
		-m Minimum length of read to retain after trimming (e.g., 50)
		-p Path (e.g., /projects/home/agombolay3/data/bin/Trimmomatic-0.36)
		-t Type of Illumina Sequencing (e.g., SE = Single end, PE = Paired end)
		-i Basename of Bowtie2 index (e.g., sacCer2, pombe, ecoli, mm9, or hg38)
		-d Local user directory (e.g., /projects/home/agombolay3/data/repository)"
}

while getopts "s:a:b:u:m:t:p:i:b:d:h" opt; do
    	case "$opt" in
        	#Allow multiple input arguments
        	s ) sample=($OPTARG) ;;
		#Allow only one input argument
		f ) read1=$OPTARG ;;
		r ) read2=$OPTARG ;;
		u ) UMI=$OPTARG ;;
		b ) barcode=$OPTARG ;;
		m ) min=$OPTARG ;;
		p ) path=$OPTARG ;;
		t ) type=$OPTARG ;;
		i ) index=$OPTARG ;;
		d ) directory=$OPTARG ;;
        	#Print usage statement
        	h ) usage ;;
    	esac
done

#Exit program if [-h]
if [ "$1" == "-h" ]; then
        exit
fi

#############################################################################################################################
#Input files
Read1Fastq=$directory/Ribose-Map/FASTQ-Files/$read1
Read2Fastq=$directory/Ribose-Map/FASTQ-Files/$read2

#Output files
statistics=$directory/Ribose-Map/Results/$index/$sample/Alignment/Bowtie2.log
output=$directory/Ribose-Map/Results/$index/$sample/Alignment/$sample-MappedReads.bam

#Create directory
mkdir -p $directory/Ribose-Map/Results/$index/$sample/Alignment
	
#############################################################################################################################
#STEP 1: Trim FASTQ files based on quality and adapter content

#Single End Reads
if [[ $type == "SE" ]]; then
	java -jar $path/trimmomatic-0.36.jar SE -phred33 $Read1Fastq Paired1.fq \
	ILLUMINACLIP:$path/adapters/TruSeq3-SE.fa:2:30:10 TRAILING:10 MINLEN:$min
#Paired End Reads
elif [[ $type == "PE" ]]; then
	java -jar $path/trimmomatic-0.36.jar PE -phred33 $Read1Fastq $Read2Fastq Paired1.fq Unpaired1.fq \
	Paired2.fq Unpaired2.fq ILLUMINACLIP:$path/adapters/TruSeq3-PE.fa:2:30:10 TRAILING:10 MINLEN:$min
fi

#############################################################################################################################
#STEP 2: Reverse complement reads

#Single End Reads
if [[ $type == "SE" ]]; then
	cat Paired1.fq | seqtk seq -r - > temp1.fq
#Paired End Reads
elif [[ $type == "PE" ]]; then
	cat Paired1.fq | seqtk seq -r - > temp1.fq
	cat Paired2.fq | seqtk seq -r - > temp2.fq
fi

#############################################################################################################################
#STEP 3: Extract UMI sequence from 3' ends of reads (append UMI to read name)

#Single End Reads
if [[ $type == "SE" ]] && [[ $UMI ]]; then
	umi_tools extract -I temp1.fq -p $UMI --3prime --quality-filter-threshold=10 -v 0 -S Read1.fq
#Paired End Reads
elif [[ $type == "PE" ]] && [[ $UMI ]]; then
	umi_tools extract -I temp1.fq --read2-in temp2.fq -p $UMI --3prime -v 0 -S Read1.fq --read2-out Read2.fq
fi

#############################################################################################################################
#STEP 4: Align reads to reference genome and save Bowtie statistics to file

#Single End Reads
if [[ $type == "SE" ]]; then
	bowtie2 -x $index -U Read1.fq 2> $statistics > mapped.sam
#Paired End Reads
elif [[ $type == "PE" ]]; then
	bowtie2 -x $index -1 Read1.fq -2 Read2.fq 2> $statistics -S mapped.sam
fi

#############################################################################################################################
#STEP 5: Extract mapped reads, convert SAM file to BAM, and sort/index BAM file

#Single End Reads
if [[ $type == "SE" ]]; then
	samtools view -bS -F260 mapped.sam | samtools sort - -o mapped.bam; samtools index mapped.bam
#Paired End Reads
elif [[ $type == "PE" ]]; then
	samtools view -bS -f66 -F260 mapped.sam | samtools sort - -o mapped.bam; samtools index mapped.bam
fi

#############################################################################################################################
#STEP 6: Remove PCR duplicates based on UMI and genomic start position and sort/index BAM file

#Single End Reads with UMI
if [[ $type == "SE" ]] && [[ $UMI ]]; then
	umi_tools dedup -I mapped.bam -v 0 | samtools sort - -o dedup.bam; samtools index dedup.bam
#Paired End Reads with UMI
elif [[ $type == "PE" ]] && [[ $UMI ]]; then
	umi_tools dedup -I mapped.bam --paired -v 0 | samtools sort - -o dedup.bam; samtools index dedup.bam	
fi

#############################################################################################################################
#STEP 7: Filter BAM file based on barcode (if any) located within UMI sequence

if [[ $barcode ]]; then
	samtools view -h dedup.bam -o dedup.sam
	grep -e '_$barcode' -e '@HG' -e '@SQ' -e '@PG' dedup.sam > filtered.sam
	samtools view filtered.sam -b -S | samtools sort -o $output; samtools index $output
fi

#############################################################################################################################
#Notify user alignment step is complete for input sample
echo "Trimming, alignment, and de-duplication of $sample is complete"

#Remove temporary files
rm -f Paired*.fq Unpaired*.fq temp1.fq Read*.fq mapped.* dedup.* filtered.sam
