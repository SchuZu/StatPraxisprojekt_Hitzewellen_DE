#Hitzetage pro Jahr, deutscher Durchschnitt
day.max.analysis |> 
  filter(Ort.ID == 9999, year(Datum) != 2026) |>
  group_by('Jahr' = year(Datum)) |> 
  summarise('Hitzetage' = sum(Extrem)) |>
  ggplot(aes(Jahr, Hitzetage)) + geom_line() #geom_smooth?
