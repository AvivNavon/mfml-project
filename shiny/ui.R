library(shiny)
library(shinythemes)
library(markdown)
library(DT)
library(plotly)

# fluidRow(
#   conditionalPanel(
#     condition = "input.task == 'reg'", plotlyOutput("plot_perf", height = "400px", width = "1400px")),
#   conditionalPanel(
#     condition = "input.task == 'clf'", plotlyOutput("bla", height = "400px", width = "1400px"))
# )


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
      column(3, 
             h3("Performance Plot"),
             radioButtons("task", "Choose Task",
                          choices = c("Classification" = "clf", "Regression" = "reg"),
                          selected = "clf", 
                          inline = TRUE)
            ),
      column(2, h3("---"),
             selectInput("metric", "Choose Metric", choices = c(""))
             ),
      column(2, h3("---"),
             selectInput("model", "Choose Model", choices = c(""))
      ),
      column(2, offset = 1,
             h3("Compare VI"),
             selectInput("method1", "Choose Method (1)", choices = c("")),
             selectInput("method2", "Choose Method (2)", choices = c(""))
      ),
      column(2, 
             h3("---"),
             sliderInput('n',
                         label = 'Number of Variables',
                         min = 1, 
                         max = 10,
                         value = 5, 
                         step = 1)
      )
    ),
    hr(),
    helpText(HTML(markdownToHTML(fragment.only = TRUE,
                                 text = c("")
                                 )
                  )
             ),
    helpText(HTML(markdownToHTML(fragment.only = TRUE,
            text = c(
"
**Description**
  
Calculated using 5-fold CV. 

**Models**

  - `RF` - Random Forest (Classifier or Regressor).
  - `SVM` - Support Vector Classifier or Regressor.
  - `LR` - Logistic Regression (Classification) or Linear Regression.

---

<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css'>
<span style='color:#d12525'> **<i class = 'fa fa-heart-o'></i>** </span>
"
      )
     )
    )
   )
  )
 )