# Load requisite libraries
library(dplyr)
library(tidyr)
library(forecast)
library(stats)
library(datasets)
library(TTR)

# Load in dataset file
origin <- read.csv("data/fluData.csv")

# Custom function to "proper"-ize string values
proper <- function(s) sub("(.)", ("\\U\\1"), tolower(s), pe=TRUE)

# Extract locations data from origin
locations <- data.frame(
  County = proper(origin$County),
  Coordinates = origin$County.Centroid
)

## Remove duplicate rows
locations <- distinct(locations)

## Separate coordinates into lat/long
locations <- locations %>% separate(Coordinates, c("Latitude", "Longitude"), ", ")
locations$Latitude <- substring(locations$Latitude, first = 2)
locations$Longitude <- substring(locations$Longitude, 1, nchar(locations$Longitude) -
                                   1)
locations$Latitude <- as.double(locations$Latitude)
locations$Longitude <- as.double(locations$Longitude)

fluData <- origin[-c(2, 6, 8, 9)]
fluData$County <- proper(fluData$County)
names(fluData) <- c("Period", "County", "Week", "Date", "Incidents")
fluData$Date <- as.Date(fluData$Date, format = "%m/%d/%Y")
fluData <- aggregate(Incidents ~ ., fluData, sum)

trainingData <- fluData[fluData$Period != "2018-2019" & fluData$Period != "2019-2020", ]
testingData <- fluData[fluData$Period == "2018-2019" | fluData$Period == "2019-2020", ]

# Periods used to train the forecasting models
trainingPeriods <- setdiff(
  unique(fluData$Period),
  c("2018-2019", "2019-2020")
)

seasonMetadata <- fluData %>%
  dplyr::filter(Period %in% trainingPeriods) %>%
  dplyr::group_by(Period) %>%
  dplyr::summarise(
    SeasonStart = min(Date[Week == 40]),
    LastCalendarWeek = max(Week),
    .groups = "drop"
  )

activeWeekSchedule <- fluData %>%
  dplyr::filter(Period %in% trainingPeriods) %>%
  dplyr::distinct(Period, Week) %>%
  dplyr::left_join(seasonMetadata, by = "Period") %>%
  dplyr::mutate(
    WeekOffset = dplyr::if_else(
      Week >= 40,
      Week - 40,
      LastCalendarWeek - 40 + Week
    ),
    CalendarDate = SeasonStart + (WeekOffset * 7)
  ) %>%
  dplyr::select(Period, Week, CalendarDate)

activeTrainingData <- tibble(
  County = sort(unique(trainingData$County))
) %>%
  crossing(activeWeekSchedule) %>%
  left_join(
    trainingData %>%
      dplyr::rename(ObservedDate = Date),
    by = c("Period", "County", "Week")
  ) %>%
  transmute(
    Period,
    County,
    Week,
    Date = coalesce(ObservedDate, CalendarDate),
    Incidents = replace_na(Incidents, 0)
  )

# Add the non-reporting/off-season weeks 21-39.
#
# Each date continues weekly from that county and season's week 20 date.
offSeasonTrainingData <- activeTrainingData %>%
  filter(Week == 20) %>%
  transmute(
    Period,
    County,
    Week20Date = Date
  ) %>%
  crossing(Week = 21:39) %>%
  transmute(
    Period,
    County,
    Week,
    Date = Week20Date + ((Week - 20) * 7),
    Incidents = 0
  )

# Combine reported, imputed, and off-season observations.
trainingDataFull <- bind_rows(
  activeTrainingData,
  offSeasonTrainingData
) %>%
  arrange(County, Date)

# Drop week variable from full training set, order by date
trainingDataFull <- trainingDataFull[-c(3)]
trainingDataFull <- trainingDataFull[order(trainingDataFull$Date),]

## Add dummy weeks to test set
testingOffSeasonData <- testingData %>%
  dplyr::filter(
    Period == "2018-2019",
    Week == 20
  ) %>%
  dplyr::transmute(
    Period,
    County,
    Week20Date = Date
  ) %>%
  tidyr::crossing(Week = 21:39) %>%
  dplyr::transmute(
    Period,
    County,
    Week,
    Date = Week20Date + ((Week - 20) * 7),
    Incidents = 0
  )

testingData <- dplyr::bind_rows(
  testingData,
  testingOffSeasonData
) %>%
  dplyr::arrange(County, Date)


forecastCounty <- function(countyData, countyName) {
  startTime <- Sys.time()
  
  message("Training models for ", countyName)
  
  incidents <- countyData %>%
    dplyr::arrange(Date) %>%
    dplyr::pull(Incidents)
  
  timeSeriesData <- stats::ts(
    incidents,
    frequency = 52,
    start = c(2009, 40)
  )
  
  arimaModel <- forecast::auto.arima(timeSeriesData)
  
  holtWintersModel <- stats::HoltWinters(
    timeSeriesData,
    seasonal = "additive"
  )
  
  arimaForecast <- forecast::forecast(
    arimaModel,
    h = 61
  )
  
  holtWintersForecast <- forecast::forecast(
    holtWintersModel,
    h = 61
  )
  
  elapsedTime <- Sys.time() - startTime
  
  message(
    countyName,
    " processing time: ",
    round(as.numeric(elapsedTime, units = "secs"), 2),
    " seconds"
  )
  
  tibble::tibble(
    ARIMA = as.numeric(arimaForecast$mean),
    HW = as.numeric(holtWintersForecast$mean),
    Time_Period = seq_len(61)
  )
}


outerStartTime <- Sys.time()

arimaTable <- trainingDataFull %>%
  dplyr::arrange(County, Date) %>%
  dplyr::group_by(County) %>%
  dplyr::group_modify(
    ~ forecastCounty(
      countyData = .x,
      countyName = .y$County[[1]]
    )
  ) %>%
  dplyr::ungroup()

outerTotalTime <- Sys.time() - outerStartTime

message(
  "Total processing time: ",
  round(as.numeric(outerTotalTime, units = "mins"), 2),
  " minutes"
)
