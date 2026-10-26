# Skript, um alle benötigten packages zu laden
# Idee von https://statsandr.com/blog/an-efficient-way-to-install-and-load-r-packages/

install.packages("pacman")

# checkt ob die aufgeführten packages installiert sind
# installiert diese falls nicht und lädt danach alle
pacman::p_load(here, ggplot2, dplyr, lubridate, readr, colorspace)

