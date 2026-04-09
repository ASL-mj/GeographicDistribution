"""
四川省样本地理分布图绘制脚本
功能：在四川省地图上绘制样本点，支持自定义颜色色调
"""

import os
import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import ListedColormap
import matplotlib.patches as mpatches

# ==================== 参数设置 ====================
# 输入数据文件路径
INPUT_FILE = "input/sichuan_samples.txt"

# 输出文件路径
OUTPUT_PDF = "output/sichuan_sample_distribution.pdf"
OUTPUT_PNG = "output/sichuan_sample_distribution.png"

# 地图颜色设置
MAP_FILL_COLOR = "#F5F5DD"        # 陆地填充颜色（浅黄色）
MAP_BORDER_COLOR = "#CACACA"      # 省界边框颜色（浅灰色）
BACKGROUND_COLOR = "#B3D9FF"      # 背景颜色（浅蓝色）

# 样本点设置
POINT_SIZE = 200                   # 点的大小
POINT_ALPHA = 0.8                  # 点的透明度（0-1）
POINT_EDGECOLOR = "white"          # 点的边框颜色
POINT_EDGEWIDTH = 1.5              # 点的边框宽度

# 颜色方案选择
# 选项1：使用matplotlib内置调色板（如'tab10', 'Set1', 'Set2', 'Set3', 'Pastel1', 'Pastel2', 'Dark2', 'Accent', 'Paired'）
COLOR_PALETTE = "Set1"

# 选项2：使用自定义颜色列表（取消下面注释并修改）
# CUSTOM_COLORS = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#F7DC6F"]

# 地图范围（四川省大致范围，可根据需要调整）
LONGITUDE_RANGE = (97, 110)        # 经度范围
LATITUDE_RANGE = (26, 34)          # 纬度范围

# 输出尺寸（英寸）
OUTPUT_WIDTH = 12
OUTPUT_HEIGHT = 10
DPI = 300                          # 图片分辨率

# 标题和图例设置
PLOT_TITLE = "四川省样本地理分布图"
TITLE_SIZE = 16
LEGEND_TITLE = "Population"
LEGEND_POSITION = "right"          # 可选：right, left, upper right, lower right等

# 字体设置（支持中文）
plt.rcParams['font.sans-serif'] = ['SimHei', 'Arial Unicode MS', 'DejaVu Sans']  # 用来正常显示中文标签
plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号

# ==================== 数据读取和处理 ====================
print("正在读取数据...")
sample_data = pd.read_csv(INPUT_FILE, sep='\t', encoding='utf-8')

print(f"读取到 {len(sample_data)} 个样本点")
print(sample_data)

# ==================== 地图数据获取 ====================
print("正在获取四川省地图数据...")

# 方法1：从本地shapefile读取（推荐，如果已有数据）
# 如果使用GADM数据，四川省在china_mainland.shp中
try:
    # 尝试读取中国省级地图
    china_provinces = gpd.read_file("data/china_mainland.shp")
    # 提取四川省（根据实际数据中的字段名调整）
    sichuan = china_provinces[china_provinces['NAME_1'] == 'Sichuan'].copy()
    
    if len(sichuan) == 0:
        # 如果NAME_1字段没有，尝试其他可能的字段名
        sichuan = china_provinces[china_provinces['name'] == 'Sichuan'].copy()
        
except Exception as e:
    print(f"从本地文件读取失败: {e}")
    print("尝试使用在线数据源...")
    
    # 方法2：使用geopandas直接读取在线数据（需要网络）
    try:
        # 使用Natural Earth数据
        world = gpd.read_file(gpd.datasets.get_path('naturalearth_lowres'))
        # 这个方法需要先下载中国地图数据
        # 建议使用方法1或手动下载shapefile
        raise Exception("请使用本地shapefile或安装rnaturalearth数据")
    except Exception as e2:
        print(f"在线数据获取失败: {e2}")
        raise Exception("无法获取地图数据，请确保data/china_mainland.shp文件存在")

if len(sichuan) == 0:
    raise Exception("未能找到四川省地图数据，请检查数据文件")

print("成功获取四川省地图数据")

# ==================== 颜色设置 ====================
n_samples = len(sample_data)

