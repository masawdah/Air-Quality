############## Change ST station analysis ###############

library("ggthemes")
library("tidyverse")
library("sf")
library("lubridate")
library("readxl")

# Read data
station_data <- read_csv("data/stations/clean_stationdata.csv")
calendar <- read_excel("data/other/calendar.xlsx")
stations_geo <- read_sf("data/geo/station_locations.geojson") %>%
  select(AirQualityStation)
boundaries <- read_sf("data/geo/lisbon_metro_municip.geojson") %>%
  st_geometry()

# Prepare calendar
calendar <- calendar %>%
  mutate(start = as.Date(start),
         end = lead(start, 1),
         name = fct_inorder(name)) %>%
  filter(name != "End restrictions")
calendar$end[nrow(calendar)] <- as.Date("2020-07-26")  
calendar_grid <- tibble(date = seq(as.Date('2020-01-01'), as.Date('2020-07-26'), by = 'day')) 
calendar_grid$phase <- calendar_grid$date %>% 
  map_chr(~as.character(filter(calendar, start <= . & end >= .)$name[1]))

# Time series change 
station_data <- station_data %>%
  mutate(Station = ifelse(type %in% c("industrial", "traffic"), "industrial and traffic", type)) %>%
  filter(date <= as.Date("2020-07-26"))
st2019 <- filter(station_data, year(date)==2019) %>%
  group_by(AirQualityStation) %>%
  summarise(no2_2019 = mean(no2)) %>%
  ungroup()
st2020 <- filter(station_data, year(date)==2020) %>%
  left_join(st2019, by = "AirQualityStation") %>%
  mutate(no2_change = no2/no2_2019 * 100) %>%
  left_join(calendar_grid, by = "date") %>%
  mutate(phase = fct_inorder(phase))

# Restate phases
res_change <- st2020 %>%
  mutate(phase = as.character(phase),
         phase = ifelse(grepl("Phase", phase), "Phase 1+2+3", phase),
         phase = ifelse(grepl("Local", phase)|grepl("New", phase), "Post-restrictions", phase),
         phase = fct_inorder(phase))

# Calculate change by phase and station, join locations
res_change <- res_change %>%
  group_by(AirQualityStation, phase, Station) %>%
  summarise(mean_change = mean(no2_change))  %>%
  ungroup()
formapping <- stations_geo %>%
  full_join(res_change, by = "AirQualityStation") %>%
  filter(AirQualityStation != "STA-PT03090")

# Map
ggplot() +
  geom_sf(data = boundaries, alpha  = 0.2, colour = "grey70") +
  geom_sf(data = formapping, aes(colour = mean_change, shape = Station), size = 2, 
          show.legend = "point") +
  facet_wrap(~phase) +
  scale_colour_viridis_c(option = "D") +
  theme_map() +
  theme(legend.position = "right", title = element_text(hjust = 0.5)) +
  labs(colour = "NO2 % change") 

# Write to disk
ggsave("figures/station_map_change.png", width = 11, height = 6, dpi = 500)

