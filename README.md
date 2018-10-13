![Logo](https://github.com/agombolay/Images/blob/master/Logo.png)
# A bioinformatics toolkit for mapping rNMPs embedded in DNA
**© 2017 Alli Gombolay, Fredrik Vannberg, and Francesca Storici**  
**School of Biological Sciences, Georgia Institute of Technology**

## Modules
**Process rNMP sequencing data independent of the rNMP sequencing technique**:  
* **Alignment**: Align reads to the reference, de-depulicate based on UMIs, and de-multiplex by barcode  
* **Coordinate**: Locate genomic coordinates of rNMPs for ribose-seq, Pu-seq, emRibo-seq, or HydEn-seq  

**Analyze sequence context of embedded rNMPs and their genome-wide distribution**:  
* **Sequence**: Calculate and visualize frequencies of nucleotides at and flanking sites of embedded rNMPs  
* **Distribution**: Visualize coverage of rNMPs across genome and create bedgraph files for genome browser  
 
&nbsp;
## Required Data
**Ribose-Map requires the following files**:
1. FASTQ files of sequencing data generated using NGS
2. Bowtie2 indexes (extension .bt2) for reference genome
3. FASTA file of nucleotide sequence of reference genome
4. Configuration file (example is provided in ribose-map/lib)

Note: If you have a list of single nucleotide coordinates and want to use only the Sequence or Distribution Modules without first running the Coordinate Module, you will need to first create a folder with the following path: "$repository/results/$sample/coordinate" (The repository and sample variables should be the ones you provide in the configuration file).

&nbsp;
## Software Installation

1. **Clone Ribose-Map GitHub repository**:  
   * Click [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for information on installing Git on Linux
   ```
   git clone https://github.com/agombolay/ribose-map/
   ```
   
    Ribose-Map uses [Bowtie 2](https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.3.1), [BEDtools](http://bedtools.readthedocs.io/en/latest/content/installation.html), [SAMtools](http://www.htslib.org/download/), [cutadapt](http://cutadapt.readthedocs.io/en/stable/), [UMI-tools](https://github.com/CGATOxford/UMI-tools), [R](https://cran.r-project.org/), and [Python](https://www.python.org/) to analyze and visualize data.  
To ensure easy installation and versioning of these software, we recommend using the MiniConda package manager.

2. **Install pre-requisite packages for conda**:
   ```
   python3 -m pip install pycosat pyyaml requests --user
   ```

3. **Install MiniConda and source your .bashrc file**:  
   * Follow prompts to install MiniConda in home directory
   * Run these commands from within ribose-map/lib directory
   ```
   sh Miniconda3-latest-Linux-x86_64.sh && source ~/.bashrc
   ```

4. **Create environment in which to run Ribose-Map**:  
   * Run these commands from within ribose-map/lib directory
   ```
   conda update conda
   conda install anaconda-client anaconda-build conda-build
   conda env create --name ribosemap_env --file ribosemap.yaml
   ```

&nbsp;
## How to run Ribose-Map
Before proceeding, close current terminal window and open a new window to refresh the settings  
* If SAMtools gives an error, then install this dependency: conda install -c conda-forge ncurses

1. **Activate environment to access software**:
```
source activate ribosemap_env
```

2. **Run scripts with configuration_file as input**:

     1. **Process the data**
     ```
     ribose-map alignment config
     ribose-map coordinate config
     ```
     2. **Analyze the data**
     ```
     ribose-map sequence config
     ribose-map distribution config
     ```

3. **Once the analysis is complete, exit environment**:  
```
source deactivate ribosemap_env
```
