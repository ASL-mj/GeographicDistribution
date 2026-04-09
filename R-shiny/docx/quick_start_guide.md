# Sample Geographic Distribution Visualization App - Quick Start Guide

## System Requirements

1. Install R environment (version >= 4.0)

   - Windows users: Download installer from [CRAN website](https://cran.r-project.org/bin/windows/base/)
   - Mac users: Download installer from [CRAN website](https://cran.r-project.org/bin/macosx/)
   - Linux users: Use package manager specific to your distribution

2. Recommended: Install RStudio (optional)
   - Download from [RStudio website](https://www.rstudio.com/products/rstudio/download/)

## Launch Methods

### Method 1: Run the startup script (Simplest)

1. Open terminal/command prompt
2. Navigate to the application directory:
   ```
   cd path/to/application/back
   ```
3. Run the startup script:
   ```
   Rscript run.R
   ```
4. The system will automatically install necessary packages and launch the application
5. The application will open in your default browser

### Method 2: Run in RStudio

1. Open RStudio
2. Open app.R file (File > Open File)
3. Click the "Run App" button in the top-right corner
4. The application will launch in RStudio's built-in browser or your default browser

## Common Issues

1. **Package installation fails**

   - Ensure you have a stable internet connection
   - Try manual package installation:
     ```R
     install.packages(c("shiny", "tidyverse", "ggplot2", "maps", "sf", "RColorBrewer", "rnaturalearth", "rnaturalearthdata", "rnaturalearthhires"))
     ```

2. **Sample data not found**

   - Ensure the "coordinate_data.txt" file exists in the "input" folder
   - Or use the "Upload your data" option in the application

3. **Application runs slowly**

   - Map libraries may take some time to load the first time
   - Subsequent launches will be faster

4. **Map doesn't display**
   - Check if R packages were installed correctly
   - Check if data file format is correct (should contain Species, latitude, longitude columns)
