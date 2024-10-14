library(shiny)
library(ggplot2)
library(dplyr)
library(shinythemes)
library(ggrepel)
library(grid)

dataset <- mtcars

ui <- fluidPage(
  titlePanel("Dashboard with Dynamic Graph"),
  
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    sidebarPanel(
      selectInput("xvar", "X-axis Variable:", choices = names(mtcars)),
      selectInput("yvar", "Y-axis Variable:", choices = names(mtcars))
    ),
    
    mainPanel(
      plotOutput("plot")
    )
  )
)

server <- function(input, output) {
  output$plot <- renderPlot({
    ggplot(dataset, aes_string(x = input$xvar, y = input$yvar)) +
      geom_point(shape = 1, size = 4, stroke = 1.25) +
      geom_text_repel(aes(label = rownames(mtcars))) +
      ggtitle("Plot of mtcars") +
      theme_bw()
  })
}

shinyApp(ui = ui, server = server)
