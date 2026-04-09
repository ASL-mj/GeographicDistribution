library(shiny)
library(tidyverse)
library(ggplot2)
library(maps)
library(sf)
library(RColorBrewer)
library(rnaturalearth)
library(rnaturalearthdata)
library(rnaturalearthhires)

# Define translation dictionary
translations <- list(
  "en" = list(
    "app_title" = "Sample Geographic Distribution Visualization",
    "data_source_label" = "Select data source:",
    "use_sample_data" = "Use sample data",
    "upload_data" = "Upload your data",
    "upload_file_label" = "Upload coordinates data file (TSV format)",
    "map_range_tab" = "Map Range",
    "longitude_range" = "Longitude range:",
    "latitude_range" = "Latitude range:",
    "color_settings_tab" = "Color Settings",
    "ocean_color" = "Ocean color:",
    "land_color" = "Land color:",
    "sample_color_scheme" = "Sample point color scheme:",
    "custom_rgb_help" = "Set custom RGB colors for the first 5 species. Each color requires values between 0-255.",
    "species_label" = "Species",
    "red" = "Red",
    "green" = "Green",
    "blue" = "Blue",
    "sample_point_tab" = "Sample Point Settings",
    "point_size" = "Sample point size:",
    "point_shape" = "Sample point shape:",
    "circle" = "Circle",
    "triangle" = "Triangle",
    "square" = "Square",
    "diamond" = "Diamond",
    "cross" = "Cross",
    "output_tab" = "Output Settings",
    "output_width" = "Output width (inches):",
    "output_height" = "Output height (inches):",
    "image_dpi" = "Image DPI:",
    "title_legend_tab" = "Title & Legend Settings",
    "chart_title" = "Chart Title:",
    "title_position" = "Title Position:",
    "center" = "Center",
    "left" = "Left",
    "right" = "Right",
    "title_font_size" = "Title Font Size:",
    "legend_position" = "Legend Position:",
    "legend_inside" = "Place legend inside plot", 
    "legend_x" = "Legend X position (0-1):", 
    "legend_y" = "Legend Y position (0-1):", 
    "top" = "Top",
    "bottom" = "Bottom",
    "top_left" = "Top Left",
    "top_right" = "Top Right",
    "bottom_left" = "Bottom Left",
    "bottom_right" = "Bottom Right",
    "legend_text_size" = "Legend Text Size:",
    "legend_border" = "Add Border to Legend",
    "download_pdf" = "Download PDF",
    "download_png" = "Download PNG",
    "longitude_label" = "Longitude",
    "latitude_label" = "Latitude",
    "language_switch" = "中文",  # Button text to switch to Chinese
    "font_family" = "Font:", 
    "font_simsun" = "SimSun",
    "font_times" = "Times New Roman",
    "font_arial" = "Arial"
  ),
  "zh" = list(
    "app_title" = "样本地理分布图可视化",
    "data_source_label" = "选择数据来源:",
    "use_sample_data" = "使用示例数据",
    "upload_data" = "上传自己的数据",
    "upload_file_label" = "上传经纬度数据文件（TSV格式）",
    "map_range_tab" = "地图范围",
    "longitude_range" = "经度范围:",
    "latitude_range" = "纬度范围:",
    "color_settings_tab" = "颜色设置",
    "ocean_color" = "海洋颜色:",
    "land_color" = "陆地颜色:",
    "sample_color_scheme" = "样本点配色方案:",
    "custom_rgb_help" = "为前5个样本种类设置自定义RGB颜色。每个颜色需要0-255之间的值。",
    "species_label" = "种类",
    "red" = "红色",
    "green" = "绿色",
    "blue" = "蓝色",
    "sample_point_tab" = "样本点设置",
    "point_size" = "样本点大小:",
    "point_shape" = "样本点形状:",
    "circle" = "圆形",
    "triangle" = "三角形",
    "square" = "方形",
    "diamond" = "菱形",
    "cross" = "十字形",
    "output_tab" = "输出设置",
    "output_width" = "输出宽度 (英寸):",
    "output_height" = "输出高度 (英寸):",
    "image_dpi" = "图像DPI:",
    "title_legend_tab" = "标题和图例设置",
    "chart_title" = "图表标题:",
    "title_position" = "标题位置:",
    "center" = "居中",
    "left" = "靠左",
    "right" = "靠右",
    "title_font_size" = "标题字体大小:",
    "legend_position" = "图例位置:",
    "legend_inside" = "将图例放置在图内", 
    "legend_x" = "图例X位置 (0-1):", 
    "legend_y" = "图例Y位置 (0-1):", 
    "top" = "顶部",
    "bottom" = "底部",
    "top_left" = "左上角",
    "top_right" = "右上角",
    "bottom_left" = "左下角",
    "bottom_right" = "右下角",
    "legend_text_size" = "图例文字大小:",
    "legend_border" = "为图例添加边框",
    "download_pdf" = "下载PDF",
    "download_png" = "下载PNG",
    "longitude_label" = "经度",
    "latitude_label" = "纬度",
    "language_switch" = "English",  # Button text to switch to English
    "font_family" = "字体:", 
    "font_simsun" = "宋体",
    "font_times" = "新罗马体",
    "font_arial" = "Arial字体"
  )
)

