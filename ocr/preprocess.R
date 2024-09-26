preprocess <- function(filename){
  image <- magick::image_read(filename)
  
  height <- magick::image_info(image)$height
  
    image <- magick::image_quantize(image) %>%
      magick::image_negate() %>%
      magick::image_modulate(brightness = 190,saturation = 0) %>%
      # magick::image_threshold(type = "black", threshold = "10%") %>%
      # magick::image_threshold(type = "white", threshold = "90%") %>%
      magick::image_background("white") %>%
      # magick::image_enhance() %>%
      # magick::image_median() %>%
      # magick::image_contrast() %>%
      # magick::image_convert(type = "grayscale") %>%
      magick::image_reducenoise() %>%
      magick::image_scale(paste0("x",round(1.3*height)))
  
  attr(image, "filename") <- filename
  
  return(image)
}