# RNA-seq Quality Control

## Dataset

The RNA-seq dataset used in this project is GSE113179 from the NCBI Gene Expression Omnibus (GEO).

The dataset contains four paired-end RNA-seq samples:

- SRR7009362
- SRR7009363
- SRR7009364
- SRR7009365

The reads are approximately 150 bp long and were generated using an Illumina HiSeq 4000 platform.

## 1. Quality control of raw reads

FastQC was used to assess the quality of the raw FASTQ files.

The main observations were:

- Per-base sequence quality: PASS for all samples.
- Per-sequence quality scores: PASS.
- Per-base N content: PASS.
- GC content: generally consistent across samples.
- Adapter Content: WARN/FAIL in several files.
- Per-base sequence content: positional nucleotide bias, particularly in R1.

A direct inspection of the reads confirmed the presence of the Illumina adapter motif `AGATCGGAAGAG` in the raw data.

## 2. Adapter trimming

Adapter trimming was performed with Cutadapt using the following Illumina-compatible adapter sequence:

`AGATCGGAAGAGCACACGTCTGAACTCCAGTCA`

For paired-end data, the adapter was searched independently in R1 and R2.

The trimming step removed adapter-derived bases while preserving the read pairs.

No minimum-length filtering was applied during this step, allowing the effect of adapter trimming to be evaluated separately.

## 3. Quality control after trimming

FastQC was run again after adapter trimming.

The main observations were:

- Per-base sequence quality: PASS.
- Per-sequence quality scores: PASS.
- Per-base N content: PASS.
- Adapter Content: substantially reduced after trimming.
- Sequence length distribution became variable because adapter removal shortened a subset of reads.
- A reproducible positional nucleotide bias remained in the first bases of R1 and, to a lesser extent, R2.

The persistent nucleotide composition bias was not considered sufficient justification for arbitrary removal of the first bases.

## 4. Length filtering

Adapter trimming and length filtering were treated as two separate processing steps.

A minimum read length of 20 bp was applied to the already trimmed paired-end reads using Cutadapt.

When one read of a pair was shorter than 20 bp, the corresponding mate was removed as well in order to preserve paired-end synchronization.

For example:

| Sample | Read pairs removed | Retained |
|---|---:|---:|
| SRR7009362 | 4,431 | 99.97% |
| SRR7009363 | 4,135 | 99.98% |

Only a very small fraction of read pairs was removed.

## 5. Quality control after filtering

FastQC was run on the final filtered FASTQ files.

Across the eight filtered FASTQ files:

- Per-base sequence quality: PASS.
- Per-sequence quality scores: PASS.
- Per-base N content: PASS.
- Sequence length distribution: WARN, reflecting the expected variable read lengths after trimming.
- Duplication levels: WARN/FAIL in several files.
- Per-base sequence content: FAIL for R1 and WARN for R2.
- Adapter Content: generally PASS/WARN, with one remaining FAIL in SRR7009362 R2.

## 6. Interpretation of duplication

The duplication level was relatively high and reproducible across the four samples:

- approximately 49–51% deduplicated sequences for R1;
- approximately 60–63% deduplicated sequences for R2.

FastQC duplication alone does not distinguish PCR duplicates from biological sequence repetition.

Because this is RNA-seq data, highly expressed transcripts can naturally generate repeated sequences.

Therefore, no duplicate removal was performed solely on the basis of the FastQC duplication module.

## 7. Adapter Content and PolyA signal

After trimming, the remaining WARN/FAIL Adapter Content signal observed in several R2 files was mainly associated with PolyA signal rather than a strong residual Illumina adapter signal.

The Illumina Universal Adapter signal remained very low.

No additional trimming was therefore applied solely to remove PolyA-related signal.

## 8. Overrepresented sequences

A sequence was reported as overrepresented in R1 for three of the four samples:

`CTCATCAATAGATGGAGACATACAGAAATAGTCAAACCACATCTACAAAA`

The sequence represented approximately 0.11% of reads in the affected samples and was reported by FastQC as `No Hit`.

The sequence does not correspond to the adapter sequence targeted during trimming.

Because its abundance was low and the signal was reproducible across samples, the reads were not removed at this stage.

Further sequence identification could be performed later using alignment or a sequence database search if necessary.

## 9. QC decisions

Based on the QC results:

- Adapter trimming was retained.
- A minimum read length of 20 bp was applied.
- Paired-end synchronization was preserved.
- No additional arbitrary trimming of the first bases was performed.
- No duplicate removal was performed based solely on FastQC.
- No reads were removed solely because of the PolyA signal.
- Overrepresented sequences were documented but not removed without further evidence.

## Conclusion

The quality control indicates that the sequencing data have good overall base quality and no major N-content problem.

Adapter contamination was detected and addressed through Cutadapt trimming. Subsequent filtering removed only a very small fraction of very short read pairs.

Several FastQC warnings and failures remain, mainly related to nucleotide composition, duplication, read-length distribution and PolyA signal. These patterns are reproducible across samples and were therefore interpreted rather than corrected through arbitrary filtering.

The resulting filtered FASTQ files are suitable for the next stage of the pipeline: RNA-seq read alignment to the reference genome.
