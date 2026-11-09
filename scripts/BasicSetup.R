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


SDO_IDs <- raw.data$SDO_ID |> unique() |> sort()
#bundesdeutsches Mittel
SDO_IDs <- c(SDO_IDs, 9999)

#Namen den SDO_IDs zuordnen (sonst unbenutzt, aber für später erledigt)
names(SDO_IDs) <- c("Berlin-Tempelhof", "Braunlage", "Bremen", "Essen-Bredeney", 
                    "Freiburg", "Freudenstadt", "Gardelegen",
                    "Garmisch-Partenkirchen", "Leipzig Holzhausen", "Lindenberg",
                    "List auf Sylt", "Regensburg", "Rostock-Warnemünde", 
                    "Trier-Petisberg", "Würzburg", "Mannheim", "Deutschland-Avg")

#alle Zeitpunkte, für die Daten erhoben werden sollen
times.all <- seq(ymd_hms("1951-01-01 00:00:00"), ymd_hms("2026-01-01 23:00:00"),
                 by = dhours(1))

#Ort als Faktor, NA für fehlende Daten, 'Celsius' statt 'Wert'
improved.data <- left_join(data.frame('Ort.ID' = rep(SDO_IDs, each = length(times.all)),
                                      'Zeit' = rep(times.all, times = length(SDO_IDs))),
                           raw.data |> select(SDO_ID, Zeitstempel, Wert), 
                           by = join_by(Ort.ID == SDO_ID, Zeit == Zeitstempel)) |>
  mutate(Ort.ID = as.factor(Ort.ID)) |>
  rename('Celsius' = Wert)

#Tageshöchstwerte(THW)
missing.max <- 24
day.max <- improved.data |> 
  group_by(Ort.ID, 'Datum' = date(Zeit)) |> 
  summarise('n.fehlend' = sum(is.na(Celsius)),
            'Celsius.max' = ifelse(sum(is.na(Celsius)) >= missing.max, NA, max(Celsius, na.rm = TRUE)))

#Deutsche Mittelwerte
ger.mean <- day.max |>
  group_by(Datum) |>
  summarise('Ort.ID' = as.factor(9999),
            'Celsius.max' = round(mean(Celsius.max, na.rm = TRUE), 1), #Mittelwerte der THW
            'n.fehlend' = sum(is.na(Celsius.max))) #hier Anzahl der fehlenden Stationen
day.max <- rbind(day.max, ger.mean)

#Möglichkeit, Schaltjahre zu verbannen
leap.year <- TRUE
if (leap.year) {
  year.length <- 366
  year <- 1972 #(fast) arbiträres Schaltjahr
} else {
  year.length <- 365
  year <- 1973
  day.max <- day.max |> 
    filter(!(day(Datum) == 29 & month(Datum) == 2))
}

#nützlich für genauere Analyse der Stundendaten
joined <- right_join(day.max,
                     improved.data |> mutate('Tag' = date(Zeit)),
                     by = join_by(Ort.ID == Ort.ID, Datum == Tag)) |>
  mutate(Tag = NULL)

#Schwelle aus Referenzzeitraum (RZR) bestimmen (1951-1980)
q <- 0.9 #Quantil

#für RZR Data.Frame erstellen; eine Zeile enthät für Ort und Datum alle 
#Temperaturen der drei Wochen, die für die Quantilberechnung nötig sind
ref.table <- day.max |>
  filter(Datum < ymd("1981-01-01")) |>
  group_by(Ort.ID) |>
  mutate('Ref-10' = lag(Celsius.max, 10),
         'Ref-9' = lag(Celsius.max, 9),
         'Ref-8' = lag(Celsius.max, 8),
         'Ref-7' = lag(Celsius.max, 7),
         'Ref-6' = lag(Celsius.max, 6),
         'Ref-5' = lag(Celsius.max, 5),
         'Ref-4' = lag(Celsius.max, 4),
         'Ref-3' = lag(Celsius.max, 3),
         'Ref-2' = lag(Celsius.max, 2),
         'Ref-1' = lag(Celsius.max, 1),
         'Ref0' = Celsius.max,
         'Ref+1' = lead(Celsius.max, 1),
         'Ref+2' = lead(Celsius.max, 2),
         'Ref+3' = lead(Celsius.max, 3),
         'Ref+4' = lead(Celsius.max, 4),
         'Ref+5' = lead(Celsius.max, 5),
         'Ref+6' = lead(Celsius.max, 6),
         'Ref+7' = lead(Celsius.max, 7),
         'Ref+8' = lead(Celsius.max, 8),
         'Ref+9' = lead(Celsius.max, 9),
         'Ref+10' = lead(Celsius.max, 10),
         Celsius.max = NULL,
         n.fehlend = NULL) |>
  ungroup()

