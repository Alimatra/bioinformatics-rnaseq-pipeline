#!/bin/bash

set -e

ADAPTER="AGATCGGAAGAGCACACGTCTGAACTCCAGTCA"

for SAMPLE in SRR7009364 SRR7009365
do
    echo "======================================"
    echo "Traitement de $SAMPLE"
    echo "======================================"

    echo ">>> 1. Trimming des adaptateurs"
    cutadapt \
      -a "$ADAPTER" \
      -A "$ADAPTER" \
      -o "data/trimmed/${SAMPLE}_1.fastq.gz" \
      -p "data/trimmed/${SAMPLE}_2.fastq.gz" \
      "data/raw/${SAMPLE}_1.fastq.gz" \
      "data/raw/${SAMPLE}_2.fastq.gz"

    echo ">>> 2. FastQC après trimming"
    fastqc \
      "data/trimmed/${SAMPLE}_1.fastq.gz" \
      "data/trimmed/${SAMPLE}_2.fastq.gz" \
      -o data/qc/trimmed

    echo ">>> 3. Filtrage des reads <20 bp"
    cutadapt \
      --minimum-length 20 \
      -o "data/filtered/${SAMPLE}_1.fastq.gz" \
      -p "data/filtered/${SAMPLE}_2.fastq.gz" \
      "data/trimmed/${SAMPLE}_1.fastq.gz" \
      "data/trimmed/${SAMPLE}_2.fastq.gz"

    echo ">>> 4. FastQC après filtrage"
    fastqc \
      "data/filtered/${SAMPLE}_1.fastq.gz" \
      "data/filtered/${SAMPLE}_2.fastq.gz" \
      -o data/qc/filtered

    echo ">>> $SAMPLE terminé"
done

echo "======================================"
echo "364 et 365 terminés"
echo "======================================"
