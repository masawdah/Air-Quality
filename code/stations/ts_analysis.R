############## Time series station analysis ###############

library("lubridate")
library("tidyverse")
library("readxl")

# Read data
station_data <- read_csv("data/stations/clean_stationdata.csv")
calendar <- read_excel("data/other/calendar.xlsx") %>%
  mutate(start = as.Date(start),
         end = lead(start, 1),
         name = fct_inorder(name)) %>%
  filter(name != "End restrictions")
calendar$end[nrow(calendar)] <- as.Date("2020-07-26")  
calendar <- bind_rows(mutate(calendar, Station = "industrial and traffic"),
                      mutate(calendar, Station = "background"))

# Daily means
station_data <- station_data %>%
  mutate(Station = ifelse(type %in% c("industrial", "traffic"), "industrial and traffic", type)) %>%
  group_by(Station, date) %>%
  mutate(no2_mean = mean(no2)) %>% 
  ungroup()

# Time series plot
xbreaks <- c("2020-01-01", "2020-02-01", "2020-03-01", "2020-04-01", 
             "2020-05-01", "2020-06-01", "2020-07-01")
xbreaks <- as.Date(xbreaks)

ggplot() +
  geom_rect(data = calendar, aes(xmin = start, xmax = end, ymin = 0, ymax = 92, fill = name),
            alpha = 0.2) +
  geom_line(data = station_data, aes(x=date, y=no2, group=AirQualityStation),
            colour = "grey50",  alpha = 0.4) +
  geom_line(data = station_data, aes(x=date, y=no2_mean),
            colour = "royalblue",  alpha = 0.8, lwd = 1) +
  facet_wrap(~Station, ncol = 1, labeller = "label_both") +
  scale_x_date(date_labels = "%Y-%m-%d", limits = c(as.Date("2020-01-01"), as.Date("2020-07-26")),
               breaks = xbreaks) +
  ylim(0, 92) + 
  xlab('') + ylab(expression(NO[2]~(mu*g*m^-3))) +
  ggtitle('Air pollution concentrations by station type and daily mean') +
  theme_bw() + 
  theme(legend.position = "bottom", legend.title=element_blank(), 
        plot.title = element_text(hjust = 0.5)) +
  guides(fill = guide_legend(nrow = 1))

# ggsave("figures/ts_overview.png", width = 11, height = 6, dpi = 500)  

# Time series change plot
st2019 <- filter(station_data, year(date)==2019) %>%
  group_by(AirQualityStation) %>%
  summarise(no2_2019 = mean(no2)) %>%
  ungroup()
st2020 <- filter(station_data, year(date)==2020) %>%
  left_join(st2019, by = "AirQualityStation") %>%
  mutate(no2_change = no2/no2_2019 * 100) %>%
  group_by(Station, date) %>%
  mutate(no2_mean = mean(no2_change)) %>% 
  ungroup()

ggplot() +
  geom_rect(data = calendar, aes(xmin = start, xmax = end, ymin = 0, ymax = 300, fill = name),
            alpha = 0.2) +
  geom_hline(data=NULL, yintercept = 100, linetype="dashed") +
  geom_line(data = st2020, aes(x=date, y=no2_change, group=AirQualityStation),
            colour = "grey50",  alpha = 0.4) +
  geom_line(data = st2020, aes(x=date, y=no2_mean),
            colour = "royalblue",  alpha = 0.8, lwd = 1) +
  facet_wrap(~Station, ncol = 1, labeller = "label_both") +
  scale_x_date(date_labels = "%Y-%m-%d", limits = c(as.Date("2020-01-01"), as.Date("2020-07-26")),
               breaks = xbreaks) +
  ylim(0, 300) +
  xlab('') + ylab('%') +
  ggtitle('NO2 concentrations compared to 2019 by station type and daily mean') +
  theme_bw() + 
  theme(legend.position = "bottom", legend.title=element_blank(), 
        plot.title = element_text(hjust = 0.5)) +
  guides(fill = guide_legend(nrow = 1))

ggsave("figures/ts_change.png", width = 11, height = 6, dpi = 500)
