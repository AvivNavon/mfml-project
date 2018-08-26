library(shiny)
library(dplyr)
library(reshape2)
library(markdown)
library(DT)
library(plotly)
library(magrittr)

# read data
results <- read.csv("data/full_results.csv")
importance <- read.csv("data/full_vi.csv")

# factor to charecter
results %<>% 
  mutate_all(funs(if(is.factor(.)) as.character(.) else .))
importance %<>% 
  mutate_all(funs(if(is.factor(.)) as.character(.) else .))
# melt
importance_melt <- importance %>% melt(id = c("variable", "task"),
                                       variable.name = "method")

## Server Logic
server <- function(input, output, session) {
  ## update UI
  observe({
    # filter task
    task_name <- input$task
    curr_res <- results %>% filter(task == task_name)
    curr_importance <- importance %>% filter(task == task_name)
    curr_importance_melt <-  importance_melt %>% filter(task == task_name)
    
    # update
    models <- curr_res$model %>% unique()
    metrics <- curr_res$metric %>% unique()
    variables <- curr_importance$variable %>% unique()
    methods <- curr_importance_melt$method %>% unique()
    
    updateSliderInput(session, "n", "Number of Variables", min = 1,
                      max = length(variables), value = 5, step = 1)
    updateSelectInput(session, "method1", "Choose Method (1)", choices = methods, 
                      selected = methods[1])
    updateSelectInput(session, "method2", "Choose Method (2)", choices = methods, 
                      selected = methods[2])
    updateSelectInput(session, "metric", "Choose Metric", choices = metrics)
    updateSelectInput(session, "model", "Choose Model", choices = models)
  })
  
  get.results <- reactive({
                  m <- input$metric
                  mod <- input$model
                  task_name <- input$task
                  data <- results %>% filter(model == mod, task == task_name, metric == m) %>% 
                                      group_by(k, method) %>% 
                                      summarise(Mean = mean(value, na.rm = T))
                  return(data.frame(data))
                  })
  
  get.vi.1 <- reactive({
                    # get vi for given method
                    n_vars <- input$n
                    method_1 <- input$method1
                    task_name <- input$task
                    data <- importance_melt %>% 
                              filter(method == method_1, task == task_name) %>% 
                              arrange(-value) %>% head(n_vars)
                    return (data)
                  })
  
  get.vi.2 <- reactive({
                    # get vi for given method
                    n_vars <- input$n
                    method_2 <- input$method2
                    task_name <- input$task
                    data <- importance_melt %>% 
                              filter(method == method_2, task == task_name) %>%
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
                layout(title = "<b>Variable importance_clf</b>",
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
                layout(title = "<b>Variable importance_clf</b>",
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
