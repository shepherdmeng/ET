#' Parse Data from Raw Station Output
#'
#' @param data a csv of RAW PRISM and USGS Flow data
#' @param stationID the station to parse
#' @param timestep timestep to average to: options include 'monthly' and 'annual'
#' @param WaterYear (logical) should the data be converted to water year?
#'
#' @return a list of data.frames, one for each station
#' @export
#'
#' @examples


getStationData = function(data = NULL,
                          stationID = NULL,
                          timestep = "annual", WaterYear = TRUE) {
  items = list()

  for (k in seq_along(stationID)) {
    stat.data = data[data$GAGE_ID == stationID[k],]

    info = stat.data[, colnames(data) %in% c("DRAIN_SQKM", "YEAR", "GAGE_ID")]

    PPT  = stat.data[, grepl('PPT', colnames(stat.data))]
    Q    = stat.data[, grepl('DISCHARGE', colnames(stat.data))]
    TMAX = stat.data[, grepl('TMAX', colnames(stat.data))]
    TMIN = stat.data[, grepl('TMIN', colnames(stat.data))]

    date.matrix = NULL

    for (i in 1:nrow(PPT)) {
      dates  = as.Date(paste(info$YEAR[i], sprintf("%02d", 1:12), "01", sep = "-"), "%Y-%m-%d")
      days = NULL

      for (j in seq_along(dates)) {
        days = append(days, numberOfDays(dates[j]))
      }

      date.matrix = rbind(date.matrix, days)

    }

    Q.m3   = Q  * .0283168 * 86400 * date.matrix
    PPT.m3 = PPT  *  info$DRAIN_SQKM[1] * 1000
    ET     = PPT.m3 - Q.m3
    colnames(ET)   = paste0("ET_", sprintf("%02d", 1:12))
    ET.P = ET / PPT.m3
    colnames(ET.P) = paste0("Ratio_", sprintf("%02d", 1:!2))

    if(WaterYear){
        TMAX = toWY(TMAX)
        TMIN = toWY(TMIN)
        Q.m3 = toWY(Q.m3)
        PPT.m3 = toWY(PPT.m3)
        ET = toWY(ET)
        ET.P = toWY(ET.P)

        info = info[-1,]

        colnames(Q.m3)   = paste0("Q_", sprintf("%02d", c(10:12, 1:9)))
        colnames(PPT.m3)   = paste0("PPT_", sprintf("%02d", c(10:12, 1:9)))
        colnames(ET)   = paste0("ET_", sprintf("%02d", c(10:12, 1:9)))
        colnames(ET.P) = paste0("Ratio_", sprintf("%02d", c(10:12, 1:9)))
        colnames(TMAX) = paste0("TMAX", sprintf("%02d", c(10:12, 1:9)))
        colnames(TMIN) = paste0("TMIN", sprintf("%02d", c(10:12, 1:9)))
      }

    fin = as.data.frame(cbind(info, Q.m3, PPT.m3, TMAX, TMIN, ET, ET.P))


    if (timestep == 'annual') {
      fin = data.frame(
        info,
        Q = rowMeans(fin[, grepl('Q', colnames(fin))]),
        PPT = rowMeans(fin[, grepl('PPT', colnames(fin))]),
        TMAX = rowMeans(fin[, grepl('TMAX', colnames(fin))]),
        TMIN = rowMeans(fin[, grepl('TMIN', colnames(fin))]),
        ET = rowMeans(fin[, grepl('ET', colnames(fin))]),
        ET.P = rowMeans(fin[, grepl('Ratio', colnames(fin))]),
        DECADE = substr(info$YEAR, 2, 3)
      )
    }


    #if (length(stationID) > 1) {
      items[[paste(stationID[k])]] = fin
    #} else {
   #   items = fin
   # }
  }


  return(items)

}
