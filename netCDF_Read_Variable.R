# Load the ncdf4 library  
library(ncdf4)  

# Specify the path to your NetCDF file  
nc_file_path <- "C:/Users/Mostafa/Desktop/Review project/Babak_SPI_SPEI/model_2/temp/Poland_2071_2100_cel_unit.nc"  # Replace with your actual file path  

# Open the NetCDF file  
nc_data <- nc_open(nc_file_path)  

# Print the information about the NetCDF file  
print(nc_data)  

# Get the variable names  
variables <- names(nc_data$var)  
print(variables)  

# Access a specific variable (replace 'your_variable_name' with the variable you want)  
# For example:   
# variable_data <- ncvar_get(nc_data, "your_variable_name")  
# print(variable_data)  

# Close the NetCDF file  
nc_close(nc_data)  