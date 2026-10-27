#falls packages noch nicht vorhanden (einmalig):
# install.packages("readr")
# install.packages("dplyr")
# install.packages("lubridate")

library(readr)
library(dplyr)
library(lubridate)

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

improved.data <- raw.data |> 
  #nur relevante Zeilen
  select(SDO_ID, Zeitstempel, Wert, Qualitaet_Byte) |>
  #SDO_IDs zu Faktor
  mutate(SDO_ID = factor(SDO_ID))

improved.data |> filter(minute(Zeitstempel) != 0 | second(Zeitstempel) != 0)
#nur volle Stunden in den Daten (YYYY-MM-DD HH:00:00)

improved.data$SDO_ID |> table() 
#Berlin-Tempelhof (433) und Leipzig-Holzhausen (2928) haben auffällig weniger Daten

improved.data |> filter(SDO_ID == 2928) |> group_by(year(Zeitstempel)) |> count() |> print(n = Inf)
#zwischen 1972 und 1997 keine Daten für Leipzig

improved.data |> filter(SDO_ID == 433) |> group_by(year(Zeitstempel)) |> count() |> print(n = Inf)
#zwischen 1971 und 1980 keine Daten für Berlin

all.dates <- seq(ymd_hms("1951-01-01 00:00:00"), ymd_hms("2026-01-01 23:00:00"),
                 by = dhours(1))
missing <- list()
for (i in seq_along(SDO_IDs)) {
  missing[[as.character(SDO_IDs[[i]])]] <- setdiff(all.dates, improved.data |> 
                                                     filter(SDO_ID == SDO_IDs[[i]]) |>
                                                     select(Zeitstempel) |>
                                                     pull())
#missing: Liste aller fehlenden Messzeitpkte zu jeweiliger Station    
}
num.missing <- sapply(missing, length) #Anzahl fehlende MZP zu jew. Station 
hist(missing$'433', breaks = 70, freq = TRUE) #Histogramm, wo die Daten **fehlen** (SDO_IDs durchgehen missing$'XXX')


