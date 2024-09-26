# only need to be run once, uncomment it manually
# tesseract_download("chi_sim")
# tesseract_info()
#########################################
library(tesseract)
library(magick)
library(tidyverse)
source("preprocess.R")
source("myTryCatch.R")
source("create_folder.R")
path=getwd()
sep=.Platform$file.sep
blacklist=paste(c("0123456789",
            "abcdefghijklmnopqrstuvwxyz",
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            "!@#$%^&*()",
            "！@#¥%……&*（）",
            "-=[];',./`\"",
            "_+{}|:<>?~",
            "-=【】、；‘’，。/·",
            "——+「」｜：“”《》？～"), collapse="")
chi <- tesseract(language = "chi_sim",
                 options = list(edges_max_children_per_outline = "40",
                 tessedit_char_blacklist=blacklist))
high_conf_threshold <- 50
low_conf_threshold <- 10

#########################################

# path for the original image files
filenames <- list.files(path = paste0(path,sep,"original_imgs"))

# initialize folders and result file
create_folder("pre-process_imgs")
create_folder("imgs_recheck")
create_folder("imgs_withtext")
write.table(cbind("filename","text"),
            file = paste0(path,sep,"text.txt"),
            row.names = FALSE, col.names = FALSE)

# pre-processing images
for(i in 1:length(filenames)){
  img <- myTryCatch( preprocess(paste0(path,sep,"original_imgs",sep,filenames[i])) )
  if(!is.null(img$error)){
    # if error, do not process the image and record it
    file.copy(paste0(path,sep,"original_imgs",sep,filenames[i]),
              paste0(path,sep,"imgs_recheck",sep,filenames[i]))
  }else{
    wrt <- myTryCatch( image_write(img$value, path = paste0(path,sep,"pre-process_imgs",sep,filenames[i]), format = "png") )
    if(!is.null(wrt$error)){
      file.copy(paste0(path,sep,"original_imgs",sep,filenames[i]), 
                paste0(path,sep,"imgs_recheck",sep,filenames[i]))
    }
  }
}


# OCR
for(i in 1:length(filenames)){
  ocr <- myTryCatch( tesseract::ocr_data(paste0(path,sep,"pre-process_imgs",sep,filenames[i]), engine = chi) )
  # if no errors or warnings
  if(is.null(ocr$warning) & is.null(ocr$error)){
    # if there are identified characters
    if(!is_empty(ocr$value$word)){
      # if there are high-quality results
      if(any(ocr$value$confidence >= high_conf_threshold)){
          # save images to the new folder
          file.copy(paste0(path,sep,"original_imgs",sep,filenames[i]), 
                    paste0(path,sep,"imgs_withtext",sep,filenames[i]))
          # extracting text
          pos <- which(ocr$value$confidence >= low_conf_threshold)
          t <- cbind(ocr$value$word[min(pos):max(pos)])
          # labeling low-quality characters with "< >"
          t[ocr$value$confidence[min(pos):max(pos)] < high_conf_threshold] <- paste0("<",t[ocr$value$confidence[min(pos):max(pos)] < high_conf_threshold],">")
          t <- paste(t,collapse = "")
          write.table(cbind(paste0(filenames[i],"  "),t),
                      file = paste0(path,sep,"text.txt"),
                      row.names = FALSE, col.names = FALSE, quote = FALSE, append = TRUE)
      }else{file.copy(paste0(path,sep,"original_imgs",sep,filenames[i]), 
                  paste0(path,sep,"imgs_recheck",sep,filenames[i]))}
    }else{file.copy(paste0(path,sep,"original_imgs",sep,filenames[i]), 
                paste0(path,sep,"imgs_recheck",sep,filenames[i]))}
  }else{file.copy(paste0(path,sep,"original_imgs",sep,filenames[i]), 
              paste0(path,sep,"imgs_recheck",sep,filenames[i]))}
}







