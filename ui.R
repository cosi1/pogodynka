library(shiny)

today = Sys.Date()

fluidPage(
  titlePanel("\U26C5 Pogodynka"),
  sidebarLayout(
    sidebarPanel(
      dateInput(
        inputId = "date",
        label = "Date",
        value = today,
        max = today
      ),
      leaflet::leafletOutput(
        outputId = "map",
        height = "300"
      )
    ),
    mainPanel(
      plotOutput(
        outputId = "temp"
      ),
      downloadLink(
        outputId = "download"
      )
    )
  )
)
