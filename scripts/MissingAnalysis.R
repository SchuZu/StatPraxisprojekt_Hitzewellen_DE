source ("scripts/BasicSetup.R") #eher ungut

#(***): ausgenommen Werte, an denen der ganze Tag fehlt
message (paste("Es fehlen", improved.data |> filter(is.na(Celsius)) |> nrow(), "Stundenwerte\n"))
message (paste("Es fehlen", day.max |> filter(is.na(Celsius.max)) |> nrow(), "Tageshöchstwerte\n"))

#Uhrzeit vs. #THW
joined |>
  filter(n.fehlend == 0, Celsius.max == Celsius) |>
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
  filter(n.fehlend == 0) |>
  count(Ort.ID)

#Anzahl NAs, falls THW vorhanden
joined |>
  filter(is.na(Celsius), !is.na(Celsius.max)) |>
  count(Ort.ID, date(Zeit)) |>
  ggplot(aes(x = n, y = Ort.ID)) + geom_boxplot()

#Schalttag?
threshold  |> ggplot(aes(Datum, Quantil, colour = Ort.ID)) + geom_line()






