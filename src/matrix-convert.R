library(Seurat) # Load the Seurat library
library(scrattch.io) # Load the scrattch.io library

args <- commandArgs(trailingOnly = TRUE) # Get the command line arguments
out_path <- paste0(args[1], "/") # Set the output path
obj <- readRDS(args[2]) # Read the RDS file specified in the second argument

# Get the expression counts matrix from the Seurat object
counts <- GetAssayData(
  obj,
  assay = "RNA",
  slot = "counts"
)

# Write the counts matrix to a CSV file in a memory-efficient manner
write_dgCMatrix_csv(
  counts,
  paste0(out_path, "counts.csv"),
  col1_name = "",
  chunk_size = 1000
)
