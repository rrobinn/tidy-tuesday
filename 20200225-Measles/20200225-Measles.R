library(tidyverse)
library(rvest)
library(maps)
library(mapproj)
library(hrbrthemes)
#library(here)
#"This repository contains immunization rate data for schools across the U.S.,
#as compiled by The Wall Street Journal. The dataset includes the overall and
#MMR-specific vaccination rates for 46,412 schools in 32 states. As used in
#“What’s the Measles Vaccination Rate at Your Child’s School?“. 
import_plex_sans()
extrafont::loadfonts()

# read data
measles <-readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-25/measles.csv')

unique(measles$xrel)
temp = measles$xrel[!is.na(measles$xrel)]

measles2 = measles %>%
  mutate(nmed = floor(enroll*(xmed/100)),
         npers = floor(enroll*(xper/100)))


# of those counties with exemptions, what's the relative % that are personal vs med? 
counties = map_data('county')
measlesc = measles2 %>%
  filter(!is.na(nmed) | !is.na(npers)) %>%
  mutate(county = tolower(county)) %>%
  group_by(county) %>%
  summarise(count_med = sum(nmed, na.rm = TRUE),
            count_pers = sum(npers, na.rm=TRUE),
            # -1=All exemptions med, 1=all exemptions personal, neg % = more medical, pos % more personal
            persvsmed = ifelse(count_med+count_pers>0, (count_pers-count_med)/(count_pers+count_med), NA)) %>% # % diff bw med and personal exemption
  ungroup() %>%
  full_join(counties, by = c('county' = 'subregion')) %>%
  mutate(
    ex_color = case_when(
      persvsmed < 0 ~ "#DB3A2F", # More medical exemptions 
      persvsmed > 0  ~ "#275D8E" # More personal exemptions
    )
  )



ggplot(measlesc) +
  geom_polygon(aes(long, lat, group = group, fill = ex_color), color = "#0B0C0B", size = 0.1) +
  annotate("text", -124, 27, label = "*Data for more than 46,000 schools in 32 states. \n 63% of counties with medical or personal exemptions \n have schools with more medical exemptions.", hjust = 0) +
  annotate("text", -124, 24, label = "Source: The Wall Street Journal | Graphic: Robin Sifre", hjust = 0, size = 2.5) +
  coord_map() +
  scale_fill_identity() +
  labs(title = "vaccine exemptions reason: Blue=More medical exemptions") +
  theme(
    plot.margin = margin(20, 20, 20, 20)
  ) +
  theme_bw()


