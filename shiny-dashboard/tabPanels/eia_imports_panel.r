load_import_by_country = function(selected_data){
    sheetIndex = 3
    if (selected_data == '1-week-avg') { sheetIndex=2}
    reported_country = read.xlsx('../data/reports/psw08.xls', sheetIndex = sheetIndex)
    reported_country = reported_country[c(-1,-2,-nrow(reported_country)),]
    colnames(reported_country) = c('discharge_date','Canada', 'Saudi Arabia', 'Venezuela', 'Mexico', 'Colombia', 'Iraq', 'Ecuador', 'Nigeria', 'Kuwait', 'Angola')
    reported_country = reported_country[,colSums(is.na(reported_country))<nrow(reported_country)]
    reported_country[is.na(reported_country)] = 0
    for (col in c('discharge_date','Canada', 'Saudi Arabia', 'Venezuela', 'Mexico', 'Colombia', 'Iraq', 'Ecuador', 'Nigeria', 'Kuwait', 'Angola')) {
        reported_country[,col] = as.numeric(paste(reported_country[,col]))
    }
    reported_country$discharge_date = as.Date(reported_country$discharge_date, origin = "1899-12-30")
    reported_country = subset(reported_country, discharge_date > '2013-01-01')
    reported_country
}

load_us_imports = function(path, selected_data, discharging_days){
    days = 28
    if (selected_data == '1-week-avg'){
        days = 7
    }
    us_imports = read.csv(path)
    us_imports$discharge_date = as.Date(us_imports$discharge_date)
    rownames(us_imports) = us_imports$discharge_date
    us_imports[,-1] = rollmean(us_imports[,-1], discharging_days, fill=c(0), align='right')
    us_imports[,-1] = rollmean(us_imports[,-1], days, fill=c(0), align='right')
    us_imports
}

reported_country = load_import_by_country('Data 2')
REPORTED_COUNTRIES = paste(names(reported_country)[-1])
# UI
eia_imports_tab = tabPanel(
  title='EIA US Imports', value='eia_export',
  # Sidebar
  sidebarPanel(width = 2
    # dropdown input for Export Data
    ,selectInput(inputId='selected_eia_data', label='Select Export Country', choices=c('1-week-avg','4-week-avg') , selected='4-week-avg')
    ,hr()
    # dropdown input for Export Country
    ,selectInput(inputId='selected_eia_export', label='Select Data frequency', choices=REPORTED_COUNTRIES, selected='Saudi Arabia')
    ,hr()
    # discharging days
    ,numericInput(inputId='selected_discharging', label='Select discharging days', min=1, max=20, step=1, value=1)
    ,hr()
    # Download button
    ,downloadButton('eia_download', label = "Download Data")
    ,hr()
    # add the img
    ,img(src='7p300.png', height='60px', width='auto')
  ),
  # Body
  mainPanel(width = 10
    ,plotlyOutput("eia_plot")
  )
)

eia_imports_server = function(input, output) {
    reported_country = reactive({load_import_by_country(input$selected_eia_data)})
    us_imports180628 = reactive({load_us_imports('../data/derivs/us_imports180628.csv', input$selected_eia_data, input$selected_discharging)})
    us_imports180705 = reactive({load_us_imports('../data/derivs/us_imports180705.csv', input$selected_eia_data, input$selected_discharging)})
    us_imports180712 = reactive({load_us_imports('../data/derivs/us_imports180712.csv', input$selected_eia_data, input$selected_discharging)})
    us_imports180719 = reactive({load_us_imports('../data/derivs/us_imports180719.csv', input$selected_eia_data, input$selected_discharging)})
    plot_data = reactive({
        plot = reported_country()[,c('discharge_date',input$selected_eia_export)]
        colnames(plot) = c('discharge_date', 'EIA Reported')
        for (i in seq(1,10)){
            plot[nrow(plot) + 1,] = list(plot[nrow(plot),'discharge_date']+7,NA)
        }
        plot = merge(plot, us_imports180628()[,c('discharge_date', gsub(' ', '.' ,input$selected_eia_export))], by = 'discharge_date', all.x = TRUE)
        plot = merge(plot, us_imports180705()[,c('discharge_date', gsub(' ', '.' ,input$selected_eia_export))], by = 'discharge_date', all.x = TRUE)
        plot = merge(plot, us_imports180712()[,c('discharge_date', gsub(' ', '.' ,input$selected_eia_export))], by = 'discharge_date', all.x = TRUE)
        plot = merge(plot, us_imports180719()[,c('discharge_date', gsub(' ', '.' ,input$selected_eia_export))], by = 'discharge_date', all.x = TRUE)
        colnames(plot) = c('discharge_date', 'EIA Reported', '7Park180628','7Park180705', '7Park180712', '7Park180719')
        plot
    })
    output$eia_plot  = renderPlotly({
        print(tail(plot_data()))
        plot = plot_ly(plot_data(), x = ~discharge_date, y =plot_data()[['EIA Reported']], type = 'scatter', mode = "lines", name='EIA Reported')
        plot = add_trace(plot, y = plot_data()[['7Park180628']], type = 'scatter', mode = "lines", name ='7Park 180628')
        plot = add_trace(plot, y = plot_data()[['7Park180705']], type = 'scatter', mode = "lines", name ='7Park 180705')
        plot = add_trace(plot, y = plot_data()[['7Park180712']], type = 'scatter', mode = "lines", name ='7Park 180712')
        plot = add_trace(plot, y = plot_data()[['7Park180719']], type = 'scatter', mode = "lines", name ='7Park 180719')
        layout(plot, title = paste(input$selected_country),
           yaxis = list(title = "kbpd")
       )
    })

    output$eia_download = downloadHandler(
    filename = function() {
      paste0('EIA backtest','-', Sys.Date(), '.csv')
    },
    content = function(con) {
      write.csv(plot_data(), con)
    }
  )
}