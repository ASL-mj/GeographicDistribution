import os
import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import ListedColormap
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import requests
import tempfile
import zipfile
import shutil

# 设置工作目录，与R脚本相同
# os.chdir('/Users/yyy/3.project/05.项目/41黄连273/6.地图')
# 使用当前工作目录，用户可以根据需要修改
current_dir = os.getcwd()

# 读取经纬度信息文件
md = pd.read_csv('经纬度信息.txt', sep='\t')

# 定义地图颜色，与R脚本一致
map_sea = '#B3D9FF'
map_fill = '#F5F5DD'
world_map_color = '#D9D9D9'
china_map_color = '#CACACA'

# 地图范围，与R脚本一致
long_limit = (96, 123)
lati_limit = (22, 33)

# 输出尺寸，与R脚本一致
out_width = 10
out_height = 6

# 读取世界地图数据
world = gpd.read_file('./data/world.shp')
world = world[~world['NAME'].isin(['China', 'Taiwan'])]

# 读取中国大陆和台湾地图数据
china_mainland = gpd.read_file('./data/china_mainland.shp')
taiwan = gpd.read_file('./data/taiwan.shp')

# 合并大陆和台湾数据，与R脚本逻辑一致
china_mainland = china_mainland.rename(columns={'NAME_1': 'name'})
china_full = pd.concat([
    china_mainland[['name', 'geometry']],
    taiwan[['name', 'geometry']]
])

# 创建基于matplotlib的图形（不使用cartopy的projection）
fig, ax = plt.subplots(figsize=(out_width, out_height))

# 设置地图背景为海洋颜色
ax.set_facecolor(map_sea)

# 绘制世界地图
world.plot(ax=ax, color=map_fill, edgecolor=world_map_color, linewidth=0.1)

# 绘制中国省界
china_full.plot(ax=ax, color=map_fill, edgecolor=china_map_color, linewidth=0.1)

# 添加样本点
unique_species = md['Species'].unique()
colors = plt.cm.tab10(np.linspace(0, 1, len(unique_species)))
for i, species in enumerate(unique_species):
    subset = md[md['Species'] == species]
    ax.scatter(subset['longitude'], subset['latitude'], 
               label=species, color=colors[i], s=20, zorder=5)

# 设置地图范围
ax.set_xlim(long_limit)
ax.set_ylim(lati_limit)

# 设置坐标轴刻度和标签
# 设置x轴（经度）的刻度
xticks = np.arange(long_limit[0], long_limit[1]+1, 5)  # 每5度一个刻度
ax.set_xticks(xticks)
ax.set_xticklabels([f"{int(x)}°E" for x in xticks])

# 设置y轴（纬度）的刻度
yticks = np.arange(lati_limit[0], lati_limit[1]+1, 2)  # 每2度一个刻度
ax.set_yticks(yticks)
ax.set_yticklabels([f"{int(y)}°N" for y in yticks])

# 设置坐标轴标签和网格线
#ax.set_xlabel('Longitude')
#ax.set_ylabel('Latitude')
ax.grid(False)  # 不显示网格线

# 添加图例，放在图像右侧
legend = ax.legend(title='', loc='center left', bbox_to_anchor=(1.02, 0.5))

# 设置主题样式
# 保留坐标轴线但不显示顶部和右侧的轴线
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['bottom'].set_visible(True)
ax.spines['left'].set_visible(True)

# 调整布局以适应图例
plt.tight_layout()

# 保存图像，与R脚本输出一致
plt.savefig('./output/黄连样本地理分布图.pdf', bbox_inches='tight')
plt.savefig('./output/黄连样本地理分布图.png', bbox_inches='tight', dpi=300)

print("地图绘制完成！输出文件：黄连样本地理分布图.pdf 和 黄连样本地理分布图.png") 