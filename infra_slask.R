
# libraries
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, sf, sp, httr, mapview, leaflet, readxl, keyring)

# För att komma förbi proxyn
set_config(use_proxy(url = "http://mwg.ltdalarna.se", port = 9090,
                     username = key_list(service = "auth")$username, password = key_get("auth", key_list(service = "auth")$username)))
set_config(config(ssl_verifypeer = 0L))

# avoid scientific notation
options(scipen=999)

###Hämta filen från:
#G:\Samhällsanalys\GIS\grundkartor\nvdb\Dalarnas_län_GeoPackage
nvdb_fil <- "G:/Samhällsanalys/GIS/grundkartor/nvdb/fixat_nvdb_riket.gpkg"

#Vilka lager finns i geopkg
nvdb_layers <- st_read(nvdb_fil, crs = 3006)

glimpse(nvdb_layers)

nvdb <- nvdb_layers %>% 
  select(Vaghallare_Vaghallartyp, 
         Vagtrafiknat_Vagtrafiknattyp, 
         Trafik_ADT_fordon, Gatunamn_Namn, 
         Barighet_Barighetsklass, 
         Hastighetsgrans_HogstaTillatnaHastighet_B,
         Vagnummer_Lanstillhorighet,
         Vagnummer_Huvudnummer_Vard)

nvdb_statlig <- nvdb %>% 
  filter(Vaghallare_Vaghallartyp == "statlig",
         Vagtrafiknat_Vagtrafiknattyp == "bilnät")

mapview(nvdb_statlig)

##https://mgimond.github.io/Spatial/reading-and-writing-spatial-data-in-r.html
#st_write(s.sf, "s.gpkg", driver = "GPKG")  # Create a geopackage file

st_write(nvdb_statlig, "nvdb_stat.gpkg", driver = "GPKG")  # Create a geopackage file

#hämta filer från QGIS nätverksanalys # G:\skript\henrik\GitHub\Region-Atlas\infrastruktur\utdata_qgis

tatorter_meran35000_fil <- "G:/skript/henrik/GitHub/Region-Atlas/infrastruktur/utdata_qgis/tatort_meran35000.gpkg"

tatorter <- st_read(tatorter_meran35000_fil, crs = 3006)

natverk_fil <- "G:/skript/henrik/GitHub/Region-Atlas/infrastruktur/utdata_qgis/network_gbg_malmo_sthlm.gpkg"

natverk <- st_read(natverk_fil, crs = 3006)

malmo <- natverk %>% 
  filter(tatort == "Malmö") %>% 
  mutate(avstand = (paste("inom 22 mil från", tatort)))

sthlm <- natverk %>% 
  filter(tatort == "Stockholm")%>% 
  mutate(avstand = (paste("inom 22 mil från", tatort)))

gtbg <- natverk %>% 
  filter(tatort == "Göteborg")%>% 
  mutate(avstand = (paste("inom 22 mil från", tatort)))

mapview(malmo, color = "red", alpha = 0.3, lwd = 1, label = "avstand")+
  mapview(sthlm, color = "green", alpha = 0.3, lwd = 1, label = "avstand", hide = TRUE)+
  mapview(gtbg, color = "blue", alpha = 0.3, lwd = 1, label = "avstand", hide = TRUE)+
  mapview(tatorter, color = "black", col.region = "grey", alpha.regions = 0.3, cex = "bef", label = "tatort", homebutton = FALSE, legend = FALSE)



