# Paths
IM_EX_PATH = '../data/derivs/im_ex.feather'

# Static global data
im_ex = read_feather(IM_EX_PATH)
EXPORT_COUNTRIES = c('all', paste(unique(im_ex$load_country_name)))
IMPORT_COUNTRIES = c('all', paste(unique(im_ex$discharge_country_name)))
SHIP_TYPES = paste(unique(im_ex$size_range_alternative))
PRODUCT_TYPES = c('all', paste(unique(im_ex$cargo_type)))

# Selector settings
SELECTED_EXPORT_COUNTRY = 'Saudi Arabia'
SELECTED_IMPORT_COUNTRY = 'United States of America'
SELECTED_PRODUCT_TYPE = 'Crude'
SELECTED_SHIP_TYPE = SHIP_TYPES

# UI
im_ex_tab = tabPanel(
  title='Import-Export', value='im_ex',
  # Sidebar
  sidebarPanel(width = 2
    # dropdown input for Import Country
    ,selectInput(inputId='selected_import', label='Select Import Country', choices=IMPORT_COUNTRIES, selected=SELECTED_IMPORT_COUNTRY)
    ,hr()
    # dropdown input for Export Country
    ,selectInput(inputId='selected_export', label='Select Export Country', choices=EXPORT_COUNTRIES, selected=SELECTED_EXPORT_COUNTRY)
    ,hr()
    # dropdown input for Product type
    ,selectInput(inputId='selected_product', label='Select Product type', choices=PRODUCT_TYPES, selected=SELECTED_PRODUCT_TYPE)
    ,hr()
    # dropdown input for Ship type
    ,selectInput(inputId='selected_ships', label='Select Ship type', choices=SHIP_TYPES, selected=SELECTED_SHIP_TYPE, multiple=TRUE)
    ,hr()
    # smooth over days
    ,numericInput(inputId='selected_smooth', label='Select over how many days to smooth', min=1, max=60, step=1, value=7)
    ,hr()
    # Download button
    ,downloadButton('im_ex_download', label = "Download Data")
    ,hr()
    # add the img
    ,img(src='7p300.png', height='60px', width='auto')
  ),
  # Body
  mainPanel(width = 10
    ,plotlyOutput("im_ex_plot")
  )
)

# Server
im_ex_server_function = function(input, output) {
  plot_data = reactive({
    data = im_ex
    if (input$selected_import != 'all'){
      data = filter(data, discharge_country_name == input$selected_import)
    }
    if (input$selected_export != 'all'){
      data = filter(data, load_country_name == input$selected_export)
    }
    if (input$selected_product != 'all'){
      data = filter(data, cargo_type == input$selected_product)
    }
    data = filter(data, size_range_alternative %in% input$selected_ships)
    #data = idata.frame(data)
    data = ddply(data, c('discharge_date','size_range_alternative'), summarize ,cargo_barrels=sum(cargo_barrels))
    data = dcast(data,  discharge_date ~ size_range_alternative, value.var='cargo_barrels')
    data$discharge_date = as.Date(data$discharge_date)
    dates = data.frame(seq(min(data$discharge_date),
                           max(data$discharge_date),
                           by="days")
                          )
    colnames(dates) = c('discharge_date')
    data = merge(dates, data, by ='discharge_date', all.x = TRUE)
    data[is.na(data)] = 0
    data[,-1] = rollmean(data[,-1], input$selected_smooth, fill=c(0), align='right')
    data
  })

  output$im_ex_plot = renderPlotly({
    ships = input$selected_ships
    if (NROW(ships) > 0) {}
      plot = plot_ly(plot_data(), x = ~discharge_date, y =plot_data()[[ships[NROW(ships)]]], type = 'scatter', mode = "lines", name=ships[NROW(ships)])
      for (ship in ships[-NROW(ships)]) {
        plot = add_trace(plot, y = plot_data()[[ship]], type = 'scatter', mode = "lines", name =ship)
      }
    layout(plot, title = paste(input$selected_export, 'exports to', input$selected_import, 'of', input$selected_product),
           yaxis = list (title = "kbpd")
           #legend = list(orientation = 'h', y=1)
          )
  })

  output$im_ex_download = downloadHandler(
    filename = function() {
      paste0(input$selected_export, '-exports-to-', input$selected_import, '-of-', input$selected_product, '-', Sys.Date(), '.csv')
    },
    content = function(con) {
      write.csv(plot_data(), con)
    }
  )
}