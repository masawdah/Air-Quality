# Assessing the effect of the COVID-19 lockdown on air quality in Lisbon

This study aims to identify how the mobility restrictions due to COVID-19 have affected NO 2 concentrations in the metropolitan area of Lisbon before, during, and after the lockdown using station and remote sensing data.

## Air quality station analysis
Regarding station data, we will first create geometries for the station locations. Raw time series hourly data will be inspected and cleaned, and daily averages will be calculated. We will compute change with respect to the previous year (using the appropriate lag to force the same weekday). We will plot raw concentrations and % changes as time series. Data will be further averaged at the weekly level for comparison with remote sensing data. Station data analysis and time series plots will be done in R.

## Remote sensing animation series
This code demonsitrate how could use Google Earth Engine (GEE) through JavaScript API, to monitor the concentration of NO2 before, during and after the COVID-19 lockdown. This analyis used Near Real-Time (NRTI) high-resolution imagery of NO2 concentrations data from Sentinel-5P, No2_column_number_density band.
