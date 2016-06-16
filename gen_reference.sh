#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
source $DIR/configuration.sh

if [ ! -f gaps.fa ]; then
  # Create a fake assembly (masked donor genome in SV context)
  python gap_bed.py inserts.bed gaps.bed
  $BEDTOOLS maskfasta -fi chr17.fa -bed inserts.bed -fo assembly.fa

  # Cut the inserts and gaps from the assembly
  $BEDTOOLS getfasta -fi assembly.fa -bed gaps.bed -fo gaps.fa
  $BEDTOOLS getfasta -fi chr17.fa -bed gaps.bed -fo inserts.fa

  # Remove all inserts from the masked donor to create a reference genome
  python reference.py assembly.fa reference.fa
  $BWA index reference.fa

  rm -f pindel.txt libraries.txt aln.*.bam
  for ((i=0;i<${#MEANS[@]};++i)); do
    # Map-sort-index reads to the reference genome
    echo -e "Aligning reads (${MEANS[i]})"
    $BWA mem -t 16 -I ${MEANS[i]},${STDDEVS[i]} reference.fa \
        reads"$i"_pe1.fq reads"$i"_pe2.fq | \
      $SAMTOOLS view -Shu - | \
      $SAMTOOLS sort - | \
      $SAMTOOLS rmdup -s - - > aln."${MEANS[i]}".bam
    $SAMTOOLS index aln."${MEANS[i]}".bam

    # echo -e "aln.${MEANS[i]}.bam\t${MEANS[i]}\tALN${MEANS[i]}" >> pindel.txt
    echo -e "aln.${MEANS[i]}.bam\t$READLENGTH\t${MEANS[i]}\t${STDDEVS[i]}" >> libraries.txt
  done
done
