library(shiny)
library(shinythemes)
library(markdown)
library(DT)
library(plotly)

# Define UI for application
ui <- fluidPage(
  theme = shinytheme("cosmo"),
  navbarPage(
    "MFML - Variable Importance",
    tabPanel("Performance", icon = icon("line-chart"),
             div(plotlyOutput("plot_perf", height = "400px", width = "1400px"), 
                 align = "center")
             ),
    tabPanel("VI", icon = icon("star-o"),
             div(plotlyOutput("vi_plot", height = "400px", width = "1400px"), 
                 align = "center")
    ),
    tabPanel("Data", icon = icon("table"),
             column(12,  dataTableOutput('table'))
    )
  ),
  hr(),
  wellPanel(
    fluidRow(
      column(2, 
             h3("Switch Plot"),
             radioButtons("plot", "Choose plot",
                          choices = c("Fit", "Error"),
                          selected = "Fit", 
                          inline = TRUE)
      ),
      column(2, 
             h3("Fit Plots"),
             sliderInput('n',
                          label = '# Vars.',
                          min = 1, 
                          max = 10,
                          value = 5)
      ),
      column(2,
             h3(" --- "),
             selectInput("method", "Method", choices = c("rf", "shap"), selected = "rf")
      ),
      column(2, offset = 2,
             h3("Compare VI"),
             selectInput("method1", "Choose Method (1)", choices = c("")),
             selectInput("method2", "Choose Method (2)", choices = c(""))
      )
    ),
    hr(),
    helpText(HTML(markdownToHTML(fragment.only = TRUE,
                                 text = c(""
                                 ))))
    ,
    helpText(HTML(markdownToHTML(fragment.only = TRUE,
 text = c(
"
<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css'>
<span style='color:#d12525'> **<i class = 'fa fa-heart-o'></i>** </span>
"
      )
     )
    )
   )
  )
 )