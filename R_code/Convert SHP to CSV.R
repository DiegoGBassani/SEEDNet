# Run this code - only line you need to change is the #Directory (Second last line)

install.packages("sf")
library(sf)

# Function 1
# Function to convert shapefile to CSV
shp_to_csv <- function(shapefile_path) {
  # Read the shapefile
  sf_data <- st_read(shapefile_path)
  #this is just to remove the column geometry that causes issues later.
  sf_data <- sf_data[, -which(names(sf_data) == "geometry")]
  
  # Get the filename without extension
  filename <- tools::file_path_sans_ext(basename(shapefile_path))
  
  # Define the CSV file path
  csv_file_path <- paste0(dirname(shapefile_path), "/", filename, ".csv")
  
  # Save the attributes as a CSV file
  write.csv(sf_data, file = csv_file_path, row.names = FALSE)
  
  cat("Attributes saved to CSV file:", csv_file_path, "\n")
}

# Function 2
# Function to process files in the directory (including subdirectories)
convert_shp_files_in_dir <- function(directory) {
  # Get a list of all files in the directory (including subdirectories)
  file_list <- list.files(path = directory, pattern = "\\.shp$", recursive = TRUE, full.names = TRUE)
  
  # Loop through each shapefile and convert to CSV
  for (shapefile_path in file_list) {
    shp_to_csv(shapefile_path)
  }
}

# Replace 
# CHANGE #Directory (directory_path) below to the folder that contains all the subdirectories with .shp files
directory_path <- "C:/Users/Luc Kortenaar/Downloads/BJ_2017-18_DHS_03202024_1644_107844/BJGE71FL"
convert_shp_files_in_dir(directory_path)
