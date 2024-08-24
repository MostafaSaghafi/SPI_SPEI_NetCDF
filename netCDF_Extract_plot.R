

# Load the ncdf4 library  
library(ncdf4)  
library(ggplot2)  
library(dplyr)  
library(tidyr)  

# Specify the path to your NetCDF file  
nc_file_path <- "C:/Users/Mostafa/Desktop/Poland__pr_1985_2014_unit.nc"  # Replace with your actual file path  

# Open the NetCDF file  
nc_data <- nc_open(nc_file_path)  

# Extract dimensions  
lon <- ncvar_get(nc_data, "lon")  # Longitude  
lat <- ncvar_get(nc_data, "lat")  # Latitude  
time <- ncvar_get(nc_data, "time") # Time  

# Extract the precipitation data variable  
pr_data <- ncvar_get(nc_data, "pr")  

# Close the NetCDF file  
nc_close(nc_data)  

# Example assuming you want to visualize precipitation for a specific time index  
time_index <- 1 # Change this to whichever time index you would like to visualize  
pr_at_time <- pr_data[,, time_index]  

# Convert to data frame for plotting  
df <- expand.grid(Lon = lon, Lat = lat)  
df$Precipitation <- as.vector(pr_at_time)  

# Plotting the data  
ggplot(df, aes(x = Lon, y = Lat, fill = Precipitation)) +  
  geom_raster() +  
  scale_fill_gradientn(colors = terrain.colors(10), na.value = "transparent") +  
  labs(title = paste("Precipitation for Time Index", time_index),  
       x = "Longitude",  
       y = "Latitude",  
       fill = "Precipitation (mm)") +  
  theme_minimal()

