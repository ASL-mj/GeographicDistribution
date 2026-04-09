# 下载四川省地图数据脚本（R版本）
# 功能：使用rnaturalearth包获取四川省地图数据并保存为shapefile

library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(rnaturalearthhires)

# ==================== 参数设置 ====================
# 输出目录
output_dir <- "data"

# 输出文件名
sichuan_shp <- file.path(output_dir, "sichuan.shp")
china_shp <- file.path(output_dir, "china_mainland.shp")

# ==================== 下载函数 ====================
download_sichuan_map <- function(output_dir = "data") {
  cat("============================================================\n")
  cat("四川省地图数据下载工具 (R版本)\n")
  cat("============================================================\n\n")
  
  # 创建输出目录
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    cat("创建输出目录:", output_dir, "\n")
  }
  
  # 检查是否已存在文件
  if (file.exists(sichuan_shp)) {
    cat("\n✓ 四川省地图文件已存在:", sichuan_shp, "\n")
    response <- readline("是否重新下载？(y/n): ")
    if (tolower(trimws(response)) != "y") {
      cat("跳过下载，使用现有文件。\n")
      return(sichuan_shp)
    }
  }
  
  cat("\n正在从rnaturalearth获取中国省级地图数据...\n")
  cat("注意：首次使用需要下载数据，可能需要几分钟...\n\n")
  
  tryCatch({
    # 方法1：使用rnaturalearth获取中国省级数据
    cat("[1/3] 正在下载中国省级地图数据...\n")
    china_provinces <- ne_states(country = "China", returnclass = "sf")
    
    if (nrow(china_provinces) == 0) {
      stop("未能获取中国省级地图数据")
    }
    
    cat("✓ 成功获取", nrow(china_provinces), "个省级行政区\n")
    
    # 显示所有省份名称（前10个）
    cat("\n可用的省份名称（前10个）:\n")
    if ("name" %in% names(china_provinces)) {
      print(head(unique(china_provinces$name), 10))
    } else {
      cat("可用的列名:", paste(names(china_provinces), collapse = ", "), "\n")
    }
    
    # 提取四川省
    cat("\n[2/3] 正在提取四川省数据...\n")
    
    # 尝试匹配四川省
    sichuan <- NULL
    if ("name" %in% names(china_provinces)) {
      # 尝试不同的名称
      possible_names <- c("Sichuan", "四川", "Sichuan Province")
      for (name in possible_names) {
        sichuan <- china_provinces[china_provinces$name == name, ]
        if (nrow(sichuan) > 0) {
          cat("✓ 找到四川省！匹配名称:", name, "\n")
          break
        }
      }
      
      # 如果还没找到，尝试模糊匹配
      if (is.null(sichuan) || nrow(sichuan) == 0) {
        all_names <- unique(china_provinces$name)
        sichuan_keywords <- c("sichuan", "四川", "sc")
        for (prov_name in all_names) {
          if (any(sapply(sichuan_keywords, function(kw) grepl(kw, tolower(prov_name), ignore.case = TRUE)))) {
            sichuan <- china_provinces[china_provinces$name == prov_name, ]
            if (nrow(sichuan) > 0) {
              cat("✓ 通过模糊匹配找到:", prov_name, "\n")
              break
            }
          }
        }
      }
    }
    
    if (is.null(sichuan) || nrow(sichuan) == 0) {
      # 显示所有省份
      cat("\n未能自动找到四川省，所有省份列表:\n")
      if ("name" %in% names(china_provinces)) {
        print(sort(unique(china_provinces$name)))
      }
      stop("未能找到四川省数据，请手动检查")
    }
    
    # 保存四川省地图
    cat("\n[3/3] 正在保存文件...\n")
    st_write(sichuan, sichuan_shp, delete_dsn = TRUE)
    cat("✓ 四川省地图已保存到:", sichuan_shp, "\n")
    
    # 同时保存完整的中国省级地图（排除台湾）
    if ("name" %in% names(china_provinces)) {
      china_mainland <- china_provinces[china_provinces$name != "Taiwan", ]
    } else {
      china_mainland <- china_provinces
    }
    st_write(china_mainland, china_shp, delete_dsn = TRUE)
    cat("✓ 中国省级地图已保存到:", china_shp, "\n")
    
    cat("\n============================================================\n")
    cat("下载完成！\n")
    cat("============================================================\n")
    cat("\n输出文件:\n")
    cat("  - 四川省地图:", sichuan_shp, "\n")
    cat("  - 中国省级地图:", china_shp, "\n")
    cat("\n现在可以在R脚本中使用以下代码:\n")
    cat('  sichuan <- st_read("', sichuan_shp, '")\n', sep = "")
    
    return(sichuan_shp)
    
  }, error = function(e) {
    cat("\n✗ 错误:", conditionMessage(e), "\n")
    cat("\n可能的解决方案:\n")
    cat("  1. 检查网络连接\n")
    cat("  2. 安装必要的包:\n")
    cat("     install.packages(c('sf', 'rnaturalearth', 'rnaturalearthdata', 'rnaturalearthhires'))\n")
    cat("  3. 如果网络问题，可以尝试使用Python脚本下载\n")
    stop(e)
  })
}

# ==================== 执行下载 ====================
# 运行下载函数
tryCatch({
  download_sichuan_map(output_dir)
}, error = function(e) {
  cat("\n下载失败:", conditionMessage(e), "\n")
})

