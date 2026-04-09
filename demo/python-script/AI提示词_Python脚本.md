# AI提示词 - Python脚本方案

## 任务描述
我需要创建一个Python脚本来绘制四川省样本地理分布图。具体要求如下：

## 数据格式
我有一个TSV格式的数据文件，包含以下列：
- Population_name: 种群名称（如ZJ, PC, JC等）
- Sampling_location: 采样地点描述
- Longitude: 经度（十进制度数，如102.843001）
- Latitude: 纬度（十进制度数，如28.014200）
- Elevation_m: 海拔高度（米）
- Individuals_number: 个体数量

数据示例：
```
Population_name	Longitude	Latitude	Elevation_m	Individuals_number
ZJ	102.843001	28.014200	2300	6
PC	107.104000	31.560500	1338	8
JC	102.064000	31.476301	2150	10
```

## 功能需求
1. **地图底图**：使用四川省地图作为底图（不要显示其他省份）
   - 优先从本地shapefile读取（如data/china_mainland.shp）
   - 需要能够提取四川省的边界数据
2. **样本点绘制**：在地图上用不同颜色的点标记每个样本位置
3. **颜色自定义**：
   - 支持使用matplotlib内置调色板（如'tab10', 'Set1', 'Set2', 'Set3', 'Pastel1', 'Pastel2', 'Dark2', 'Accent', 'Paired'）
   - 支持自定义颜色列表（如["#FF6B6B", "#4ECDC4", "#45B7D1"]）
   - 每个种群使用不同颜色
4. **可调参数**：
   - 点的大小（scatter的s参数）
   - 点的透明度（alpha参数）
   - 点的边框颜色和宽度
   - 地图填充颜色
   - 省界边框颜色
   - 背景颜色
   - 地图显示范围（经度和纬度范围）
5. **输出格式**：同时输出PDF（矢量图）和PNG（位图，300 DPI）

## 技术要求
- 使用geopandas读取和处理地图数据
- 使用matplotlib进行绘图
- 代码结构清晰，参数集中在顶部便于修改
- 包含详细的注释说明
- 支持中文显示（设置合适的字体）

## 输出要求
- 生成一个完整的Python脚本文件
- 脚本可以直接运行（假设数据文件路径正确）
- 包含错误处理（如果地图文件不存在时的提示）
- 支持中文标题和标签显示
- 包含图例，显示每个种群对应的颜色

## 参考信息
- 四川省大致经度范围：97°-110°
- 四川省大致纬度范围：26°-34°
- 使用geopandas的plot()方法绘制地图边界
- 使用matplotlib的scatter()方法绘制样本点
- 建议使用ax.set_xlim()和ax.set_ylim()设置地图范围
- 如果使用GADM数据，四川省可能在NAME_1字段中标识为'Sichuan'

## 依赖包
- pandas: 读取数据
- geopandas: 处理地图数据
- matplotlib: 绘图
- numpy: 数值计算（如需要）

请生成完整的Python脚本代码。

