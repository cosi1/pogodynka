library(shiny)

function(input, output, session) {
  
  # Retrieve Meteo.pl API key from a local file
  api_key = get_api_key()
  
  # Create a temporary file for the plot
  temp_file = tempfile(fileext = ".png")
  
  # Initial longitude/latitude
  lng_lat = reactiveValues(
    lng = 19.25,
    lat = 50.48
  )
  
  # Render map
  output$map = leaflet::renderLeaflet({
    lng = lng_lat$lng
    lat = lng_lat$lat
    m = leaflet::addTiles(map = leaflet::leaflet())
    m = leaflet::setView(m, lng = 19, lat = 51.5, zoom = 5)
    m = leaflet::addMarkers(m, lng = lng, lat = lat)
  })
  
  # Render forecast plot
  output$temp = renderPlot({
    date = paste0(input$date, "T00")
    lng = lng_lat$lng
    lat = lng_lat$lat
    
    temp_data = try(
      get_meteo(
        lng = lng,
        lat = lat,
        date = date,
        api_key = api_key
      ),
      silent = TRUE
    )
    if (inherits(temp_data, "try-error")) {
      dump_log(type = "error", message = as.character(temp_data))
      NULL
      
    } else {
      dump_log(type = "success", message = list(lat = lat, lng = lng))
      plot = ggplot2::ggplot(
        data = temp_data,
        mapping = ggplot2::aes(x = times, y = data)
      ) +
        ggplot2::geom_line()
      suppressMessages(ggplot2::ggsave(plot = plot, filename = temp_file))
      plot
    }
  })
  
  observe({
    point = input$map_click
    if (!is.null(point)) {
      lng_lat$lng = point$lng
      lng_lat$lat = point$lat
    }
  })
  
  # Handler for downloading forecast plot
  output$download = downloadHandler(
    filename = "meteo.png",
    content = function(file) {
      file.copy(temp_file, file, overwrite = TRUE)
    },
    contentType = "image/png"
  )
}
