# Load necessary libraries
library(deSolve)   # For solving differential equations with lsoda
library(lubridate) # For working with dates (optional, if needed)
library(Hmisc)

# Source custom functions
source("Functions.R")

# ----------------------------
# Read and Prepare Input Data
# ----------------------------

# Set working directory to the location of data file
setwd('C:\\Users\\Aalok\\OneDrive - lamar.edu\\Soil-MoisturePaper\\Aalok\\SMcalc_Thronthwaite')

# Read the CSV file, skipping the first 10 rows (assuming header is on row 11)
a <- read.csv('VCKPRISM_SI.csv', skip = 10, header = TRUE)

# Define parameters from the data file
k <- 3                         # (This parameter is set but not used in the current snippet)
P <- a$ppt..mm.                # Precipitation data in millimeters
Tavg <- a$tmean..degrees.C.    # Average temperature data in degrees Celsius
latitude <- 30.3979            # Latitude (degrees) for Beaumont

# Define date range for the analysis
begindate <- "1895-01-01"
enddate <- "2024-08-01"

# Compute Potential Evapotranspiration (PET) using the Thornthwaite method
PET_values <- PET(Tavg, latitude)

# Generate a sequence of dates corresponding to each month in the data series
beginx <- as.Date(begindate, format = "%Y-%m-%d")
endx   <- as.Date(enddate, format = "%Y-%m-%d")
datesx <- seq.Date(beginx, endx, by = "month")

# Add the computed PET values as a new column in the data frame
a['PET'] <- PET_values

# Display the first few rows of the data frame for verification
head(a)

# Convert the 'Date' column to proper Date objects assuming the day is the first of the month.
# This assumes that the CSV file contains a column named 'Date' in a "YYYY-MM" format.
a$Date <- as.Date(paste0(a$Date, "-01"))

# ---------------------------------
# Set Up and Run Soil Moisture Model
# ---------------------------------

# Define time steps for the soil moisture simulation (one time step per row in the data)
times <- seq(1, nrow(a), 1)

# Define initial soil moisture and model parameters
Wo   <- 500   # Initial soil moisture (mm)
mu   <- 5.8   # Parameter for the soil moisture model (e.g., evaporation coefficient)
alpha <- 0.093 # Parameter (e.g., infiltration rate)
m    <- 4.886  # Model-specific parameter (e.g., shape factor)
Wmax <- 760    # Maximum soil moisture capacity (mm)

# Pack the parameters into a list to pass to the soil moisture model function.
# Note: The parameters must match those expected by the 'soilm' function.
parms <- list(P = P, PET = PET_values, times = times, mu = mu, alpha = alpha, m = m, Wmax = Wmax)

# Solve the soil moisture differential equation using lsoda from the deSolve package.
# The function 'soilm' must be defined elsewhere and should describe the system dynamics.
W <- lsoda(y = Wo, times = times, func = soilm, parms = parms)

# Rename columns of the output for clarity: 't' for time and 'W' for soil moisture.
colnames(W) <- c('t', 'W')

# Extract soil moisture values from the result.
SM <- W[, 2]


# Define the start and end dates for the time series based on the computed dates.
# 'beginx' and 'endx' are the Date objects defined earlier in the code.
begind <- c(year(beginx), month(beginx))  # Start year and month
endd   <- c(year(endx), month(endx))        # End year and month

# Create a time series object from the soil moisture data with a monthly frequency.
SM.ts <- ts(SM, start = begind, end = endd, frequency = 12)

# Plot the time series.
plot(SM.ts,
     col   = 'blue',               # Line color
     lwd   = 2,                    # Line width
     main  = "Time-Series of Soil Moisture Analogue",  # Title of the plot
     ylab  = "Soil Moisture (mm)",  # Y-axis label
     xlab  = "Year")               # X-axis label

# Add minor ticks to the plot for better readability.
minor.tick(nx = 5, ny = 5)

# Add a horizontal line at the mean soil moisture value.
abline(h = mean(SM), lty = 2, lwd = 2, col = 'red')