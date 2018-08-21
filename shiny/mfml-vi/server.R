library(shiny)
library(dplyr)
library(reshape2)
library(markdown)
library(DT)
library(plotly)


results <- data.frame(x = 1:100, y = rnorm(100))
importance <- data.frame(method = c("rf", "rf", "shap", "shap"),
                         var = c("a", "b", "a", "b"),
                         imp = c(1, 2, 1, 1))
perf <- data.frame(method = c("rf", "rf", "rf", "shap", "shap", "shap"),
                         k = c(1,2,3,1,2,3),
                         error = c(.5, .25, .1, .4, .3, .09))

methods <- as.vector(importance$method %>% unique())
print(methods)
server <- function(input, output, session) {
  ## update UI
  updateSelectInput(session, "method", "Method", choices = methods)
  updateSelectInput(session, "method1", "Choose Method (1)", choices = methods)
  updateSelectInput(session, "method2", "Choose Method (2)", choices = methods)
  
  get.vi <- reactive({
                    # get vi for given method
                    n_vars <- input$n
                    method_ <- input$method1
                    data <- importance %>% 
                            filter(method == method_) %>% 
                            arrange(-imp) %>% head(n_vars)
                    print(data)
                    return (data)
                  })
  
  get.vi.2 <- reactive({
                    # get vi for given method
                    n_vars <- input$n
                    method_ <- input$method2
                    data <- importance %>% 
                      filter(method == method_) %>% 
                      arrange(-imp) %>% head(n_vars)
                    print(data)
                    return (data)
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
              
              plot1 <- get.vi() %>% 
                    arrange(imp) %>% 
                plot_ly(x = ~imp, 
                        y = ~reorder(var, imp), 
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
                arrange(imp) %>% 
                plot_ly(x = ~imp, 
                        y = ~reorder(var, imp), 
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
  output$plot_perf <- renderPlotly({
               perf %>% plot_ly(x = ~k,
                                y = ~error,
                                color = ~method,
                                mode = 'lines+markers')
  })
  # table
  output$table <- renderDataTable(get.vi())
}
