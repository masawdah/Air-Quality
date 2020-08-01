############## Clean station data for analysis ###############

library("tidyverse")
library("sf")
library("lubridate")

# Read and clean station data
station_files <- list.files(path = "data/stations/raw", full.names = TRUE)
station_files <- station_files[!grepl("metada", station_files)]
station_data <- station_files %>% map_df(~read_csv(.))
station_data <- station_data %>%
  mutate(datetime  = substr(DatetimeBegin, 1, 19)) %>%
  select(AirQualityStation, datetime, Concentration) %>%
  filter(!is.na(Concentration))

# Read metadata and filter by location
metadata <- read_delim("data/stations/raw/PanEuropean_metadata.csv",
                       delim = "\t") %>%
  select(AirQualityStation, AirQualityStationType, AirQualityStationArea,
         Longitude, Latitude) %>%
  rename(type = AirQualityStationType,
         area = AirQualityStationArea) %>%
  filter(!duplicated(.)) %>%
  filter(AirQualityStation != "STA-PT03103")
metadata <- st_as_sf(metadata, coords = c('Longitude', 'Latitude'), crs = 4326)
boundaries <- read_sf("data/geo/lisbon_metro.geojson") %>%
  st_geometry()
metadata <- st_intersection(metadata, boundaries)

# Filter metropolitan area and compute daily average (70% coverage)
station_data <- inner_join(station_data, metadata, by = "AirQualityStation")
station_data <- station_data %>%
  mutate(date = as.Date(ymd_hms(datetime))) %>%
  group_by(AirQualityStation, date, type, area) %>%
  summarise(no2 = mean(Concentration),
            n = n()) %>%
  filter(n >= 16 & AirQualityStation != "STA-PT03103") %>%
  ungroup()

# Export time series
write_csv(station_data, "data/stations/clean_stationdata.csv")

# Export station locations
write_sf(metadata, "data/geo/station_locations.geojson")