library(dplyr)

args <- commandArgs(trailingOnly = TRUE) # Get the command line arguments
out_path <- paste0(args[1], "/") # Set the output path

preds <- read.csv(paste0(out_path, "predicted_labels.csv"), row.names = 1)
dec_matrix <- read.csv(paste0(out_path, "decision_matrix.csv"), row.names = 1)
prob_matrix <- read.csv(paste0(out_path, "probability_matrix.csv"), row.names = 1)

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

# Transpose the data frame and rename the column to conflicts
conflicts <- as.data.frame(t(conflicts)) %>%
  rename(conflicts = V1)

# Write the counts of predicted labels to a CSV file called cell-counts.csv
write.csv(
  as.data.frame(table(preds$predicted_labels)),
  paste0(out_path, "cell-counts.csv"),
  row.names = FALSE
)

# Write the prob_medians data frame to a CSV file called probability-medians.csv
write.csv(
  prob_medians,
  paste0(out_path, "probability-medians.csv")
)

# Write the conflicts data frame to a CSV file called conflict-counts.csv
write.csv(
  conflicts,
  paste0(out_path, "conflict-counts.csv")
)

