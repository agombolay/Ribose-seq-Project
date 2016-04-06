# Ribose-seq-Project
Alli Gombolay, M.P.H  
Storici Lab | School of Biology  
Georgia Institute of Technology  

##Project Overview
###Non-LSF Dependent Version of Ribose-seq Analysis Pipeline  

**References**:  
* [Ribose-seq *Nature Methods* Paper, 2015]
(http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4686381/pdf/nihms742750.pdf)  
* [Georgia Tech News Article on Ribose-seq]
(http://www.news.gatech.edu/2015/01/26/ribose-seq-identifies-and-locates-ribonucleotides-genomic-dna)
* [Jay Hesselberth's GitHub Page]
(https://github.com/hesselberthlab/modmap/tree/snake/pipeline/ribose-seq-ms)

##Biological Information on *Saccharomyces cerevisiae*
* Chromosomes: 16
* Genome size: 12 million base pairs  
(Reference: https://www.ncbi.nlm.nih.gov/genome/15)

##Required Input Files:  
-Sequencing data in FASTQ file format  
-Saccharomyces cerevisiae data: http://amc-sandbox.ucdenver.edu/User13/outbox/2016/  

##Convert input reference genome files from 2bit to fasta format
* http://hgdownload.soe.ucsc.edu/admin/exe/

##Software Requirements:  
* [umitools] (https://github.com/brwnj/umitools): Trim UMIs and remove duplicate reads

* [Bowtie] (https://sourceforge.net/projects/bowtie-bio/files/bowtie/1.1.2/): Align sequencing reads to reference genome
 * [Manual page for information on commands] (http://bowtie-bio.sourceforge.net/manual.shtml)
 * [How to test if Bowtie index is properly installed] (http://bowtie-bio.sourceforge.net/tutorial.shtml)

* [SAMtools] (http://www.htslib.org/download/): Convert aligned reads files to BAM format
 * [Manual page for information on commands] (http://www.htslib.org/doc/samtools.html)
 * [Download SAMtools] (http://www.htslib.org/download/)

* [bedToBigBed and bedGraphToBigWig] (http://hgdownload.cse.ucsc.edu/admin/exe/)

* [bedtools]  (http://bedtools.readthedocs.org/en/latest/content/installation.html)

* [Python] (https://www.python.org/downloads/)  

* [R]  (https://www.r-project.org/)

##Set-up:
###Part A: Software Set-up  
-Script to download and install software automatically  

###Part B: Directory Set-up  
1. Clone the Ribose-seq Analysis Pipeline Directory Structure:  
```git clone https://github.com/agombolay/Ribose-seq-Project/tree/master/Ribose-seq-Directory```
