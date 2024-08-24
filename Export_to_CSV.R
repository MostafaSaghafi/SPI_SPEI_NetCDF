# Load the required libraries  
library(ncdf4)  
library(ggplot2)  
library(dplyr)  
library(tidyr)  

# Specify the path to your NetCDF file  
nc_file_path <- "C:/Users/Mostafa/Desktop/Review project/Babak_SPI_SPEI/model_1/temp/Poland_tas_1985_2014_unit.nc"  # Replace with your actual file path  

# Open the NetCDF file  
nc_data <- nc_open(nc_file_path)  

# Extract dimensions  
lon <- ncvar_get(nc_data, "lon")  # Longitude  
lat <- ncvar_get(nc_data, "lat")  # Latitude  
time <- ncvar_get(nc_data, "time") # Time 
#Temprature
temp_data <- ncvar_get(nc_data, "tas") # Precipitation data  
#Precipitation
#pr_data <- ncvar_get(nc_data, "pr") # Precipitation data 

# Get time units and reference date from the attributes  
time_units <- ncatt_get(nc_data, "time", "units")$value  
reference_date <- sub(".*since ", "", time_units)  # Extract the reference date  
reference_date <- as.Date(reference_date)  # Convert to Date format  

# Close the NetCDF file  
nc_close(nc_data)  

# Prepare a data frame to store all the data  
data_list <- list()  

# Loop over time to extract and combine data  
for (i in 1:length(time)) {  
  # Get the Temp data for the current time index  
  temp_at_time <- temp_data[,,i]  
  # Get the precipitation data for the current time index  
  #pr_at_time <- pr_data[,,i]  
  # Transform to data frame  
  df <- expand.grid(Lon = lon, Lat = lat)  
  df$Time <- reference_date + time[i]  # Convert to Date format  
  df$Temprature <- as.vector(temp_at_time)
  #df$Precipitation <- as.vector(pr_at_time)
  
  # Store in the list  
  data_list[[i]] <- df  
}  

# Combine all data frames into one  
final_df <- bind_rows(data_list)  

# Save the data frame to a CSV file  
write.csv(final_df, "C:/Users/Mostafa/Desktop/Review project/Babak_SPI_SPEI/model_1/temp/Temp_Model1.csv", row.names = FALSE)  

# Show the first few rows of the data frame  
head(final_df)

