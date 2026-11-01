#ich (eric) habe den code mal überprüft und er scheint richtig zu sein. 
#jemand sollte ihn aber sicherheitshalber nochmal kontrollieren


#mind Messungen pro tag, wert vorerst als platzhalter kann man jederzeit anpassen
min_messungen <- 20

# Höchste Temperatur pro Wetterstation und Tag
hoechstwert <- daten %>% 
  mutate(Datum = as.Date(Zeitstempel)) %>% #datum aus zeitstempel für neuen datensatz
  group_by(SDO_ID, Datum) %>% # nach station und datum gruppieren
  filter(n_distinct(Zeitstempel[!is.na(Wert)]) >= min_messungen) %>% #mind anzahl an messungen
  slice_max(
    order_by = Wert,
    n = 1,
    with_ties = FALSE
  ) %>% # höchster wert der gruppe
  ungroup()

#ggf. speicherort/namen anpassen und # entfernen
# write_csv(hoechstwert, "~/Desktop/hoechstwert.csv")




# Mindestanzahl gültiger Tage im 21-Tage-Fenster
# Platzhalter, jederzeit anpassbar
min_referenztage <- 15

# Daten vorbereiten
daten_extrem <- hoechstwert %>%
  select(-any_of(c(
    "Kalendertag", "Quantil_90",
    "Anzahl_Referenzwerte", "Anzahl_Referenzjahre",
    "Hitzetag"
  ))) %>%
  mutate(
    Datum = as.Date(Datum),
    Kalendertag = format(Datum, "%m-%d")
  )

# Referenzzeitraum 
ref_start <- min(year(daten_extrem$Datum))
ref_ende <- max(year(daten_extrem$Datum))

#Stationen
stationen <- daten_extrem %>%
  distinct(SDO_ID)

# Referenzdaten
referenz <- daten_extrem %>%
  select(SDO_ID, Datum, Wert)

# Alle Kalendertage inklusive 29. Februar
kalendertage <- format(
  seq(
    as.Date("2000-01-01"),
    as.Date("2000-12-31"),
    by = "day"
  ),
  "%m-%d"
)

#Schwellenwerte Liste
schwellen_liste <- vector("list", length(kalendertage))

# 0,9 Quantil berechnen die alle Tage 
for (i in seq_along(kalendertage)) {
  
  tag <- kalendertage[i]
  
  # Kalendertag bestimmen
  mitte <- as.Date(
    paste0(ref_start:ref_ende, "-", tag),
    format = "%Y-%m-%d"
  )
  
  # wegen sch... schaltjahren
  mitte <- mitte[!is.na(mitte)]
  
  # 10 Tage davor und danach
  fenster <- data.frame(
    Jahr = rep(year(mitte), each = 21),
    Datum = rep(mitte, each = 21) +
      rep(-10:10, times = length(mitte))
  )
  
  # Für jede Station alle Fenstertage
  fenster <- merge(
    fenster,
    as.data.frame(stationen),
    by = NULL
  )
  
  # Temperaturen zuordnen
  fenster <- fenster %>%
    left_join(
      referenz,
      by = c("SDO_ID", "Datum")
    )
  
  # Anzahl gültiger tageswerte pro station und jahr
  fenster <- fenster %>%
    group_by(SDO_ID, Jahr) %>%
    mutate(
      Anzahl_Tage = sum(!is.na(Wert))
    ) %>%
    ungroup()
  
  # mind tage mit werten aus referenzfenster
  gueltig <- fenster %>%
    filter(
      Anzahl_Tage >= min_referenztage,
      !is.na(Wert)
    )
  
  # 90-%-Quantil für jede Station berechnen
  schwelle <- gueltig %>%
    group_by(SDO_ID) %>%
    summarise(
      Quantil_90 = quantile(Wert, 0.90),
      Anzahl_Referenzwerte = n(),
      Anzahl_Referenzjahre = n_distinct(Jahr),
      .groups = "drop"
    ) %>%
    mutate(Kalendertag = tag)
  
  
  schwellen_liste[[i]] <- schwelle
}


schwellen <- bind_rows(schwellen_liste)

# Schwellenwerte mit höchsttemperaturen 
extremtage <- daten_extrem %>%
  left_join(
    schwellen,
    by = c("SDO_ID", "Kalendertag")
  ) %>%
  mutate(
    Hitzetag = Wert > Quantil_90
  )

# Höchstwert-Tabelle mit neuer spalte
hoechstwert <- extremtage %>%
  select(-Kalendertag)


