# StatPraxisprojekt_Hitzewellen_DE
Analyse der Entwicklung von Temperaturextremtagen und Hitzewellen in Deutschland


In diesem Projekt sollen die Entwicklung von Temperaturextremtagen und Hitzewellen in
Deutschland über die vergangenen Jahrzehnte untersucht werden. Da die Definitionen von
Temperaturextremtagen und Hitzewellen in der Literatur variieren, werden für dieses Projekt die
folgenden Definitionen verwendet.
Definitionen

Temperaturextremtag: Ein Tag 𝑡 ist ein (Temperatur-)Extremtag an einem Standort 𝑠,
wenn die Tageshöchsttemperatur die lokale, saisonal schwankende Schwelle
überschreitet:
𝑇max (𝑡, 𝑠) > 𝑞0.90 (𝑑(𝑡), 𝑠)
wobei 𝑑(𝑡) der Kalendertag (Tag im Jahr) von 𝑡 ist



Schwelle: Sie wird aus einem Referenzzeitraum bestimmt. Für jeden Kalendertag d und
Standort s betrachtet man die Höchsttemperaturen an diesem Tag sowie an den 10
vorangehenden und 10 folgenden Tagen in allen Jahren des Referenzzeitraums. Das 0.9-
Quantil dieser Werte ist die Schwelle 𝑞0.90 (𝑑, 𝑠). Die Schwelle ist also sowohl vom
Standort als auch vom Kalendertag abhängig.
Hitzewelle: eine Folge von mindestens 3 aufeinanderfolgenden Extremtagen
Referenzzeitraum: Damit die Quantile stabil geschätzt werden, sollte er mindestens 30
Jahre umfassen, in unserem Fall z.B. 1951-1980. Der Analysezeitraum schließt sich daran
an (z.B. 1981-2025).
Da die Schwelle relativ zur Jahreszeit definiert ist, können auch im Winter „Hitzewellen“ auftreten.
Gemeint sind dann ungewöhnlich warme Phasen für die jeweilige Jahreszeit.
Analysekriterien
Hitzewellen lassen sich unter anderem anhand folgender Kennzahlen analysieren:



Jährliche Häufigkeit: Anzahl der Hitzewellen pro Jahr
Dauer: Anzahl der Tage, die eine Hitzewelle andauert
(Mittlere) Intensität: Mittlere Abweichung der Tageshöchsttemperaturen während einer
Hitzewelle von den jeweiligen durchschnittlichen Tageshöchsttemperaturen im
Referenzzeitraum
Kumulierte Intensität: Summe der Produkte aus mittlerer Intensität mal Dauer über alle
Hitzewellen eines Zeitraums (z.B. eines Jahres)Fragestellungen:
1. Wie hat sich die Anzahl der Temperaturextremtage und Hitzewellen in Deutschland im
Laufe der vergangenen Jahrzehnte entwickelt?
2. Haben sich Hitzewellen hinsichtlich ihrer Dauer, mittleren Intensität und kumulierten
Intensität in den letzten Jahrzehnten verändert?
3. Gibt es saisonale oder regionale Unterschiede hinsichtlich des Auftretens von
Hitzewellen und ihrer zeitlichen Entwicklung?
4. Lässt sich eine Assoziation zwischen der Dauer und der mittleren Intensität einer
Hitzewelle beobachten?
