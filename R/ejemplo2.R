library(tidyverse)
library(jsonlite)
library(progress)
source(file = "R/api_vision.R")

imagenes <- list.files(
  path = "data/alquileres/",
  pattern = ".png",
  full.names = TRUE
)

.prompt <- '
 extrae en informacion de anuncios de alquier en el siguiente
 formato:
output:

[
   {
      "tipo":"Apartamento|casa",
      "telefono":"8888-8888",
      "precio":"1000000",
      "moneda":"colones|dolares",
      "habitaciones":"2",
      "baños":"1",
      "parqueo":"si|no",
      "mascotas":"si|no",
      "servicios incluidos":"si|no",
      "ubicacion":"direccion de domicilio"
   }
]

No anotaciones ni observaciones solo codigo json como texto plano
no un bloque de codigo, si no se encuentra un valor se debe indicar 
NA
'

pb <- progress_bar$new(
  format = "  Descargando [:bar] :percent :current/:total",
  total = length(imagenes), clear = FALSE, width= 60)

df <- map(imagenes, function(imagen){
  pb$tick()
  x <- gpt_4_vision(
    .imgs = imagen,
    .prompt = .prompt
  )
  x <- fromJSON(x)
  return(x)
}) |> 
  list_rbind()

df
