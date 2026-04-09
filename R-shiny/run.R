#!/usr/bin/env Rscript

# This is a simple startup script to launch the Sample Geographic Distribution Visualization Shiny app

# Check and install necessary packages
required_packages <- c("shiny", "tidyverse", "ggplot2", "maps", "sf", "RColorBrewer", 
                      "rnaturalearth", "rnaturalearthdata", "rnaturalearthhires")

# Check if already installed
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

# If there are uninstalled packages, install them
if(length(new_packages) > 0) {
  cat("Installing necessary R packages...\n")
  for(pkg in new_packages) {
    cat(paste0("Installing ", pkg, "...\n"))
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  cat("All necessary packages have been installed\n")
} else {
  cat("All necessary packages are already installed\n")
}

# Load shiny package
library(shiny)

# Set working directory to script location
script_dir <- dirname(sys.frame(1)$ofile)
if (script_dir != "") {
  setwd(script_dir)
  cat(paste0("Working directory has been set to: ", getwd(), "\n"))
}

# Check if input data file exists
if (!file.exists("input/coordinate_data.txt")) {
  cat("Warning: Sample data file 'input/coordinate_data.txt' does not exist!\n")
  cat("Please ensure this file exists, or use your own data file in the application\n")
}

# Launch Shiny application
cat("Starting Sample Geographic Distribution Visualization app...\n")
cat("Please visit the URL shown in your browser\n")
cat("Press Ctrl+C to stop the application\n\n")

runApp("app.R", launch.browser = TRUE) 