setwd('/Users/Zhuanz1/Desktop/公司项目/demo项目/坐标表格转pdf/back')

library(tidyverse)
library(ggplot2)
library(maps)
library(sf)
library(RColorBrewer)
library(rnaturalearth)
library(rnaturalearthdata)
library(rnaturalearthhires)
library(RColorBrewer)

###
# Input file
md <- read_tsv('/Users/Zhuanz1/Desktop/公司项目/demo项目/坐标表格转pdf/back/input/coordinate_data.txt')

# World map data
world_map <- map_data("world")

# China mainland provinces
china_mainland <- ne_states(country = "China", returnclass = "sf")
# Get Taiwan separately
taiwan <- ne_countries(scale = "large", country = "Taiwan", returnclass = "sf")
# Change Taiwan to province level
taiwan$region <- "Taiwan"
taiwan$name <- "Taiwan"
# Combine Taiwan and mainland
china_full <- rbind(
    china_mainland %>% select(name, geometry),
    taiwan %>% select(name, geometry)
)

###
# Map colors
map_sea <- '#B3D9FF'
map_fill <- '#F5F5DD'
world_map_color <- '#D9D9D9'
china_map_color <- '#CACACA'

# Map range
Long_limit <- c(96, 123)
Lati_limit <- c(22, 33)

# Output size
out_width <- 10
out_height <- 6

ggplot() +
    # Draw world map base
    geom_polygon(data = world_map %>% filter(!region==c('China','Taiwan')), 
                 aes(x = long, y = lat, group = group),
                 fill = map_fill, color = world_map_color, size=0.1) +
    # Draw China provinces
    geom_sf(data = china_full, fill = map_fill, color = china_map_color, size=0.1) +
    # Add sample points
    geom_point(data = md, aes(x = longitude, y = latitude, color = Species), size = 2) +
    coord_sf(xlim = Long_limit, ylim = Lati_limit) +
    labs(x='Longitude', y='Latitude') +
    theme_minimal() +
    theme(
        legend.title = element_blank(),
        panel.background = element_rect(fill=map_sea,color = NA),
        panel.grid.major = element_blank()
        # panel.grid.major = element_line(color = "gray90")
    )

# Output files
ggsave('/Users/Zhuanz1/Desktop/公司项目/demo项目/坐标表格转pdf/back/output/sample_geographic_distribution.pdf', width = out_width, height = out_height)
ggsave('/Users/Zhuanz1/Desktop/公司项目/demo项目/坐标表格转pdf/back/output/sample_geographic_distribution.png', width = out_width, height = out_height) 