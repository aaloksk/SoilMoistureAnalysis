Project: Soil Moisture Calculation and Plotting
Author: Aalok Sharma Kafle
Date: [Insert Date]

Description:
------------
This project calculates soil moisture using a water balance model (based on Huang et al., 1993) and plots the resulting time series.
The project requires raw PRISM data as input, which is expected to be a CSV file with 10 rows of header information to be skipped.
The CSV file must contain at least the following columns after the header rows:
   - ppt..mm.       : Precipitation data in millimeters (mm)
   - tmean..degrees.C.: Mean temperature data in degrees Celsius (°C)

Files Included:
---------------
1. Functions.R
   - Contains custom functions including:
       * PET() : Computes potential evapotranspiration using the Thornthwaite formula.
       * soilm() : Performs the water balance calculations.
       
2. SM_Calc_Plot.R
   - Main script that:
       * Reads the raw PRISM data from the CSV file (skipping the first 10 header rows).
       * Extracts precipitation and temperature columns.
       * Computes PET and soil moisture.
       * Generates and plots the soil moisture time series.
       
3. VCKPRISM_SI.csv (Example raw PRISM data file)
   - This is the required input data file. Make sure it is placed in the same folder.
   - The file must have 10 rows of headers (which will be skipped) followed by the data.
   - Ensure the columns for precipitation (ppt..mm.) and temperature (tmean..degrees.C.) are present.

How to Run:
-----------
1. Open R or RStudio.
2. Set the working directory to this folder.
3. In the R console, run the following commands:
   > source("Functions.R")
4. Open SM_Calc_Plot and change imput parameters and data as required.   


Additional Notes:
-----------------
- Ensure that you have the required R packages installed: deSolve, lubridate, and Hmisc.
- You can install any missing packages using the command:
   > install.packages("packageName")
- Update the file paths in the scripts if necessary.
- For any modifications or troubleshooting, refer to the comments within the R files.

Enjoy analyzing your soil moisture data!

-----------------------------------------------------
Aalok Sharma Kafle
