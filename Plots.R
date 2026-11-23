#Extremtage pro Jahr, deutscher Durchschnitt
day.max.analysis |> 
  filter(Ort.ID == 9999, year(Datum) != 2026) |>
  group_by('Jahr' = year(Datum)) |> 
  summarise('Extremtage' = sum(Extrem)) |>
  ggplot(aes(Jahr, Extremtage)) + geom_line() #geom_smooth?

#Extremtage pro Jahr Balken, deutscher Durchschnitt
day.max.analysis |>
  filter(Ort.ID == 9999, year(Datum) != 2026) |>
  group_by('Jahr' = year(Datum)) |>
  summarise('Extremtage' = sum(Extrem, na.rm = TRUE)) |>
  ggplot(aes(Jahr, Extremtage)) + geom_col()

#Extremtage pro Jahrzehnt, deutscher Durchschnitt
day.max.analysis |>
  filter(Ort.ID == 9999, year(Datum) != 2026) |>
  group_by('Jahr' = year(Datum)) |>
  summarise('Extremtage' = sum(Extrem, na.rm = TRUE)) |>
  ggplot(aes(as.factor((Jahr %/% 10) * 10), Extremtage)) + labs(x = "Jahrzehnt") +
  geom_boxplot()

#Hitzewellen pro Jahr, deutscher Durchschnitt
heat.waves |>
  filter(Ort.ID == 9999, year(Beginn) != 2026) |>
  group_by('Jahr' = year(Beginn)) |>
  summarise('Hitzewellen' = n()) |>
  ggplot(aes(Jahr, Hitzewellen)) + geom_line()

#Hitzewellen pro Jahr Balken, deutscher Durchschnitt
heat.waves |>
  filter(Ort.ID == 9999, year(Beginn) != 2026) |>
  group_by('Jahr' = year(Beginn)) |>
  summarise('Hitzewellen' = n()) |>
  ggplot(aes(Jahr, Hitzewellen)) + geom_col()


#Hitzewellen pro Jahrzehnt Boxplot, deutscher Durchschnitt
day.max.analysis |>
  filter(Ort.ID == 9999, year(Datum) != 2026) |>
  group_by('Jahr' = year(Datum)) |>
  summarise('Hitzewellen' = sum(Beginn.Hw, na.rm = TRUE)) |>
  ggplot(aes(as.factor((Jahr %/% 10) * 10), Hitzewellen)) + labs(x = "Jahrzehnt") +
  geom_boxplot()

#Dauer vs. Intensität von Hitzewellen, deutscher Mittelwert
heat.waves |>
  filter(Ort.ID == 9999) |>
  ggplot(aes(Dauer, Intensität.m)) + 
  geom_bin_2d(binwidth = c(1, 1/3)) +
  scale_fill_gradient(low = "#9999BB", high = "#111166") +
  geom_smooth(method = "loess", #ich messe dieser Linie wenig Aussagekraft bei
              se = FALSE, 
              color = "red")

#mittlere Intensität von Hitzewellen pro Jahr, deutscher Durchschnitt
heat.waves |>
  filter(Ort.ID == 9999, year(Beginn) != 2026) |>
  group_by('Jahr' = year(Beginn)) |>
  summarise('m.Intensität' = sum(Intensität.m)) |>
  ggplot(aes(Jahr, m.Intensität)) + geom_line()

#kumulierte Intensität von Hitzewellen pro Jahr, deutscher Durchschnitt
intensity.c |>
  filter(Ort.ID == 9999) |>
  ggplot(aes(Jahr, Intensität.k)) + geom_line()

#Dauer vs. Intensität von Hitzewellen, nur die stationen
heat.waves |>
  filter(Ort.ID != 9999) |>
  ggplot(aes(Dauer, Intensität.m)) + 
  geom_bin_2d(binwidth = c(1, 1/3)) +
  scale_fill_gradient(low = "#E0E1FF", high = "#111166") +
  geom_smooth(method = "loess", 
              se = FALSE, 
              color = "red")

#f2 dauer
heat.waves |>
  filter(year(Beginn) != 2026, Ort.ID != 9999) |>
  group_by('Jahr' = year(Beginn)) |>
  summarise('Dauer.m' = mean(Dauer)) |>
  ungroup() |>
  ggplot(aes(Jahr, Dauer.m)) +
  geom_line() +
  geom_smooth(
    method = "lm",
    se = FALSE,
    color = "red"
  ) 

#f2 mittlere Intensität
heat.waves |>
  filter(year(Beginn) != 2026, Ort.ID != 9999) |>
  group_by('Jahr' = year(Beginn)) |>
  summarise('Intensität.m' = mean(Intensität.m)) |>
  ungroup() |>
  ggplot(aes(Jahr, Intensität.m)) +
  geom_line() +
  geom_smooth(
    method = "lm",
    se = FALSE,
    color = "red"
  )

#f2 kumulierte Intensität
intensity.c |>
  filter(Jahr != 2026, Ort.ID != 9999) |>
  group_by(Jahr) |>
  summarise('Intensität.k' = mean(Intensität.k)) |>
  ungroup() |>
  ggplot(aes(Jahr, Intensität.k)) +
  geom_line() +
  geom_smooth(method = "lm",
              se = FALSE,
              color = "red")

#f3 
heat.waves |>
  filter(Ort.ID != 9999, year(Beginn) != 2026) |>
  group_by(Ort.ID, 'Jahr' = year(Beginn)) |>
  summarise('Hitzewellen' = n()) |>
  ungroup() |>
  ggplot(aes(Jahr, Hitzewellen)) +
  geom_line() +
  geom_smooth(method = "lm",
              se = FALSE,
              color = "red") +
  facet_wrap(~ Ort.ID, ncol = 4)

dates <- ymd(c(
  "2026-01-15",
  "2026-05-04",
  "2026-07-15",
  "2026-09-23",
  "2026-12-31"))

quarter(dates, fiscal_start = 12)
quarter(dates, type = "year.quarter", fiscal_start = 12)

heat.waves <- heat.waves |>
  mutate(Saison = factor(quarter(Beginn, fiscal_start = 12),
                         levels = 1:4,
                         labels = c("Winter", "Frühling", "Sommer", "Herbst")),
         Saison.Jahr = year(Beginn) + (month(Beginn) == 12))

heat.waves |>
  filter(Ort.ID != 9999,
         Saison.Jahr >= 1982,
         Saison.Jahr <= 2025) |>
  count(Saison.Jahr, Saison, name = "Anzahl") |>
  ggplot(aes(x = Saison.Jahr, y = Anzahl)) +
  geom_line() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  facet_wrap(~ Saison, ncol = 2) 

