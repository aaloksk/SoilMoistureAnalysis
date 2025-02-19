# ---------------------------------------------------
# File: functions.R
# Author: Aalok Sharma Kafle
# Date: 2025-02-19
# Description: Contains custom functions for computing PET
#              and performing the water balance model.
# ---------------------------------------------------


library(SPEI)

#' Compute Potential Evapotranspiration (PET) using the Thornthwaite Formula
#'
#' This function calculates the potential evapotranspiration (PET) for a given set of average temperatures
#' and latitude using the Thornthwaite method. It also handles cases where temperature data contains NA values
#' at the beginning or end of the series.
#'
#' @param Tavg A numeric vector of average temperature values.
#' @param lat  A numeric value or vector representing the latitude (in degrees).
#'
#' @return A numeric vector containing the computed PET values, with NA values added at the beginning or end if necessary.
#'
PET <- function(Tavg, lat) {
  # Compute PET using the thornthwaite function; na.rm is set to TRUE to remove missing values.
  Ep <- thornthwaite(Tavg, lat, na.rm = TRUE)
  
  # Get the lengths of the original temperature vector and the computed PET vector.
  N <- length(Tavg)
  N1 <- length(Ep)
  
  # If the computed PET vector is shorter than the original temperature vector and the first temperature is NA,
  # prepend NA values for each NA in the first 12 elements of Tavg.
  if (N1 < N && is.na(Tavg[1])) {
    num_na_start <- sum(is.na(Tavg[1:12]))
    addx <- rep(NA, num_na_start)
    Ep <- c(addx, Ep)
  }
  
  # If the computed PET vector is still shorter than the original temperature vector and the last temperature is NA,
  # append NA values for each NA in the last 12 elements of Tavg.
  if (N1 < N && is.na(Tavg[N])) {
    num_na_end <- sum(is.na(Tavg[(N-12):N]))
    addy <- rep(NA, num_na_end)
    Ep <- c(Ep, addy)
  }
  
  # Return the PET vector with appropriate NA values added
  return(Ep)
}



#' Soil Moisture Water Balance Model (Huang et al., 1993)
#'
#' This function computes the rate of change of soil moisture (dW) at a given time 't'
#' based on a water balance model adapted from Huang et al. (1993). It interpolates
#' precipitation (P) and potential evapotranspiration (Ep) for the current time step,
#' calculates various water budget components, and returns the differential change in soil moisture.
#'
#' @param t     The current time value (numeric).
#' @param W     The current soil moisture value (mm).
#' @param parms A list of parameters containing:
#'   - Pf: A vector of precipitation values.
#'   - PETf: A vector of potential evapotranspiration (PET) values.
#'   - times: A vector of time points corresponding to the precipitation and PET data.
#'   - mu: A parameter (e.g., representing a soil or evaporation factor).
#'   - alpha: A parameter representing the proportion of water contributing to a specific flux.
#'   - m: A parameter for the soil moisture nonlinearity.
#'   - Wmax: The maximum soil moisture capacity (mm).
#'
#' @return A list containing the rate of change of soil moisture, dW.
soilm <- function(t, W, parms) {
  # Extract parameters from the list
  Pf    <- parms[[1]]   # Precipitation time series
  PETf  <- parms[[2]]   # Potential Evapotranspiration time series
  times <- parms[[3]]   # Time vector corresponding to the data
  mu    <- parms[[4]]   # Parameter for soil evaporation or drainage
  alpha <- parms[[5]]   # Parameter for water flux (e.g., infiltration)
  m     <- parms[[6]]   # Soil moisture nonlinearity exponent
  Wmax  <- parms[[7]]   # Maximum soil moisture capacity (mm)
  
  # Interpolate the precipitation (P) and PET (Ep) values at the current time 't'.
  # rule = 2 ensures that extrapolation is allowed if 't' is outside the range of 'times'.
  P  <- approx(times, Pf, t, rule = 2)$y
  Ep <- approx(times, PETf, t, rule = 2)$y
  
  # Compute the soil water budget components:
  # S: Effective precipitation contribution, weighted by current soil moisture.
  S <- P * (W / Wmax)^m
  
  # B: A flux term associated with soil water loss, scaled by alpha.
  B <- alpha * W / (1 + mu)
  
  # R: Total runoff or drainage combining S and B.
  R <- S + B
  
  # E: Actual evapotranspiration, scaled by the fraction of soil moisture.
  E <- Ep * (W / Wmax)
  
  # G: Additional loss term, e.g., representing groundwater recharge.
  G <- (mu * alpha) * W / (1 + mu)
  
  # Compute the differential change in soil moisture (dW) as the balance between inputs and losses.
  dW <- P - E - R - G
  
  # Return the derivative as a list (required by the deSolve package)
  return(list(dW))
}

