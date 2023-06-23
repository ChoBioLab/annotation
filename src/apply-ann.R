library(Seurat) # Load the Seurat library

args <- commandArgs(trailingOnly = TRUE) # Get the command line arguments
out_path <- paste0(args[1], "/") # Set the output path
obj <- readRDS(args[2]) # Read the RDS file specified in the second argument
obj_name <- tools::file_path_sans_ext(basename(args[2])) # Get the name of the RDS file without extension

# Read the predicted labels from a CSV file
labels <- read.csv(
  paste0(out_path, "predicted_labels.csv"),
  row.names = 1
)

# Add the predicted labels to the Seurat object
obj$predicted_labels <- labels$predicted_labels
obj$over_clustering <- labels$over_clustering
obj$majority_voting <- labels$majority_voting

# Save the updated Seurat object to an RDS file with a specific name
saveRDS(
  object = obj,
  file = paste0(
    out_path,
    obj_name,
    "-annd_",
    Sys.Date(),
    ".RDS"
  )
)
