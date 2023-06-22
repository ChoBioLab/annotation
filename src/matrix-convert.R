library(Seurat)
library(scrattch.io)

args <- commandArgs(trailingOnly = TRUE)
out_path <- paste0(args[1], "/")
object <- readRDS(args[2])

# write expression counts matrix
counts <- GetAssayData(
  object,
  assay = "RNA",
  slot = "counts"
)

# write counts matrix to file in memory considerate maner
write_dgCMatrix_csv(
  counts,
  paste0(out_path, "counts.txt"),
  chunk_size = 1000
)
