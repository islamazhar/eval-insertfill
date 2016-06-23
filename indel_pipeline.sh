#!/bin/bash
set -e

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)
SCRIPTS=$DIR/scripts

source $DIR/configuration.sh
OUT=$PREFIX/indel/

source $SCRIPTS/gen_reads.sh
source $SCRIPTS/gen_reference.sh

mkdir -p $OUT || true
cd $OUT

for ((i=0;i<${#MEANS[@]};++i)); do
  if [ ! -f tmp.filled."${MEANS[i]}".normal ]; then
    echo -e "Running Gap2Seq (normal-${MEANS[i]})"
    $GAP2SEQ -filled tmp.filled."${MEANS[i]}".normal -scaffolds $DATA/gaps.fa \
      -reads $DATA/reads"$i"_pe1.fq,$DATA/reads"$i"_pe2.fq -nb-cores $THREADS
  fi

  if [ ! -f tmp.filled."${MEANS[i]}".filter ]; then
    echo -e "Running Gap2Seq (filter-${MEANS[i]})"
    python $SCRIPTS/filler.py -l $DATA/libraries.txt -g $DATA/gaps.fa \
      -b $DATA/breakpoints.bed -i "$i" -o tmp.filled."${MEANS[i]}".filter \
      -t $THREADS
  fi
done

if [ ! -f tmp.filled.all.normal ]; then
  READS="$DATA/reads0_pe1.fq,$DATA/reads0_pe2.fq"
  for ((i=1;i<${#MEANS[@]};++i)); do
    READS="$READS,$DATA/reads"$i"_pe1.fq,$DATA/reads"$i"_pe2.fq"
  done

  echo -e "Running Gap2Seq (normal-all)"
  $GAP2SEQ -filled tmp.filled.all.normal -scaffolds $DATA/gaps.fa \
    -reads $READS -nb-cores $THREADS
fi

if [ ! -f tmp.filled.all.filter ]; then
  echo -e "Running Gap2Seq (filter-all)"
  python $SCRIPTS/filler.py -l $DATA/libraries.txt -g $DATA/gaps.fa \
    -b $DATA/breakpoints.bed -o tmp.filled.all.filter -t $THREADS
fi

python $SCRIPTS/evaluate_fill.py $DATA/inserts.fa \
  tmp.filled.150.normal tmp.filled.150.filter \
  tmp.filled.1500.normal tmp.filled.1500.filter \
  tmp.filled.3000.normal tmp.filled.3000.filter \
  tmp.filled.all.normal tmp.filled.all.filter > results_fills
