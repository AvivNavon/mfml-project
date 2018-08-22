library(shiny)
library(dplyr)
library(reshape2)
library(markdown)
library(DT)
library(plotly)

set_wd <- function() {
  library(rstudioapi) # make sure you have it installed
  current_path <- getActiveDocumentContext()$path 
  setwd(dirname(current_path ))
  print( getwd() )
}
set_wd()

results <- read.csv("../../results/clf_results_full.csv")
importance <- read.csv("../../results/clf_vi.csv")
importance_melt <- importance %>% melt(id = "variable", variable.name = "method")
clf_metric_names <- names(results %>% select(-model,	-method, -k))


methods <- as.vector(results$method %>% unique())
variables <- as.vector(importance$variable %>% unique())
models <- as.vector(results$model %>% unique())

server <- function(input, output, session) {
  ## update UI
  updateSliderInput(session, "n", "Number of Variables", min = 1, 
                    max = length(variables), value = 5, step = 1)
  updateSelectInput(session, "method1", "Choose Method (1)", choices = methods)
  updateSelectInput(session, "method2", "Choose Method (2)", choices = methods)
  updateSelectInput(session, "metric", "Choose Metric", choices = clf_metric_names)
  updateSelectInput(session, "model", "Choose Model", choices = models)
  
  get.results <- reactive({
                  m <- input$metric
                  mod <- input$model
                  data <- results %>% filter(model == mod) %>% 
                                      group_by(k, method) %>% 
                                      summarise(Mean = mean(get(input$metric), na.rm=T))
                  return(data.frame(data))
                  })
  
  get.vi.1 <- reactive({
                    # get vi for given method
                    n_vars <- input$n
                    method_1 <- input$method1
                    data <- importance_melt %>% 
                            filter(method == method_1) %>% 
                            arrange(-value) %>% head(n_vars)
                    return (data)
                  })
  
  get.vi.2 <- reactive({
                    # get vi for given method
                    n_vars <- input$n
                    method_2 <- input$method2
                    data <- importance_melt %>% 
                      filter(method == method_2) %>% 
                      arrange(-value) %>% head(n_vars)
                    return (data)
                  })
  ## Vis.
  output$plot_perf <- renderPlotly({
                      get.results() %>% plot_ly(x = ~k,
                                                y = ~Mean,
                                                color = ~method,
                                                mode = 'markers+lines')
                    })
  
  output$vi_plot <- renderPlotly({
    
              vline <- function(x = 0, color = "black") {
                # plot vertical line
                list(
                  type = "line", 
                  y0 = 0, 
                  y1 = 1, 
                  yref = "paper",
                  x0 = x, 
                  x1 = x, 
                  line = list(color = color)
                )
              }
              
              plot1 <- get.vi.1() %>% 
                    arrange(value) %>% 
                plot_ly(x = ~value, 
                        y = ~reorder(variable, value), 
                        type = 'bar', 
                        orientation = 'h',
                        opacity = .75,
                        showlegend = FALSE,
                        marker = list(line = list(color = 'black', width = 1))) %>%
                layout(title = "<b>Variable Importance</b>",
                       tickfont = list(size = 20),
                       showlegend = FALSE,
                       xaxis = list(title = ""),
                       yaxis = list(title = "", showticklabels = TRUE),
                       paper_bgcolor = "transparent"
                       #,shapes = list(vline())
                       )
            
              plot2 <- get.vi.2() %>% 
                arrange(value) %>% 
                plot_ly(x = ~value, 
                        y = ~reorder(variable, value), 
                        type = 'bar', 
                        orientation = 'h',
                        opacity = .75,
                        showlegend = FALSE,
                        marker = list(line = list(color = 'black', width = 1))) %>%
                layout(title = "<b>Variable Importance</b>",
                       tickfont = list(size = 20),
                       showlegend = FALSE,
                       xaxis = list(title = ""),
                       yaxis = list(title = "", showticklabels = TRUE),
                       paper_bgcolor = "transparent"
                       #,shapes = list(vline())
                )
              subplot(plot1, plot2)
            })  

  ## table
  output$table <- renderDataTable(get.results() %>% arrange(method, k))
}
