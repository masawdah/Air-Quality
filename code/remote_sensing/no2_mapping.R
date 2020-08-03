############## Mapping sentinel 5P no2 ###############

library("ggthemes")
library("raster")
library("sf")
library("tidyverse")

# Study area boundaries
boundaries <- read_sf("data/geo/lisbon_metro_municip.geojson") %>%
  st_geometry()

# Import 2019 raster
no2_2019 <- raster("data/no2_rasters/no2_2019.tif")
no2_2019 <- crop(no2_2019, as_Spatial(boundaries))
no2_2019 <- mask(no2_2019, as_Spatial(boundaries))

# 2020 rasters and labels
raster_list <- list("data/no2_rasters/no2_2020_1.tif", "data/no2_rasters/no2_2020_2.tif", 
                    "data/no2_rasters/no2_2020_3.tif", "data/no2_rasters/no2_2020_4.tif")
rast_labels <- list("Pre-emergency", "General lockdown", "Phase 1+2+3", "Post-restrictions")

# Change from 2019, transform to df and add title
process_raster <- function(x, r2019, bound, plotit){
  rast <- raster(x)
  rast <- crop(rast, as_Spatial(bound))
  rast <- mask(rast, as_Spatial(bound))
  res <- as.data.frame(rast/r2019*100, xy = TRUE)
  res <- filter(res, !is.nan(layer))
  res <- filter(res, !is.na(layer))
  res$str <- plotit
  return(res)
}

mapdata <- map2(.x = raster_list, .y = rast_labels,
                ~process_raster(.x, r2019=no2_2019, bound=boundaries, .y))
mapdata <- do.call(rbind, mapdata)        
mapdata <- mutate(mapdata, str = fct_inorder(str))

# Map
ggplot() +
  geom_raster(data = mapdata, aes(x, y, fill=layer)) +
  geom_sf(data = boundaries, alpha  = 0.2, colour = "grey40") +
  facet_wrap(~str) +
  theme_map() +
  theme(legend.position = "right", title = element_text(hjust = 0.5)) +
  scale_fill_distiller(palette = "Spectral") +
  labs(fill = "% change")

# Write to disk
# ggsave("figures/remotesensing_map_change.png", width = 11, height = 6, dpi = 500)


# Now simple NO2
process_raster <- function(x, bound, plotit){
  rast <- raster(x)
  rast <- crop(rast, as_Spatial(bound))
  rast <- mask(rast, as_Spatial(bound))
  res <- as.data.frame(rast, xy = TRUE)
  names(res)[3] <- 'layer'
  res <- filter(res, !is.nan(layer))
  res <- filter(res, !is.na(layer))
  res$str <- plotit
  return(res)
}

mapdata <- map2(.x = raster_list, .y = rast_labels, ~process_raster(.x, bound=boundaries, .y))
mapdata <- do.call(rbind, mapdata)        
mapdata <- mutate(mapdata, str = fct_inorder(str))

# Map
ggplot() +
  geom_raster(data = mapdata, aes(x, y, fill=layer)) +
  geom_sf(data = boundaries, alpha  = 0.2, colour = "grey40") +
  facet_wrap(~str) +
  theme_map() +
  theme(legend.position = "right", title = element_text(hjust = 0.5)) +
  scale_fill_distiller(palette = "Spectral") +
  labs(fill = "NO2 (µmol/m2)")

# Write to disk
ggsave("figures/remotesensing_map_conc.png", width = 11, height = 6, dpi = 500)
