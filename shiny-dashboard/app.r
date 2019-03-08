library(shiny)
library(plotly)

# Other enviorment variables
prj_title = 'Sample Project'
# UI
ui = fluidPage(navbarPage(
  title=prj_title
  ,id='tabchosen'
  ,tabPanel(
    title='EIA US Imports', value='eia_export',
    # Sidebar
    sidebarPanel(width = 2
      # dropdown input for Export Data
      ,selectInput(inputId='data_dropdown', label='Select plot', choices=c('scatter','histogram') , selected='scatter')
      ,hr()
      # add the img
      ,img(src='7p300.png', height='60px', width='auto')
    ),
    # Body
    mainPanel(width = 10
      ,plotlyOutput("example_graph")
    )
  )
))

# Server
shinyServer = function(input, output) {

    output$example_graph = renderPlotly({
        x = c(0,1,2,3)
        y = c(2, 1, 4, 3)
        type = NULL
        if (input$data_dropdown == 'histogram') {type='bar'}
        if (input$data_dropdown == 'scatter') {type='scatter'}
        plot = plot_ly(x=x, y=y, type=type, mode='lines')
        layout(plot, title = paste(input$data_dropdown),
               yaxis=list(title = "Numbers"),
               xaxis=list(title = "Numbers")
       )
    })
}

shinyApp(ui = ui, server = shinyServer)