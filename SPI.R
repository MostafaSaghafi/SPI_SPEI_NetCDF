# Load necessary libraries  
library(zoo)  
library(SPEI)  

# Read the CSV file  
data <- read.csv("C:/Users/Mostafa/Desktop/Review project/Babak_SPI_SPEI/Mod1/Model1.csv") 

# Make sure the Date column is in Date format  
data$Date <- as.Date(data$Date)  

# Aggregate Precipitation data by month  
monthly_data <- aggregate(Precipitation ~ format(Date, "%Y-%m"), data = data, sum)  

# Convert aggregated data to a zoo object and remove NAs  
monthly_precip <- zoo(monthly_data$Precipitation, order.by = as.yearmon(monthly_data$`format(Date, "%Y-%m")`))  
monthly_precip <- na.omit(monthly_precip)  # Remove NAs if they exist  

# Check aggregated data  
print(head(monthly_data))  
print(monthly_precip)  

# Function to compute SPI for different time scales  
compute_spi <- function(data, scale) {  
  if (length(data) < scale) {  
    warning("Not enough data to compute SPI for scale ", scale)  
    return(rep(NA, length(data)))  # Return NA for all entries  
  }  
  spi_result <- spi(as.numeric(data), scale = scale)  
  return(spi_result$fitted)  # Extract the fitted values  
}  

# Calculate SPI for the specified time scales  
spi_1 <- compute_spi(monthly_precip, scale = 1)  
spi_3 <- compute_spi(monthly_precip, scale = 3)  
spi_6 <- compute_spi(monthly_precip, scale = 6)  
spi_9 <- compute_spi(monthly_precip, scale = 9)  
spi_12 <- compute_spi(monthly_precip, scale = 12)  
spi_24 <- compute_spi(monthly_precip, scale = 24)  

# Combine results into a data frame for easier analysis  
spi_results <- data.frame(Date = index(monthly_precip),  
                          SPI_1 = as.numeric(spi_1),  
                          SPI_3 = as.numeric(spi_3),  
                          SPI_6 = as.numeric(spi_6),  
                          SPI_9 = as.numeric(spi_9),  
                          SPI_12 = as.numeric(spi_12),  
                          SPI_24 = as.numeric(spi_24))  

# Print the results  
print(head(spi_results))  

# Save the results to a CSV file if needed  
write.csv(spi_results, "C:/Users/Mostafa/Desktop/Review project/Babak_SPI_SPEI/Mod1/spi_results.csv", row.names = FALSE)  
