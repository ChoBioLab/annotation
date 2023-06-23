library(Seurat) # Load the Seurat library
library(future) # Load the future library

args <- commandArgs(trailingOnly = TRUE) # Get the command line arguments
out_path <- paste0(args[1], "/") # Set the output path
obj <- readRDS(args[2]) # Read the RDS file specified in the second argument
obj_name <- tools::file_path_sans_ext(basename(args[2])) # Get the name of the RDS file without extension
workers <- as.numeric(args[3])
ram <- as.numeric(args[4])

message(workers)
message(ram)

plan(
  multicore,
  workers = workers
)
options(future.globals.maxSize = ram * 1000 * 1024^2)

# Read the predicted labels from a CSV file
labels <- read.csv(
  paste0(out_path, "predicted_labels.csv"),
  row.names = 1
)

# Add the predicted labels to the Seurat object
obj$predicted_labels <- labels$predicted_labels
obj$over_clustering <- labels$over_clustering
obj$majority_voting <- labels$majority_voting

Idents(obj) <- "predicted_labels" # Assign predicted labels as active idents
markers <- FindAllMarkers(obj) # Find DEGs for all identity classes
write.csv(markers, paste0(out_path, "annd_all_markers.csv")) # Save marker list

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
