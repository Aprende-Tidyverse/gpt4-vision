library(httr2)
library(readr)

openai_api_key <- Sys.getenv("OPENAI_API_KEY")

# Función para codificar la imagen en Base64
encode_image <- function(image_path) {
  readBin(image_path, "raw", file.info(image_path)$size) %>% 
    base64enc::base64encode()
}

gpt_4_vision <- function(.imgs, .prompt){
  # Codificar la imagen 'input.jpeg' en Base64
  base64_image <- encode_image(.imgs)
  
  # Configurar la solicitud POST con la imagen codificada
  response <- request("https://api.openai.com/v1/chat/completions") |> 
    req_headers(
      `Content-Type` = "application/json",
      `Authorization` = paste("Bearer", openai_api_key)
    ) |> 
    req_body_json(
      list(
        model = "gpt-4-vision-preview",
        messages = list(
          list(role = "system",
               content = "
               Eres un extractor de información, dada una imagen
               retornas un json son la informacion solicitada, no
               comentarios ni informacion adicional solo datos en
               formato json como texto plano no como un bloque de
               codigo.
               
               "),
          list(
            role = "user",
            content = list(
              list(
                type = "text",
                text = .prompt
              ),
              list(
                type = "image_url",
                image_url = list(
                  url = paste0("data:image/jpeg;base64,", base64_image)
                )
              )
            )
          )
        ),
        max_tokens = 1500
      )
    ) |> 
    req_perform() |> resp_body_json()
  
  contenido <- response$choices[[1]]$message$content
  
  # Imprimir la respuesta
  return(contenido)
}
