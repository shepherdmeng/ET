getWU = function(year = NULL, airport_code = NULL, month = NULL, day = NULL, type = NULL){
  
  load("data/airports.rda")
  
  if(nchar(airport_code) == 3) { airport_code = as.character(airports[which(airport_code == ap$V5),6]) }
  if(!(airport_code %in% ap$V6)) { stop("Airport code not found") }
  
  if((type %in% c("daily", "weekly", "monthly"))){
    type = simpleCap(type)
  } else { stop("'", type, "' ", "is not a valid type. Select from:\n (1) daily (2) weekly (3) monthly") }
  
  if( type == 'Daily' ){ index = 5 } else { index = 4 }
  if( is.null(day) ){ day = 1 }
  
  data.names = c(
    "Day",
    "T_max",    "T_avg",    "T_min",    # Temperture         (C)
    "DP_max",   "DP_avg",   "DP_min",   # Dew Point          (C)
    "H_max",    "H_avg",    "H_min",    # Humidity           (%)
    "SLP_max",  "SLP_avg",  "SLP_min",  # Sea Level Pressure (hPa)
    "V_min",    "V_avg",    "V_max",    # Visibility         (km)
    "Wind_max", "Wind_avg", "Wind_min", # Wind               (km/hr)
    "PPT_tot",
    "Events" )
  
  df.airports = NULL
  
  for( i in seq_along(year)){
    for( j in seq_along(month)) {
      
      df = xml2::read_html(paste0("https://www.wunderground.com/history/airport/",
                                  toupper(airport_code), "/",
                                  year[i], "/", month[j], "/", day, "/",
                                  paste0(type, "History"),
                                  ".html?req_city=&req_state=&req_statename=&reqdb.zip=&reqdb.magic=&reqdb.wmo=")) %>%
        rvest::html_nodes("table") %>%
        .[[index]] %>%
        rvest::html_table()
      
      df = df[-1,]
      df[df == "-"] <- NA
      df[df == "T"] <- NA
      
      df = data.frame(
        Date = as.Date(paste0(year[i], "-", month[j], "-", df[,1] )),
        Year = year[i],
        Month = month[j],
        df)
      
      t = as.matrix(df)
      hope = data.frame(lapply(split(t, col(t)), type.convert, as.is = TRUE), stringsAsFactors = FALSE)
      df.airports = rbind(df.airports, hope)
      message( "Year ", year[i], " Month ", j,  " downloaded.")
    }
  }
  names(df.airports) = c("Date", "Year", "Month", data.names)
  df.airports[,1] = as.Date(df.airports[,1])
  return(df.airports)
}
