# Optional: recreate the standardized input from the archived original table.
# Run from the repository root. This changes CSV serialization, not cell contents.
x <- read.table("reference/original_master_data.csv",header=TRUE,sep=";",
  quote="\"",comment.char="",colClasses="character",na.strings=NULL,
  check.names=FALSE,fileEncoding="Windows-1252",stringsAsFactors=FALSE)
write.table(x,"data/raw/master_data.csv",sep=",",row.names=FALSE,
  col.names=TRUE,quote=TRUE,na="NA",fileEncoding="UTF-8")