# Define UI
ui <- function(request) {
  # Get language from URL query parameter
  query <- parseQueryString(request$QUERY_STRING)
  lang <- if (!is.null(query$lang) && query$lang %in% c("en", "zh")) query$lang else "en"
  
  # Get translation dictionary for current language
  t <- translations[[lang]]
  
  fluidPage(
    # Language switch button in the top right corner
    div(style = "position: absolute; right: 10px; top: 10px;",
        actionButton("switchLang", t$language_switch, 
                     icon = icon("language"),
                     style = "color: #fff; background-color: #337ab7; border-color: #2e6da4;")
    ),
    
    titlePanel(t$app_title),
    
    sidebarLayout(
      sidebarPanel(
        # Data loading options
        radioButtons("dataSource", t$data_source_label,
                     choices = setNames(c("sample", "upload"), 
                                      c(t$use_sample_data, t$upload_data)),
                     selected = "sample"),
        
        # Only show when "Upload your data" is selected
        conditionalPanel(
          condition = "input.dataSource == 'upload'",
          fileInput("dataFile", t$upload_file_label,
                    accept = c("text/tsv", "text/tab-separated-values,text/plain", ".tsv", ".txt"))
        ),
        
        # Create custom options tabs
        tabsetPanel(
          tabPanel(t$map_range_tab, 
                   # Map range adjustment
                   sliderInput("longRange", t$longitude_range,
                               min = -180, max = 180, value = c(96, 123)),
                   sliderInput("latRange", t$latitude_range,
                               min = -90, max = 90, value = c(22, 33))
          ),
          
          tabPanel(t$color_settings_tab, 
                   # Map color scheme
                   selectInput("mapSeaColor", t$ocean_color, 
                               choices = list("Light blue" = "#B3D9FF", 
                                            "Deep blue" = "#99CCFF", 
                                            "White" = "#FFFFFF",
                                            "Azure" = rgb(0, 127, 255, maxColorValue=255),
                                            "Sky blue" = rgb(135, 206, 235, maxColorValue=255),
                                            "Cyan" = rgb(0, 255, 255, maxColorValue=255),
                                            "Navy" = rgb(0, 0, 128, maxColorValue=255)), 
                               selected = "#B3D9FF"),
                   selectInput("mapFillColor", t$land_color, 
                               choices = list("Light yellow" = "#F5F5DD", 
                                            "Light gray" = "#E8E8E8", 
                                            "White" = "#FFFFFF",
                                            "Beige" = rgb(245, 245, 220, maxColorValue=255),
                                            "Tan" = rgb(210, 180, 140, maxColorValue=255),
                                            "Light green" = rgb(220, 240, 220, maxColorValue=255),
                                            "Light brown" = rgb(210, 180, 160, maxColorValue=255)), 
                               selected = "#F5F5DD"),
                   selectInput("colorPalette", t$sample_color_scheme, 
                               choices = list("Default" = "default", 
                                            "Rainbow" = "rainbow", 
                                            "Set1" = "Set1", 
                                            "Set2" = "Set2", 
                                            "Set3" = "Set3",
                                            "Paired" = "Paired",
                                            "Dark2" = "Dark2",
                                            "Accent" = "Accent",
                                            "Pastel1" = "Pastel1",
                                            "Pastel2" = "Pastel2",
                                            "Custom RGB" = "custom_rgb"), 
                               selected = "default"),
                   
                   # Custom RGB color section - only show when "Custom RGB" is selected
                   conditionalPanel(
                     condition = "input.colorPalette == 'custom_rgb'",
                     helpText(t$custom_rgb_help),
                     div(style = "display: flex; flex-wrap: wrap;",
                         div(style = "width: 50%;",
                             numericInput("rgb1R", paste(t$species_label, "1 -", t$red), 255, min = 0, max = 255),
                             numericInput("rgb1G", paste(t$species_label, "1 -", t$green), 0, min = 0, max = 255),
                             numericInput("rgb1B", paste(t$species_label, "1 -", t$blue), 0, min = 0, max = 255)
                         ),
                         div(style = "width: 50%;",
                             numericInput("rgb2R", paste(t$species_label, "2 -", t$red), 0, min = 0, max = 255),
                             numericInput("rgb2G", paste(t$species_label, "2 -", t$green), 0, min = 0, max = 255),
                             numericInput("rgb2B", paste(t$species_label, "2 -", t$blue), 255, min = 0, max = 255)
                         )
                     ),
                     div(style = "display: flex; flex-wrap: wrap;",
                         div(style = "width: 50%;",
                             numericInput("rgb3R", paste(t$species_label, "3 -", t$red), 0, min = 0, max = 255),
                             numericInput("rgb3G", paste(t$species_label, "3 -", t$green), 255, min = 0, max = 255),
                             numericInput("rgb3B", paste(t$species_label, "3 -", t$blue), 0, min = 0, max = 255)
                         ),
                         div(style = "width: 50%;",
                             numericInput("rgb4R", paste(t$species_label, "4 -", t$red), 255, min = 0, max = 255),
                             numericInput("rgb4G", paste(t$species_label, "4 -", t$green), 255, min = 0, max = 255),
                             numericInput("rgb4B", paste(t$species_label, "4 -", t$blue), 0, min = 0, max = 255)
                         )
                     ),
                     div(style = "display: flex; flex-wrap: wrap;",
                         div(style = "width: 50%;",
                             numericInput("rgb5R", paste(t$species_label, "5 -", t$red), 255, min = 0, max = 255),
                             numericInput("rgb5G", paste(t$species_label, "5 -", t$green), 0, min = 0, max = 255),
                             numericInput("rgb5B", paste(t$species_label, "5 -", t$blue), 255, min = 0, max = 255)
                         )
                     )
                   )
          ),
          
          tabPanel(t$sample_point_tab, 
                   # Sample point style
                   sliderInput("pointSize", t$point_size, 
                               min = 0.5, max = 5, value = 2, step = 0.5),
                   selectInput("pointShape", t$point_shape, 
                               choices = setNames(c(16, 17, 15, 18, 3), 
                                                c(t$circle, t$triangle, t$square, t$diamond, t$cross)), 
                               selected = 16)
          ),
          
          tabPanel(t$output_tab, 
                   # Output size
                   numericInput("outWidth", t$output_width, 10, min = 5, max = 20),
                   numericInput("outHeight", t$output_height, 6, min = 3, max = 15),
                   numericInput("dpi", t$image_dpi, 300, min = 72, max = 600)
          ),
          
          tabPanel(t$title_legend_tab,
                   # Title settings
                   textInput("plotTitle", t$chart_title, t$app_title),
                   selectInput("titlePosition", t$title_position,
                               choices = setNames(c("panel.middle", "panel.left", "panel.right"),
                                                c(t$center, t$left, t$right)),
                               selected = "panel.middle"),
                   sliderInput("titleSize", t$title_font_size, 
                               min = 8, max = 32, value = 16, step = 1),
                   
                   # Font selection
                   selectInput("fontFamily", t$font_family,
                              choices = setNames(c("SimSun", "Times New Roman", "Arial"),
                                              c(t$font_simsun, t$font_times, t$font_arial)),
                              selected = "SimSun"),
                   
                   # Legend settings
                   selectInput("legendPosition", t$legend_position, 
                               choices = setNames(list("right", "left", "top", "bottom",
                                                    c(0, 1), c(1, 1), c(0, 0), c(1, 0)),
                                                c(t$right, t$left, t$top, t$bottom,
                                                  t$top_left, t$top_right, t$bottom_left, t$bottom_right)),
                               selected = "right"),
                   
                   # Custom legend position inside plot
                   checkboxInput("legendInside", t$legend_inside, value = FALSE),
                   
                   # Only show when legend is inside plot
                   conditionalPanel(
                     condition = "input.legendInside == true",
                     sliderInput("legendX", t$legend_x, 
                                 min = 0, max = 1, value = 0.95, step = 0.01),
                     sliderInput("legendY", t$legend_y, 
                                 min = 0, max = 1, value = 0.25, step = 0.01)
                   ),
                   
                   sliderInput("legendTextSize", t$legend_text_size, 
                               min = 6, max = 20, value = 8, step = 1),
                   checkboxInput("legendBox", t$legend_border, value = FALSE)
          )
        ),
        
        # Download buttons
        br(),
        downloadButton("downloadPDF", t$download_pdf),
        downloadButton("downloadPNG", t$download_png)
      ),
      
      mainPanel(
        plotOutput("mapPlot", height = "600px")
      )
    )
  )
}

