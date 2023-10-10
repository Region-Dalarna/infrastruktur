library(leaflet)
library(htmlwidgets)
library(sf)
library(tidyverse)

# Replace 'your_file.gpkg' with the path to your GeoPackage file
nvdb_fil <- "G:/Samhällsanalys/GIS/grundkartor/nvdb/Dalarnas_län_GeoPackage/Dalarnas_län.gpkg"

# List available layers in the GeoPackage
nvdb_layers <- st_layers(nvdb_fil) # tar för lång tid

# Read the desired layers into R
# Replace 'layer1' and 'layer2' with the names of the layers you want to import
vaghallare <- st_read(nvdb_fil, layer = "AGGREGAT_O_5_KommunLanReg", crs = 3006)
gatu_namn <- st_read(nvdb_fil, layer = "AGGREGAT_O_67_Vagslag", crs = 3006)
kategori <- st_read(nvdb_fil, layer = "AGGREGAT_O_68_Vagkategori", crs = 3006)
#layer4 <- st_read(nvdb_fil, layer = "AGGREGAT_O_70_Servicenivaer_TL")        #service nivå?
#layer5 <- st_read(nvdb_fil, layer = "AGGREGAT_O_71_Stamvag")                 # ingen info
underhallstyp <- st_read(nvdb_fil, layer = "AGGREGAT_O_74_Underhallstyp_vag", crs = 3006)

# Perform individual joins

nvdb_join <- gatu_namn %>% 
  st_join(vaghallare, join = st_overlaps)

nvdb_join <- nvdb_join %>% 
  st_join(kategori, join = st_overlaps)

nvdb_join <- nvdb_join %>% 
  st_join(underhallstyp, join = st_overlaps)

summary(nvdb_join)

nvdb <- nvdb_join %>% 
  select(ELEMENT_ID.x, Avfartsvag_pafartsvag, Bro_och_tunnel, Bussgata, Cirkulationsplats, Gagata, 
         Gangfartsomrade, Gastvag1_europavag, Gastvag1huvudnummer, Gastvag1undernummer, Gastvag2_europavag,
         Gastvag2huvudnummer, Gastvag2undernummer, Gatunamn, Genomgaende_vagnummervag, Industrivag, Typ, 
         Uppsamlande, Vardvag_europavag, Vardvaghuvudnummer, Vardvagundernummer, Kommunkod, Kommunnamn, 
         Lansbeteckning, Lanskod, Lansnamn, Regionkod, Regionnamn, Vaghallare_vaghallartyp, Vagtrafiknat_nattyp,
         Kategori, Underhallstyp
         ) %>%
  rename_all(tolower)

st_geometry_type(nvdb)

nvdb <- nvdb[!sf::st_is_empty(nvdb), ]
nvdb <- nvdb[sf::st_is_valid(nvdb), ]

mapview::mapview(nvdb)

#Testar med json
st_write(nvdb, "nvdb_data.geojson", driver = "GeoJSON")

library(leaflet)

nvdb_geojson <- readRDS("nvdb_data.geojson")

leaflet(nvdb_geojson) %>%
  addTiles() %>%
  addMarkers()  # You can customize this part based on your data



# Combine the results using bind_rows
final_combined_data <- bind_rows(joined_vaghallare)

mapview::mapview(vaghallare)
