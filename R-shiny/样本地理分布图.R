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
# 输入文件
md <- read_tsv('/Users/Zhuanz1/Desktop/公司项目/demo项目/坐标表格转pdf/back/input/经纬度信息.txt')

# 世界地图数据
world_map <- map_data("world")

# 中国大陆各省
china_mainland <- ne_states(country = "China", returnclass = "sf")
# 台湾单独拿
taiwan <- ne_countries(scale = "large", country = "Taiwan", returnclass = "sf")
# 把台湾强行改成省
taiwan$region <- "Taiwan"
taiwan$name <- "Taiwan"
# 把台湾和大陆合并起来
china_full <- rbind(
    china_mainland %>% select(name, geometry),
    taiwan %>% select(name, geometry)
)

###
# 地图颜色
map_sea <- '#B3D9FF'
map_fill <- '#F5F5DD'
world_map_color <- '#D9D9D9'
china_map_color <- '#CACACA'

# 地图范围
Long_limit <- c(96, 123)
Lati_limit <- c(22, 33)

# 输出尺寸
out_width <- 10
out_height <- 6

ggplot() +
    # 绘制世界地图底纹
    geom_polygon(data = world_map %>% filter(!region==c('China','Taiwan')), 
                 aes(x = long, y = lat, group = group),
                 fill = map_fill, color = world_map_color, size=0.1) +
    # 绘制中国省界
    geom_sf(data = china_full, fill = map_fill, color = china_map_color, size=0.1) +
    # 添加样本点
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

# 输出文件
ggsave('/Users/Zhuanz1/Desktop/公司项目/demo项目/坐标表格转pdf/back/output/黄连样本地理分布图.pdf', width = out_width, height = out_height)
ggsave('/Users/Zhuanz1/Desktop/公司项目/demo项目/坐标表格转pdf/back/output/黄连样本地理分布图.png', width = out_width, height = out_height)

