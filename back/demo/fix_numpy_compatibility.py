"""
修复NumPy版本兼容性问题
解决geopandas等包与NumPy 2.x不兼容的问题
"""

import subprocess
import sys

def fix_numpy_compatibility():
    """
    修复NumPy版本兼容性问题
    将NumPy降级到1.x版本以兼容geopandas等包
    """
    print("=" * 60)
    print("NumPy版本兼容性修复工具")
    print("=" * 60)
    print("\n检测到NumPy 2.x版本与geopandas不兼容")
    print("需要将NumPy降级到1.x版本\n")
    
    # 检查当前NumPy版本
    try:
        import numpy as np
        current_version = np.__version__
        print(f"当前NumPy版本: {current_version}")
        
        if current_version.startswith('2.'):
            print("\n需要降级NumPy到1.x版本")
        else:
            print("\nNumPy版本正常，无需修复")
            return True
    except ImportError:
        print("NumPy未安装")
        return False
    
    print("\n" + "=" * 60)
    print("修复方案")
    print("=" * 60)
    print("\n请选择修复方法：")
    print("\n方法1：使用conda降级（推荐，如果使用Anaconda）")
    print("  运行命令：")
    print("    conda install 'numpy<2' -y")
    print("\n方法2：使用pip降级")
    print("  运行命令：")
    print("    pip install 'numpy<2' --force-reinstall")
    print("\n方法3：创建新的conda环境（最安全）")
    print("  运行命令：")
    print("    conda create -n geo_env python=3.11 numpy=1.24 geopandas -y")
    print("    conda activate geo_env")
    print("    pip install requests")
    print("\n" + "=" * 60)
    
    # 询问是否自动执行
    response = input("\n是否自动执行方法2（pip降级）？(y/n): ").strip().lower()
    
    if response == 'y':
        print("\n正在降级NumPy...")
        try:
            subprocess.check_call([
                sys.executable, "-m", "pip", "install", 
                "numpy<2", "--force-reinstall", "--no-cache-dir"
            ])
            print("\n✓ NumPy降级成功！")
            print("请重新运行下载脚本。")
            return True
        except subprocess.CalledProcessError as e:
            print(f"\n✗ 降级失败: {e}")
            print("\n请手动执行上述命令。")
            return False
    else:
        print("\n请手动执行上述命令之一。")
        return False

if __name__ == "__main__":
    fix_numpy_compatibility()

