library(Seurat)

args <- commandArgs(trailingOnly = TRUE)
out_path <- paste0(args[1], "/")
obj <- readRDS(args[2])
obj_name <- tools::file_path_sans_ext(basename(args[2]))

labels <- read.csv(
  paste0(out_path, "predicted_labels.csv"),
  row.names = 1
)

obj$predicted_labels <- labels$predicted_labels
obj$over_clustering <- labels$over_clustering
obj$majority_voting <- labels$majority_voting

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
