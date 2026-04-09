
# # 下载自然地球数据的世界地图
# def download_world_map():
#     """下载世界地图数据"""
#     # 检查是否已有世界地图数据
#     if os.path.exists('world.shp'):
#         return
    
#     # 使用Natural Earth数据
#     world_url = "https://naturalearth.s3.amazonaws.com/110m_cultural/ne_110m_admin_0_countries.zip"
#     temp_dir = tempfile.mkdtemp()
#     zip_path = os.path.join(temp_dir, "world.zip")
    
#     # 下载世界地图数据
#     print("正在下载世界地图数据...")
#     response = requests.get(world_url)
#     with open(zip_path, 'wb') as f:
#         f.write(response.content)
    
#     # 解压文件
#     with zipfile.ZipFile(zip_path, 'r') as zip_ref:
#         zip_ref.extractall(temp_dir)
    
#     # 读取并保存世界地图数据
#     world_data = gpd.read_file(os.path.join(temp_dir, 'ne_110m_admin_0_countries.shp'))
#     world_data.to_file('world.shp')
    
#     # 清理临时文件
#     shutil.rmtree(temp_dir)
#     print("世界地图数据下载完成")

# # 下载中国各省地图数据
# def download_china_map():
#     """下载中国省级行政区划数据"""
#     # 检查是否已有中国地图数据
#     if os.path.exists('china_mainland.shp') and os.path.exists('taiwan.shp'):
#         return
    
#     # 使用GADM数据
#     gadm_url = "https://geodata.ucdavis.edu/gadm/gadm4.1/shp/gadm41_CHN_shp.zip"
#     temp_dir = tempfile.mkdtemp()
#     zip_path = os.path.join(temp_dir, "china_gadm.zip")
    
#     # 下载中国地图数据
#     print("正在下载中国地图数据...")
#     response = requests.get(gadm_url)
#     with open(zip_path, 'wb') as f:
#         f.write(response.content)
    
#     # 解压文件
#     with zipfile.ZipFile(zip_path, 'r') as zip_ref:
#         zip_ref.extractall(temp_dir)
    
#     # 读取并保存中国大陆数据
#     china_adm1 = gpd.read_file(os.path.join(temp_dir, 'gadm41_CHN_1.shp'))
#     china_mainland = china_adm1[china_adm1['NAME_1'] != 'Taiwan']
#     china_mainland.to_file('china_mainland.shp')
    
#     # 创建台湾数据
#     taiwan = china_adm1[china_adm1['NAME_1'] == 'Taiwan']
#     taiwan['region'] = 'Taiwan'
#     taiwan['name'] = 'Taiwan'
#     taiwan.to_file('taiwan.shp')
    
#     # 清理临时文件
#     shutil.rmtree(temp_dir)
#     print("中国地图数据下载完成")

# # 下载所需的地图数据
# download_world_map()
# download_china_map()
