#falls packages noch nicht vorhanden (einmalig):
# install.packages("readr")
# install.packages("dplyr")
# install.packages("lubridate")

library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)

#Zeile 1 bis 8 mit pacman-package machen...

#(***): ausgenommen Werte, an denen der ganze Tag fehlt

#import data
raw.data <- read_csv("data/raw/data_OBS_DEU_PT1H_T2M.csv")

#Namen den SDO_IDs zuordnen (sonst unbenutzt, aber für später erledigt)
SDO_IDs <- raw.data$SDO_ID |> unique() |> sort()
names(SDO_IDs) <- c("Berlin-Tempelhof", "Braunlage", "Bremen", "Essen-Bredeney", 
                    "Freiburg", "Freudenstadt", "Gardelegen",
                    "Garmisch-Partenkirchen", "Leipzig Holzhausen", "Lindenberg",
                    "List auf Sylt", "Regensburg", "Rostock-Warnemünde", 
                    "Trier-Petisberg", "Würzburg", "Mannheim")

all.dates <- seq(ymd_hms("1951-01-01 00:00:00"), ymd_hms("2026-01-01 23:00:00"),
                 by = dhours(1))

#Ort als Faktor, NA für fehlende Daten, 'Celsius' statt 'Wert'
improved.data <- left_join(data.frame('Ort.ID' = rep(SDO_IDs, each = length(all.dates)),
                                      'Zeit' = rep(all.dates, times = length(SDO_IDs))),
                           raw.data |> select(SDO_ID, Zeitstempel, Wert), 
                           by = join_by(Ort.ID == SDO_ID, Zeit == Zeitstempel)) |>
  mutate(Ort.ID = as.factor(Ort.ID)) |>
  rename('Celsius' = Wert)

#Tageshöchstwerte(THW) (fehlende Werte ignoriert, außer ganzer Tag fehlt, dann NA)
day.max <- improved.data |> 
  group_by(Ort.ID, date(Zeit)) |> 
  summarise('no.missing' = ifelse(any(is.na(Celsius)), FALSE, TRUE),
            'Celsius.max' = ifelse(all(is.na(Celsius)), NA, max(Celsius, na.rm = TRUE))) |>
  rename('Tag' = 'date(Zeit)')

joined <- right_join(day.max,
                     improved.data |> mutate('Tag' = date(Zeit)),
                     by = join_by(Ort.ID == Ort.ID, Tag == Tag)) |>
  mutate(Tag = NULL)


#Uhrzeit vs. #THW
joined |>
  filter(no.missing, Celsius.max == Celsius) |>
  pull(Zeit) |> hour() |> hist()

#Uhrzeit vs. #fehlende Werte (***)
joined |> 
  filter(!is.na(Celsius.max), is.na(Celsius)) |>
  pull(Zeit) |> hour() |> hist()

#Anzahl Tage/Stunden mit mind. einem fehlenden Wert (***)
joined |> 
  filter(!is.na(Celsius.max), is.na(Celsius)) |>
  group_by(Ort.ID) |>
  summarise('Anzahl.Tage' = length(unique(date(Zeit))),
            'Anzahl.Stunde' = n())

#Anzahl Tage mit bestätigtem THW
day.max |>
  filter(no.missing) |>
  count(Ort.ID)

#Anzahl NAs, falls THW vorhanden
joined |>
  filter(is.na(Celsius), !is.na(Celsius.max)) |>
  count(Ort.ID, date(Zeit)) |>
  ggplot(aes(x = n, y = Ort.ID)) + geom_boxplot()




cat(paste("Es fehlen", improved.data |> filter(is.na(Celsius)) |> nrow(), "Stundenwerte\n"))
cat(paste("Es fehlen", day.max |> filter(is.na(Celsius.max)) |> nrow(), "Tageshöchstwerte\n"))
