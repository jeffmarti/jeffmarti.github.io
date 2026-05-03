library(shiny)
library(dplyr)

ui <- fluidPage(
  titlePanel("Jeff's App List Manager"),
  sidebarLayout(
    sidebarPanel(
      textInput("title", "App Title"),
      textInput("url", "App URL"),
      textAreaInput("purpose", "Purpose/Description"),
      textInput("source", "Data Source (e.g., NRCS SNOTEL)"),
      textInput("domain", "Domain (e.g., Washington State)"),
      actionButton("save", "Add App & Update GitHub", class = "btn-primary")
    ),
    mainPanel(
      tableOutput("current_list")
    )
  )
)

server <- function(input, output, session) {
  # Load existing data
  apps_df <- reactiveVal(read.csv("apps.csv", stringsAsFactors = FALSE))
  
  output$current_list <- renderTable({ apps_df() })
  
  observeEvent(input$save, {
    # 1. Update the local CSV
    new_entry <- data.frame(
      App_Title = input$title,
      URL = input$url,
      Purpose = input$purpose,
      Data_Source = input$source,
      Domain = input$domain
    )
    updated_df <- rbind(apps_df(), new_entry)
    write.csv(updated_df, "apps.csv", row.names = FALSE)
    apps_df(updated_df)
    
    # 2. Generate the new HTML
    new_html <- generate_html(updated_df)
    writeLines(new_html, "index.html")
    
    # 3. Push to GitHub (requires a Personal Access Token)
    # You would use system() commands or the httr package here to 
    # push the new index.html to your jeffm.github.io repo.
    showNotification("List updated and pushed to GitHub!")
  })
}

shinyApp(ui, server)