create_folder <- function(foldername){
  path=getwd()
  sep=.Platform$file.sep
  folder = paste0(path,sep,foldername)
  
  if(dir.exists(folder)){
    unlink(folder, recursive = TRUE)
    dir.create(folder)
  }else{
    dir.create(folder)
  }
}