# 设置颜色
if 'CUSTOM_COLORS' in globals() and len(CUSTOM_COLORS) > 0:
    # 使用自定义颜色
    if len(CUSTOM_COLORS) < n_samples:
        print(f"警告：自定义颜色数量({len(CUSTOM_COLORS)})少于样本点数量({n_samples})，将循环使用")
        colors = (CUSTOM_COLORS * ((n_samples // len(CUSTOM_COLORS)) + 1))[:n_samples]
    else:
        colors = CUSTOM_COLORS[:n_samples]
else:
    # 使用matplotlib调色板
    cmap = plt.get_cmap(COLOR_PALETTE)
    colors = [cmap(i) for i in np.linspace(0, 1, n_samples)]

# 创建颜色字典
color_dict = dict(zip(sample_data['Population_name'], colors))

# ==================== 绘制地图 ====================
print("正在绘制地图...")

# 创建图形和坐标轴
fig, ax = plt.subplots(figsize=(OUTPUT_WIDTH, OUTPUT_HEIGHT))

# 设置背景颜色
ax.set_facecolor(BACKGROUND_COLOR)

# 绘制四川省边界
sichuan.plot(ax=ax, 
             color=MAP_FILL_COLOR, 
             edgecolor=MAP_BORDER_COLOR, 
             linewidth=0.5)

# 添加样本点
for idx, row in sample_data.iterrows():
    pop_name = row['Population_name']
    color = color_dict[pop_name]
    ax.scatter(row['Longitude'], row['Latitude'],
               s=POINT_SIZE,
               c=[color],
               alpha=POINT_ALPHA,
               edgecolors=POINT_EDGECOLOR,
               linewidths=POINT_EDGEWIDTH,
               label=pop_name,
               zorder=5)

# 设置坐标范围
ax.set_xlim(LONGITUDE_RANGE)
ax.set_ylim(LATITUDE_RANGE)

# 设置坐标轴标签
ax.set_xlabel('经度 (Longitude)', fontsize=12)
ax.set_ylabel('纬度 (Latitude)', fontsize=12)

# 设置标题
ax.set_title(PLOT_TITLE, fontsize=TITLE_SIZE, fontweight='bold', pad=20)

# 添加网格（可选）
ax.grid(True, linestyle='--', linewidth=0.3, color='gray90', alpha=0.5)

# 设置坐标轴刻度
ax.tick_params(labelsize=10)

# 添加图例
# 获取唯一的标签和颜色
handles, labels = ax.get_legend_handles_labels()
# 去重（保持顺序）
seen = set()
unique_handles = []
unique_labels = []
for handle, label in zip(handles, labels):
    if label not in seen:
        seen.add(label)
        unique_handles.append(handle)
        unique_labels.append(label)

ax.legend(unique_handles, unique_labels,
          title=LEGEND_TITLE,
          loc=LEGEND_POSITION,
          fontsize=10,
          title_fontsize=12,
          frameon=True,
          fancybox=True,
          shadow=True,
          framealpha=0.9)

# 调整布局
plt.tight_layout()

# 显示图形（如果在交互环境中）
# plt.show()

# ==================== 保存图片 ====================
print("正在保存图片...")

# 确保输出目录存在
os.makedirs("output", exist_ok=True)

# 保存PDF（矢量图）
plt.savefig(OUTPUT_PDF, 
            format='pdf', 
            dpi=DPI, 
            bbox_inches='tight',
            facecolor='white')

# 保存PNG（位图）
plt.savefig(OUTPUT_PNG, 
            format='png', 
            dpi=DPI, 
            bbox_inches='tight',
            facecolor='white')

print(f"地图已保存到：")
print(f"  PDF: {OUTPUT_PDF}")
print(f"  PNG: {OUTPUT_PNG}")

# ==================== 使用说明 ====================
"""
1. 修改参数设置部分的变量来自定义地图外观
2. 颜色方案：
   - 使用COLOR_PALETTE变量选择matplotlib调色板
   - 或取消CUSTOM_COLORS注释并设置自定义颜色列表
3. 点的大小和透明度可通过POINT_SIZE和POINT_ALPHA调整
4. 地图范围可通过LONGITUDE_RANGE和LATITUDE_RANGE调整
5. 确保data/china_mainland.shp文件存在，或修改地图数据获取部分
"""

