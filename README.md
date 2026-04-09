# GeographicDistribution

地理分布图项目，包含两套主要实现：

- `R-shiny/`：Shiny 可视化应用与相关 R 脚本
- `back/`：Python 绘图脚本与示例输入数据
- `data/`：根目录公共地图数据
- `demo/`：示例脚本和演示输入

## 目录说明

### `R-shiny/`

- `app.R`：Shiny 应用主入口
- `run.R`：自动安装依赖并启动应用
- `input/`：Shiny 示例输入数据
- `docx/`：项目说明文档

### `back/`

- `sample_geographic_distribution.py`：全国样本地理分布图绘制
- `sichuan_distribution_map.py`：四川样本地理分布图绘制
- `input/`：Python 脚本示例输入
- `data/`：Python 使用的地图数据

## 快速开始

### R Shiny

```r
source("R-shiny/run.R")
```

### Python

```bash
cd back
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python sample_geographic_distribution.py
python sichuan_distribution_map.py
```

Python 脚本已改为基于脚本自身位置读取 `input/`、`data/`、`output/`，不再依赖当前工作目录。
