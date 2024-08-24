# Load necessary libraries  
library(zoo)  
library(SPEI)  
library(ncdf4)  
library(raster)  


# Read the CSV file  
data <- read.csv("C:/Users/Mostafa/Desktop/Review project/Babak_SPI_SPEI/Mod1/Model1.csv") 

# Make sure the Date column is in Date format  
data$Date <- as.Date(data$Date)  


# Aggregate by month  
monthly_data <- aggregate(cbind(Precipitation, Temperature) ~ format(Date, "%Y-%m"), data = data, sum)  

# Convert to zoo object  
monthly_data_zoo <- zoo(monthly_data[, -1], order.by = as.yearmon(monthly_data$`format(Date, "%Y-%m")`))  

# Function to calculate PET using Thornthwaite method  
calculate_pet <- function(temp) {  
  if (is.na(temp)) return(0)  
  a <- (temp / 5) ^ 1.514  
  sum_a <- sum(a)  
  return(16 * (10 * sum_a / 12))  # Monthly PET  
}  

# Calculate PET for each month  
monthly_pet <- apply(monthly_data_zoo[, "Temperature", drop = FALSE], 1, calculate_pet)  

# Calculate the water balance: Precipitation - PET  
water_balance <- monthly_data_zoo[, "Precipitation"] - monthly_pet  

# Check for NA values in water balance  
print(sum(is.na(water_balance)))  

# Remove NA values or interpolate  
water_balance <- na.omit(water_balance)  # Remove NAs  
# Alternatively, you can use interpolation  
# water_balance <- na.approx(water_balance)  

# Compute SPEI for different time scales  
compute_spei <- function(data, scale) {  
  spei_result <- spei(as.numeric(data), scale = scale)  
  return(spei_result$fitted)  
}  

# Calculate SPEI for the time scales  
spei_1 <- compute_spei(water_balance, scale = 1)  
spei_3 <- compute_spei(water_balance, scale = 3)  
spei_6 <- compute_spei(water_balance, scale = 6)  
spei_9 <- compute_spei(water_balance, scale = 9)  
spei_12 <- compute_spei(water_balance, scale = 12)  
spei_24 <- compute_spei(water_balance, scale = 24)  

# Combine results into a data frame for easier analysis  
spei_results <- data.frame(Date = index(monthly_data_zoo)[index(monthly_data_zoo) %in% index(water_balance)],  
                           SPEI_1 = as.numeric(spei_1),  
                           SPEI_3 = as.numeric(spei_3),  
                           SPEI_6 = as.numeric(spei_6),  
                           SPEI_9 = as.numeric(spei_9),  
                           SPEI_12 = as.numeric(spei_12),  
                           SPEI_24 = as.numeric(spei_24))  

# Print the results  
print(head(spei_results))  

# Save the results to a CSV file if needed  
write.csv(spei_results, "C:/Users/Mostafa/Desktop/Review project/Babak_SPI_SPEI/Mod1/spei_results.csv", row.names = FALSE) 

# Specify the path where you want to save the file  
output_directory <- "C:/Users/Mostafa/Desktop/Review project/Babak_SPI_SPEI/Mod1/"  
nc_file <- paste0(output_directory, "spei_results.nc")  
n <- nrow(spei_results)  

# Create the time variable  
# Convert the Date column to numeric values representing the number of days since a reference date  
reference_date <- as.Date("1970-01-01")  
time_values <- as.numeric(as.Date(spei_results$Date) - reference_date)  

# Define dimensions  
time_dim <- ncdim_def("time", "days since 1970-01-01", time_values)  

# Define variables for each SPEI type  
spei_1_var <- ncvar_def("SPEI_1", "SPEI value", list(time_dim), -9999)  
spei_3_var <- ncvar_def("SPEI_3", "SPEI value", list(time_dim), -9999)  
spei_6_var <- ncvar_def("SPEI_6", "SPEI value", list(time_dim), -9999)  
spei_9_var <- ncvar_def("SPEI_9", "SPEI value", list(time_dim), -9999)  
spei_12_var <- ncvar_def("SPEI_12", "SPEI value", list(time_dim), -9999)  
spei_24_var <- ncvar_def("SPEI_24", "SPEI value", list(time_dim), -9999)  

# Create the NetCDF file  
nc <- nc_create(nc_file, list(spei_1_var, spei_3_var, spei_6_var, spei_9_var, spei_12_var, spei_24_var))  

# Write the SPEI data to the NetCDF file  
ncvar_put(nc, "SPEI_1", spei_results$SPEI_1)  
ncvar_put(nc, "SPEI_3", spei_results$SPEI_3)  
ncvar_put(nc, "SPEI_6", spei_results$SPEI_6)  
ncvar_put(nc, "SPEI_9", spei_results$SPEI_9)  
ncvar_put(nc, "SPEI_12", spei_results$SPEI_12)  
ncvar_put(nc, "SPEI_24", spei_results$SPEI_24)  

# Add the time variable to the NetCDF file  
ncvar_put(nc, "time", time_values)  

# Add attribute to the variable about its time units  
ncatt_put(nc, "time", "units", "days since 1970-01-01")  

# Close the NetCDF file  
nc_close(nc)  

cat("SPEI results saved to ", nc_file, "\n")   
