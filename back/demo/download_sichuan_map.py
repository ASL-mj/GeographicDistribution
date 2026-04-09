"""
下载四川省地图数据脚本
功能：从GADM下载中国省级地图数据，并提取四川省保存为独立的shapefile文件
"""

import os
import sys
import requests
import zipfile
import tempfile
import shutil
from pathlib import Path

# 检查NumPy版本兼容性
try:
    import numpy as np
    numpy_version = np.__version__
    if numpy_version.startswith('2.'):
        print("=" * 60)
        print("警告：检测到NumPy 2.x版本")
        print("=" * 60)
        print(f"当前NumPy版本: {numpy_version}")
        print("\ngeopandas等包可能不兼容NumPy 2.x")
        print("建议先修复NumPy版本兼容性问题：")
        print("\n方法1：运行修复脚本")
        print("  python fix_numpy_compatibility.py")
        print("\n方法2：手动降级NumPy")
        print("  pip install 'numpy<2' --force-reinstall")
        print("  或")
        print("  conda install 'numpy<2' -y")
        print("\n方法3：创建新环境（推荐）")
        print("  conda create -n geo_env python=3.11 numpy=1.24 geopandas -y")
        print("  conda activate geo_env")
        print("\n" + "=" * 60)
        response = input("\n是否继续尝试运行？(y/n): ").strip().lower()
        if response != 'y':
            sys.exit(1)
except ImportError:
    pass

# 检查并导入geopandas
try:
    import geopandas as gpd
except ImportError as e:
    print("=" * 60)
    print("错误：无法导入 'geopandas'")
    print("=" * 60)
    error_msg = str(e)
    
    if "NumPy" in error_msg or "numpy" in error_msg.lower():
        print("\n这是NumPy版本兼容性问题！")
        print("请先运行修复脚本：")
        print("  python fix_numpy_compatibility.py")
        print("\n或手动降级NumPy：")
        print("  pip install 'numpy<2' --force-reinstall")
    else:
        print("\n请先安装依赖包，使用以下命令之一：\n")
        print("方法1：使用pip安装（推荐）")
        print("  pip install geopandas")
        print("\n方法2：使用conda安装（如果使用Anaconda）")
        print("  conda install -c conda-forge geopandas")
        print("\n方法3：如果pip安装失败，可能需要先安装系统依赖：")
        print("  macOS: brew install geos proj gdal")
        print("  Ubuntu/Debian: sudo apt-get install libgeos-dev libproj-dev gdal-bin")
    
    print("\n安装完成后，请重新运行此脚本。")
    print("=" * 60)
    sys.exit(1)

