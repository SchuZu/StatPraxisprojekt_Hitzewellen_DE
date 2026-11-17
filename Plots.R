#Extremtage pro Jahr, deutscher Durchschnitt
day.max.analysis |> 
  filter(Ort.ID == 9999, year(Datum) != 2026) |>
  group_by('Jahr' = year(Datum)) |> 
  summarise('Extremtage' = sum(Extrem)) |>
  ggplot(aes(Jahr, Hitzetage)) + geom_line() #geom_smooth?

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
