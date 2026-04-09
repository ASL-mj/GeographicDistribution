# 四川省样本地理分布图绘制脚本
# 功能：在四川省地图上绘制样本点，支持自定义颜色色调

library(tidyverse)
library(ggplot2)
library(sf)
library(RColorBrewer)
library(rnaturalearth)
library(rnaturalearthdata)
library(rnaturalearthhires)

# ==================== 参数设置 ====================
# 输入数据文件路径
input_file <- "input/sichuan_samples.txt"

# 输出文件路径
output_pdf <- "output/sichuan_sample_distribution.pdf"
output_png <- "output/sichuan_sample_distribution.png"

# 地图颜色设置
map_fill_color <- "#F5F5DD"      # 陆地填充颜色（浅黄色）
map_border_color <- "#CACACA"    # 省界边框颜色（浅灰色）
background_color <- "#B3D9FF"    # 背景颜色（浅蓝色）

# 样本点设置
point_size <- 4                   # 点的大小
point_alpha <- 0.8                # 点的透明度（0-1）

# 颜色方案选择（可选：Set1, Set2, Set3, Pastel1, Pastel2, Dark2, Accent, Paired, Spectral, RdYlBu等）
color_palette <- "Set1"           # 使用RColorBrewer调色板
# 或者使用自定义颜色（取消下面注释并修改）
# custom_colors <- c("#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#F7DC6F")

# 地图范围（四川省大致范围，可根据需要调整）
longitude_range <- c(97, 110)     # 经度范围
latitude_range <- c(26, 34)       # 纬度范围

# 输出尺寸（英寸）
output_width <- 12
output_height <- 10

# 标题和图例设置
plot_title <- "四川省样本地理分布图"
title_size <- 16
legend_title <- "Population"
legend_position <- "right"        # 可选：right, left, top, bottom, none

# ==================== 数据读取和处理 ====================
# 读取样本数据
sample_data <- read_tsv(input_file, locale = locale(encoding = "UTF-8"))

# 显示数据摘要
cat("读取到", nrow(sample_data), "个样本点\n")
print(sample_data)

# ==================== 地图数据获取 ====================
# 方法1：使用rnaturalearth获取中国省级地图（推荐，无需本地文件）
cat("正在获取中国省级地图数据...\n")
china_provinces <- ne_states(country = "China", returnclass = "sf")

# 提取四川省
sichuan <- china_provinces[china_provinces$name == "Sichuan", ]

# 如果方法1失败，可以使用方法2：从本地shapefile读取
# sichuan <- st_read("data/sichuan.shp")

# 检查是否成功获取四川省地图
if (nrow(sichuan) == 0) {
  stop("未能获取四川省地图数据，请检查网络连接或使用本地shapefile")
}

# ==================== 颜色设置 ====================
# 获取样本点数量
n_samples <- nrow(sample_data)

# 设置颜色
if (exists("custom_colors")) {
  # 使用自定义颜色
  if (length(custom_colors) < n_samples) {
    warning("自定义颜色数量少于样本点数量，将循环使用")
    colors <- rep(custom_colors, length.out = n_samples)
  } else {
    colors <- custom_colors[1:n_samples]
  }
  names(colors) <- sample_data$Population_name
  color_scale <- scale_color_manual(values = colors)
} else {
  # 使用RColorBrewer调色板
  if (n_samples <= 8) {
    color_scale <- scale_color_brewer(palette = color_palette, name = legend_title)
  } else {
    # 如果样本点超过8个，使用viridis调色板
    color_scale <- scale_color_viridis_d(name = legend_title, option = "plasma")
  }
}

# ==================== 绘制地图 ====================
cat("正在绘制地图...\n")

# 创建基础地图
p <- ggplot() +
  # 绘制四川省边界
  geom_sf(data = sichuan, 
          fill = map_fill_color, 
          color = map_border_color, 
          linewidth = 0.5) +
  # 添加样本点
  geom_point(data = sample_data, 
             aes(x = Longitude, y = Latitude, color = Population_name),
             size = point_size, 
             alpha = point_alpha) +
  # 应用颜色方案
  color_scale +
  # 设置坐标范围
  coord_sf(xlim = longitude_range, ylim = latitude_range, expand = FALSE) +
  # 设置标题和坐标轴标签
  labs(
    title = plot_title,
    x = "经度 (Longitude)",
    y = "纬度 (Latitude)"
  ) +
  # 设置主题
  theme_minimal() +
  theme(
    # 标题设置
    plot.title = element_text(size = title_size, hjust = 0.5, face = "bold"),
    
    # 图例设置
    legend.position = legend_position,
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 10),
    legend.background = element_rect(fill = "white", color = "gray80", linewidth = 0.5),
    
    # 坐标轴设置
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 12),
    
    # 背景设置
    panel.background = element_rect(fill = background_color, color = NA),
    panel.grid.major = element_line(color = "gray90", linewidth = 0.3, linetype = "dashed"),
    panel.grid.minor = element_blank(),
    
    # 边框设置
    panel.border = element_rect(color = "gray50", fill = NA, linewidth = 1)
  )

# 显示地图
print(p)

# ==================== 保存图片 ====================
cat("正在保存图片...\n")

# 确保输出目录存在
if (!dir.exists("output")) {
  dir.create("output", recursive = TRUE)
}

# 保存PDF（矢量图）
ggsave(output_pdf, plot = p, 
       width = output_width, height = output_height, 
       device = "pdf", dpi = 300)

# 保存PNG（位图）
ggsave(output_png, plot = p, 
       width = output_width, height = output_height, 
       device = "png", dpi = 300)

cat("地图已保存到：\n")
cat("  PDF:", output_pdf, "\n")
cat("  PNG:", output_png, "\n")

# ==================== 使用说明 ====================
# 1. 修改参数设置部分的变量来自定义地图外观
# 2. 颜色方案：
#    - 使用color_palette变量选择RColorBrewer调色板
#    - 或取消custom_colors注释并设置自定义颜色
# 3. 点的大小和透明度可通过point_size和point_alpha调整
# 4. 地图范围可通过longitude_range和latitude_range调整

