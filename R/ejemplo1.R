library(tidyverse)
library(jsonlite)
library(progress)
source(file = "R/api_vision.R")

imagenes <- list.files(
  path = "data/fotos_recibos/",
  pattern = ".jpg",
  full.names = TRUE
)

.prompt <- '
 extrae en formato json informacion en el siguiente
 formato:
output:

[
   {
      "fecha transaccion":"%y/%m/%d %H:%M",
      "descripcion":"descripcion",
      "monto":"10000",
      "n.comprobante":"numero comprobante"
   }
]
No anotaciones ni observaciones solo codigo json como texto plano
no un bloque de codigo
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