#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)

############################ TOOLS ##########################################

# https://www.niehs.nih.gov/research/resources/software/biostatistics/art/
ART=~/art_bin_MountRainier/art_illumina

# http://bedtools.readthedocs.io/en/latest/
BEDTOOLS=~/bedtools2/bin/bedtools

# https://github.com/samtools/samtools
SAMTOOLS=~/samtools/samtools

# http://bio-bwa.sourceforge.net
BWA=~/bwa/bwa

# http://bowtie-bio.sourceforge.net/index.shtml
BOWTIE=~/bowtie2-2.3.5.1/bowtie2
BOWTIEBUILD=~/bowtie2-2.3.5.1/bowtie2-build

# https://github.com/genome/pindel
# You may face a problem regarding abs(unsigned int). to resolve it change it to abs(int(unsigned int)) 
# change line no 1557 to the following 
# if (abs(int (All[index_a].FirstPos - All[index_b].FirstPos)) < 10 && abs(int (All[index_a].SecondPos - All[index_b].SecondPos)) < 10 && All[index_a].NumSupport + All[index_b].NumSupport >= cutoff) {
PINDEL=~/pindel/pindel
PINDEL2VCF=~/pindel/pindel2vcf

# https://github.com/GATB/MindTheGap
MINDTHEGAP=~/MindTheGap/build/bin/MindTheGap

# https://sourceforge.net/projects/gapfiller/
GAPFILLER=~/gapfiller-2.1.1/GapFiller.pl
# https://sourceforge.net/projects/soapdenovo2/files/GapCloser/src/r6/
GAPCLOSER=~/GapCloser/GapCloser
# http://www.bcgsc.ca/platform/bioinfo/software/abyss
SEALER=~/abyss-1.9.0/Sealer/abyss-sealer

# GNU time
TIME=/usr/bin/time

# Included as git submodule
# Use this one instead https://github.com/rikuu/Gap2Seq. 
# I have problem while installing the given `Gap2Seq` inside the eval-insertfill
GAP2SEQ=$DIR/Gap2Seq/build/Gap2Seq-core
GAPCUTTER=$DIR/Gap2Seq/build/GapCutter
EXTRACT=$DIR/Gap2Seq/build/ReadFilter
GAP2SEQFILTER=$DIR/Gap2Seq/build/Gap2Seq

############################ PARAMETERS ######################################

# Number of threads used in all tools
THREADS=16

# Maximum memory usage for Gap2Seq (in Gb)
MAXMEM=20

# Read simulation parameters
READLENGTH=100
COVERAGE=30
MEANS=(150 1500 3000)
STDDEVS=(15 150 300)

# Aligner, "bowtie" or "bwa"
ALIGN="bowtie"

# Gap simulation parameters
GAPNUM=30
MINGAPLEN=11
MAXGAPLEN=10000

# Threshold for using unmapped reads in filtering
# Should be close but less than $COVERAGE
THRESHOLD=25

GENOME=$DIR/chr17.fa
CONTIG=chr17

PREFIX=$DIR
DATA=$PREFIX/data