q <- 0.9 #Quantil

#Kalendertage für Schwellen für jeden Ort
threshold <- tibble('Ort.ID' = as.factor(rep(SDO_IDs, each = year.length)), 
                    'Datum' = rep(seq(from = ymd(paste0(year, "-01-01")), 
                                       to = ymd(paste0(year, "-12-31")),
                                       by = 1),
                                  times = length(SDO_IDs)),
                    'Quantil' = NA,
                    'n.fehlend' = NA) |>
  mutate('Monat' = month(Datum),
         'Tag' = day(Datum))


for (j in seq_along(SDO_IDs)) { #pro Ort
  temp.df <- ref.table |>
    filter(Ort.ID == SDO_IDs[[j]]) #Einteilen in kleinere Data.Frames (spart Zeit)
  for (i in seq_len(year.length)) { #pro Tag
    temp.vec <- temp.df |>
      filter(day(Datum) == day(threshold$Datum[[i]]),
             month(Datum) == month(threshold$Datum[[i]])) |> #suche Tag i
      select(-c(Ort.ID, Datum)) |> #nur Temperaturen übrig
      unlist() #als Vektor statt Data.Frame
    threshold$Quantil[[i + year.length * (j - 1)]] <- quantile(temp.vec, 
                                                       probs = q, 
                                                       na.rm = TRUE) #Quantil berechnen
    threshold$n.fehlend[[i + year.length * (j - 1)]] <- sum(is.na(temp.vec)) #Anzahl fehlend von 630 (168 im Schaltjahr)
  }
  rm(temp.vec, temp.df) #Hilfsobjekte löschen
  print(names(SDO_IDs)[[j]]) #Rechenzeit abschätzen
}
#umständlich aber kürzere Rechenzeit

#Ist THW > q-Quantil
day.max.final <- left_join(day.max |> 
                       mutate('Monat' = month(Datum),
                              'Tag' = day(Datum)),
                     threshold |> 
                       select(-c(n.fehlend, Datum)),
                     by = join_by(Ort.ID == Ort.ID,
                                  Tag == Tag,
                                  Monat == Monat),
                     keep = FALSE) |> #join day.max und threshold,
  select(-c(Tag, Monat)) |>
  mutate('Extrem' = Celsius.max > Quantil) |> #um das zu testen
  ungroup()

#Hitzewellen
day.max.analysis <- day.max.final |>
  filter(Datum >= ymd("1981-01-01")) |> #im Analysezeitraum
  mutate('Ext-2' = lag(Extrem, 2),
         'Ext-1' = lag(Extrem, 1),
         'Ext+1' = lead(Extrem, 1),
         'Ext+2' = lead(Extrem, 2)) |> 
  mutate('Hitzewelle' = Extrem & ( #damit Hitzewelle, muss an diesem Tag Extremtag sein und
                        (`Ext-2` & `Ext-1`) | #(entweder an den zwei vorherigen
                        (`Ext-1` & `Ext+1`) | #oder am Tag davor und danach
                        (`Ext+1` & `Ext+2`))) |> #oder an den zwei nachfolgenden) 
  mutate('Beginn.Hw' = Hitzewelle & (!`Ext-1` | is.na(`Ext-1`)), #an diesem Tag Hitzewelle, am vorherigen nicht
         'Ext-2' = NULL,
         'Ext-1' = NULL,
         'Ext+1' = NULL,
         'Ext+2' = NULL) #aufräumen

heat.waves <- day.max.analysis |> 
  filter(Hitzewelle) |> #ist Teil einer Hitzewelle
  mutate('hw_id' = cumsum(Beginn.Hw)) |>
    #fügt Hitzetagen eine id für die jeweilige Hitzewelle hinzu
    #zählt bei jedem Beginn einer neuen Hitzewelle hoch
  group_by(hw_id) |> #gruppiert die Hitzewellen und fasst sie zusammen
  reframe(
    'Beginn' = min(Datum), 
    'Ende' = max(Datum),
    'Dauer' = n(),
    'Ort.ID' = Ort.ID) |>
  unique()

ref.mean #<- Mittelwerte der Höchsttemp. im RZR
intensity.m #<- mittl. Intensität (siehe Projektbeschr.)
intensity.c #<- kum. Intensität
