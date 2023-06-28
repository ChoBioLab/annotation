library(dplyr)

args <- commandArgs(trailingOnly = TRUE) # Get the command line arguments
out_path <- paste0(args[1], "/") # Set the output path

preds <- read.csv(
  paste0(out_path, "predicted_labels.csv"),
  check.names = FALSE,
  row.names = 1
)
dec_matrix <- read.csv(
  paste0(out_path, "decision_matrix.csv"),
  check.names = FALSE,
  row.names = 1
)
prob_matrix <- read.csv(
  paste0(out_path, "probability_matrix.csv"),
  check.names = FALSE,
  row.names = 1
)

# Create a new data frame called prob_medians
prob_medians <- prob_matrix %>%
  mutate(
    across(
      everything(),
      # Replace values less than 0.5 with NA
      ~ ifelse(
        . < 0.5,
        NA,
        .
      )
    )
  ) %>%
  # Calculate the median of each column, ignoring NA values
  summarise(
    across(
      everything(),
      median,
      na.rm = TRUE
    )
  )

# Transpose the data frame and rename the column to probability_median
prob_medians <- as.data.frame(t(prob_medians)) %>%
  rename(probability_median = V1)

# Create a new data frame called conflicts
conflicts <- dec_matrix %>%
  # Filter rows where the sum of values greater than 0 is greater than 1
  filter(
    rowSums(dec_matrix > 0)
    > 1
  ) %>%
  # Calculate the sum of values greater than 0 in each column, ignoring NA values
  summarise(
    across(
      everything(),
      ~ sum(
        . > 0,
        na.rm = TRUE
      )
    )
  )

# Transpose the conflicts data frame and rename the first column to "conflicts"
conflicts <- as.data.frame(t(conflicts))

# Create a table from the predicted labels in the preds data frame
table <- as.data.frame(table(preds$predicted_labels)) %>%
  # Merge with the prob_medians data frame, matching on the row names
  merge(
    prob_medians,
    by.x = "Var1",
    by.y = "row.names"
  ) %>%
  # Merge with the conflicts data frame, matching on the row names
  merge(
    conflicts,
    by.x = "Var1",
    by.y = "row.names"
  ) %>%
  # Rename columns for clarity
  rename(
    cell_type = Var1,
    cell_count = Freq,
    conflict_count = V1
  ) %>%
  # Calculate the proportion of conflicts for each cell type
  mutate(conflict_proportion = conflict_count / cell_count)

# Write the conflicts data frame to a CSV file called conflict-counts.csv
write.csv(
  table,
  paste0(out_path, "qc.csv")
)