def download_sichuan_map(output_dir="data"):
    """
    下载并提取四川省地图数据
    
    参数:
        output_dir: 输出目录，默认为"data"
    """
    print("=" * 60)
    print("四川省地图数据下载工具")
    print("=" * 60)
    
    # 创建输出目录
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    # 检查是否已存在四川省地图文件
    sichuan_shp = output_path / "sichuan.shp"
    if sichuan_shp.exists():
        print(f"\n✓ 四川省地图文件已存在: {sichuan_shp}")
        response = input("是否重新下载？(y/n): ").strip().lower()
        if response != 'y':
            print("跳过下载，使用现有文件。")
            return str(sichuan_shp)
    
    # GADM数据下载URL（中国省级行政区划数据，Level 1）
    gadm_url = "https://geodata.ucdavis.edu/gadm/gadm4.1/shp/gadm41_CHN_shp.zip"
    
    print(f"\n正在从GADM下载中国省级地图数据...")
    print(f"数据源: {gadm_url}")
    print("注意：文件较大（约50-100MB），下载可能需要几分钟，请耐心等待...")
    
    try:
        # 创建临时目录
        temp_dir = tempfile.mkdtemp()
        zip_path = os.path.join(temp_dir, "china_gadm.zip")
        
        # 下载文件
        print("\n[1/4] 正在下载ZIP文件...")
        response = requests.get(gadm_url, stream=True, timeout=300)
        response.raise_for_status()
        
        # 显示下载进度
        total_size = int(response.headers.get('content-length', 0))
        downloaded = 0
        with open(zip_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
                    if total_size > 0:
                        percent = (downloaded / total_size) * 100
                        print(f"\r下载进度: {percent:.1f}% ({downloaded}/{total_size} bytes)", end='', flush=True)
        print("\n下载完成！")
        
        # 解压文件
        print("\n[2/4] 正在解压ZIP文件...")
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)
        print("解压完成！")
        
        # 读取中国省级地图数据
        print("\n[3/4] 正在读取地图数据...")
        gadm_file = os.path.join(temp_dir, 'gadm41_CHN_1.shp')
        
        if not os.path.exists(gadm_file):
            raise FileNotFoundError(f"解压后未找到期望的文件: {gadm_file}")
        
        china_provinces = gpd.read_file(gadm_file)
        print(f"成功读取 {len(china_provinces)} 个省级行政区")
        
        # 显示所有省份名称（用于调试）
        print("\n可用的省份名称（前10个）:")
        if 'NAME_1' in china_provinces.columns:
            print(china_provinces['NAME_1'].head(10).tolist())
        elif 'name' in china_provinces.columns:
            print(china_provinces['name'].head(10).tolist())
        else:
            print("可用的列名:", china_provinces.columns.tolist())
        
        # 提取四川省
        print("\n[4/4] 正在提取四川省数据...")
        
        # 尝试不同的字段名来匹配四川省
        sichuan = None
        province_name_field = None
        
        # 可能的字段名
        possible_fields = ['NAME_1', 'name', 'NAME', 'NAME_CN', 'province']
        possible_names = ['Sichuan', '四川', 'Sichuan Province']
        
        for field in possible_fields:
            if field in china_provinces.columns:
                for name in possible_names:
                    sichuan = china_provinces[china_provinces[field] == name].copy()
                    if len(sichuan) > 0:
                        province_name_field = field
                        print(f"✓ 找到四川省！使用字段 '{field}' 匹配名称 '{name}'")
                        break
                if sichuan is not None and len(sichuan) > 0:
                    break
        
        if sichuan is None or len(sichuan) == 0:
            # 如果没找到，显示所有省份让用户选择
            print("\n未能自动找到四川省，请查看所有省份列表：")
            if 'NAME_1' in china_provinces.columns:
                all_provinces = china_provinces['NAME_1'].unique()
            elif 'name' in china_provinces.columns:
                all_provinces = china_provinces['name'].unique()
            else:
                raise ValueError("无法识别省份字段，请检查数据格式")
            
            print("\n所有省份列表:")
            for i, prov in enumerate(sorted(all_provinces), 1):
                print(f"  {i}. {prov}")
            
            # 尝试模糊匹配
            sichuan_keywords = ['sichuan', '四川', 'sc']
            for prov in all_provinces:
                if any(keyword.lower() in str(prov).lower() for keyword in sichuan_keywords):
                    if 'NAME_1' in china_provinces.columns:
                        sichuan = china_provinces[china_provinces['NAME_1'] == prov].copy()
                    else:
                        sichuan = china_provinces[china_provinces['name'] == prov].copy()
                    if len(sichuan) > 0:
                        print(f"\n✓ 通过模糊匹配找到: {prov}")
                        break
            
            if sichuan is None or len(sichuan) == 0:
                raise ValueError("未能找到四川省数据，请手动检查数据文件")
        
        # 保存四川省地图
        sichuan_output = output_path / "sichuan.shp"
        sichuan.to_file(str(sichuan_output))
        print(f"\n✓ 四川省地图已保存到: {sichuan_output}")
        
        # 同时保存完整的中国省级地图（可选，方便后续使用）
        china_output = output_path / "china_mainland.shp"
        # 排除台湾（如果需要）
        china_mainland = china_provinces[china_provinces[province_name_field] != 'Taiwan'].copy()
        china_mainland.to_file(str(china_output))
        print(f"✓ 中国省级地图已保存到: {china_output}")
        
        # 清理临时文件
        shutil.rmtree(temp_dir)
        print("\n" + "=" * 60)
        print("下载完成！")
        print("=" * 60)
        print(f"\n输出文件:")
        print(f"  - 四川省地图: {sichuan_output}")
        print(f"  - 中国省级地图: {china_output}")
        print(f"\n现在可以在Python脚本中使用以下路径:")
        print(f'  sichuan = gpd.read_file("{sichuan_output}")')
        
        return str(sichuan_output)
        
    except requests.exceptions.RequestException as e:
        print(f"\n✗ 下载失败: {e}")
        print("\n可能的解决方案:")
        print("  1. 检查网络连接")
        print("  2. 尝试使用VPN或代理")
        print("  3. 手动下载: https://geodata.ucdavis.edu/gadm/gadm4.1/shp/gadm41_CHN_shp.zip")
        print("  4. 解压后找到 gadm41_CHN_1.shp，手动提取四川省")
        raise
        
    except Exception as e:
        print(f"\n✗ 处理过程中出错: {e}")
        import traceback
        traceback.print_exc()
        raise

if __name__ == "__main__":
    # 可以修改输出目录
    output_directory = "data"  # 或者使用绝对路径，如 "/path/to/your/data"
    
    try:
        download_sichuan_map(output_directory)
    except KeyboardInterrupt:
        print("\n\n用户中断下载")
    except Exception as e:
        print(f"\n\n错误: {e}")