# Define server logic
server <- function(input, output, session) {
  
  # Store current language as reactive value
  currentLang <- reactiveVal("en")
  
  # Initialize language based on URL parameter when session starts
  observe({
    query <- parseQueryString(session$clientData$url_search)
    if (!is.null(query$lang) && query$lang %in% c("en", "zh")) {
      currentLang(query$lang)
    }
  })
  
  # Language switching
  observeEvent(input$switchLang, {
    # Toggle language
    newLang <- ifelse(currentLang() == "en", "zh", "en")
    currentLang(newLang)
    
    # Redirect to the same page with new language parameter
    updateQueryString(paste0("?lang=", newLang), mode = "replace")
    session$reload()
  })
  
  # Read data
  sampleData <- reactive({
    if (input$dataSource == "sample") {
      # Use sample data
      read_tsv("input/经纬度信息.txt")
    } else {
      # Use uploaded data
      req(input$dataFile)
      read_tsv(input$dataFile$datapath)
    }
  })
  
  # Create map
  createMap <- reactive({
    # Get language for labels
    lang <- currentLang()
    t <- translations[[lang]]
    
    # World map data
    world_map <- map_data("world")
    
    # China mainland provinces
    china_mainland <- ne_states(country = "China", returnclass = "sf")
    # Get Taiwan separately
    taiwan <- ne_countries(scale = "large", country = "Taiwan", returnclass = "sf")
    # Change Taiwan to province level
    taiwan$region <- "Taiwan"
    taiwan$name <- "Taiwan"
    # Combine Taiwan and mainland
    china_full <- rbind(
      china_mainland %>% select(name, geometry),
      taiwan %>% select(name, geometry)
    )
    
    # Map colors
    map_sea <- input$mapSeaColor
    map_fill <- input$mapFillColor
    world_map_color <- '#D9D9D9'
    china_map_color <- '#CACACA'
    
    # Map range
    Long_limit <- input$longRange
    Lati_limit <- input$latRange
    
    # Set color scheme
    if(input$colorPalette == "custom_rgb") {
      # Create custom RGB color scale
      species_list <- unique(sampleData()$Species)
      n_species <- min(length(species_list), 5)  # Limit to 5 species for now
      
      # Create RGB colors for each species
      custom_colors <- c(
        rgb(input$rgb1R, input$rgb1G, input$rgb1B, maxColorValue = 255),
        rgb(input$rgb2R, input$rgb2G, input$rgb2B, maxColorValue = 255),
        rgb(input$rgb3R, input$rgb3G, input$rgb3B, maxColorValue = 255),
        rgb(input$rgb4R, input$rgb4G, input$rgb4B, maxColorValue = 255),
        rgb(input$rgb5R, input$rgb5G, input$rgb5B, maxColorValue = 255)
      )[1:n_species]
      
      # Create named vector for scale_color_manual
      names(custom_colors) <- species_list[1:n_species]
      
      color_scale <- scale_color_manual(values = custom_colors)
    } else if(input$colorPalette != "default") {
      color_scale <- scale_color_brewer(palette = input$colorPalette)
    } else {
      color_scale <- scale_color_discrete()
    }
    
    # Draw map
    p <- ggplot() +
      # Draw world map base
      geom_polygon(data = world_map %>% filter(!region==c('China','Taiwan')), 
                   aes(x = long, y = lat, group = group),
                   fill = map_fill, color = world_map_color, size=0.1) +
      # Draw China provinces
      geom_sf(data = china_full, fill = map_fill, color = china_map_color, size=0.1) +
      # Add sample points
      geom_point(data = sampleData(), 
                 aes(x = longitude, y = latitude, color = Species), 
                 size = input$pointSize,
                 shape = as.numeric(input$pointShape)) +
      # Apply color scheme
      color_scale +
      coord_sf(xlim = Long_limit, ylim = Lati_limit) +
      labs(x=t$longitude_label, y=t$latitude_label, 
           title=input$plotTitle) +
      theme_minimal() +
      theme(
        # Set font family for all text elements
        text = element_text(family = input$fontFamily),
        
        # Title settings
        plot.title = element_text(
          size = input$titleSize,
          hjust = if(input$titlePosition == "panel.middle") 0.5 
                  else if(input$titlePosition == "panel.left") 0 
                  else 1,
          family = input$fontFamily
        ),
        
        # Legend settings
        legend.position = if(input$legendInside) c(input$legendX, input$legendY) else input$legendPosition,
        legend.text = element_text(size = input$legendTextSize),
        legend.title = element_blank(),
        legend.background = if(input$legendBox) element_rect(color = "black", fill = "white", alpha = 0.7) 
                          else element_blank(),
        
        # Axis settings - 使用固定值
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        
        # Other settings
        panel.background = element_rect(fill=map_sea, color = NA),
        panel.grid.major = element_blank()
      )
    
    return(p)
  })
  
  # Display map
  output$mapPlot <- renderPlot({
    req(sampleData())
    createMap()
  })
  
  # Download PDF
  output$downloadPDF <- downloadHandler(
    filename = function() {
      paste0("sample_geographic_distribution_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".pdf")
    },
    content = function(file) {
      # 使用标准pdf设备，但更改字体设置以使用R原生支持的字体
      p <- createMap()
      
      # 临时修改地图的字体设置，使用系统支持的字体
      p <- p + theme(
        text = element_text(family = "sans"),
        plot.title = element_text(family = "sans"),
        axis.text = element_text(family = "sans"),
        axis.title = element_text(family = "sans"),
        legend.text = element_text(family = "sans")
      )
      
      # 使用标准pdf设备
      ggsave(file, p, width = input$outWidth, height = input$outHeight, 
             dpi = input$dpi, device = "pdf")
    },
    contentType = "application/pdf"
  )
  
  # Download PNG
  output$downloadPNG <- downloadHandler(
    filename = function() {
      paste0("sample_geographic_distribution_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".png")
    },
    content = function(file) {
      ggsave(file, createMap(), width = input$outWidth, height = input$outHeight, 
             dpi = input$dpi, device = "png")
    },
    contentType = "image/png"
  )
}

# Run application
shinyApp(ui = ui, server = server) 