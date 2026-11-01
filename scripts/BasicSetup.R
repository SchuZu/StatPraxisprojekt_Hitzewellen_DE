#falls packages noch nicht vorhanden (einmalig):
# install.packages("readr")
# install.packages("dplyr")
# install.packages("lubridate")

library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)

#Zeile 1 bis 8 mit pacman-package machen...


#import data
raw.data <- read_csv("data/raw/data_OBS_DEU_PT1H_T2M.csv")

#Namen den SDO_IDs zuordnen (sonst unbenutzt, aber für später erledigt)
SDO_IDs <- raw.data$SDO_ID |> unique() |> sort()
names(SDO_IDs) <- c("Berlin-Tempelhof", "Braunlage", "Bremen", "Essen-Bredeney", 
                    "Freiburg", "Freudenstadt", "Gardelegen",
                    "Garmisch-Partenkirchen", "Leipzig Holzhausen", "Lindenberg",
                    "List auf Sylt", "Regensburg", "Rostock-Warnemünde", 
                    "Trier-Petisberg", "Würzburg", "Mannheim")

all.times <- seq(ymd_hms("1951-01-01 00:00:00"), ymd_hms("2026-01-01 23:00:00"),
                 by = dhours(1))

#Ort als Faktor, NA für fehlende Daten, 'Celsius' statt 'Wert'
improved.data <- left_join(data.frame('Ort.ID' = rep(SDO_IDs, each = length(all.times)),
                                      'Zeit' = rep(all.times, times = length(SDO_IDs))),
                           raw.data |> select(SDO_ID, Zeitstempel, Wert), 
                           by = join_by(Ort.ID == SDO_ID, Zeit == Zeitstempel)) |>
  mutate(Ort.ID = as.factor(Ort.ID)) |>
  rename('Celsius' = Wert)

#Tageshöchstwerte(THW) (fehlende Werte ignoriert, außer ganzer Tag fehlt, dann NA)
day.max <- improved.data |> 
  group_by(Ort.ID, 'Tag' = date(Zeit)) |> 
  summarise('n.fehlend' = sum(is.na(Celsius)),
            'Celsius.max' = ifelse(all(is.na(Celsius)), NA, max(Celsius, na.rm = TRUE)))

#nützlich für genauere Analyse der Stundendaten
joined <- right_join(day.max,
                     improved.data |> mutate('Tag' = date(Zeit)),
                     by = join_by(Ort.ID == Ort.ID, Tag == Tag)) |>
  mutate(Tag = NULL)

#Schwelle aus Referenzzeitraum bestimmen (1951-1980)
q <- 0.9 #Quantil

#threshold <- 
    


