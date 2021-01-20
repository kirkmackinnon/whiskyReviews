#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(data.table)
library(rvest)
library(DT)
library(ggplot2)
library(plotly)

test <- read_html("https://ralfywhisky.webnode.be/ralfy/whisky/")
test %>% html_node("table") %>% html_table() -> mydt
setDT(mydt)
mydt <- mydt[-1,][order(-X5)]
names(mydt) <- c("Number", "Whisky", "Maltmarks", "Link", "Date")
mydt$Maltmarks <- as.numeric(mydt$Maltmarks)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Ralfy's Whisky Reviews"),
    
    sidebarPanel(
        htmlOutput("sideDesc")
    ),

        # Show a plot of the generated distribution
    mainPanel(
        plotlyOutput("histogram"),
        dataTableOutput("whiskyTable")
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$sideDesc <- renderText(
        "<b>Table of values from:</b><br> 
        <a href='https://ralfywhisky.webnode.be'>https://ralfywhisky.webnode.be</a>
        <br><br>
        <b>Whisky reviews from:</b><br>
        <a href='https://ralfy.com/'>https://ralfy.com/</a>
        <br><br>
        <b>Code available here:</b><br>
        <a href=''></a>"
    )
    
    output$histogram <- renderPlotly(
        print(ggplotly(ggplot(mydt, aes(x = Maltmarks)) + 
                           geom_histogram(binwidth = 1) +
                           theme_bw(base_size = 20) +
                           theme(panel.grid = element_blank()) +
                           labs(title = "Maltmark Distribution") +
                           ylab("Count")
                       ))
    )
    
    output$whiskyTable <- renderDataTable({
        DT::datatable(mydt, options = list(pageLength = 20, paging = FALSE, scrollY = 900), rownames = FALSE, selection = list(mode = "single", target = "row"))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
