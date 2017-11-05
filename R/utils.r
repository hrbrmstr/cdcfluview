.mcga <- function(tbl) {

  x <- colnames(tbl)
  x <- tolower(x)
  x <- gsub("[[:punct:][:space:]]+", "_", x)
  x <- gsub("_+", "_", x)
  x <- gsub("(^_|_$)", "", x)
  x <- gsub("^x_", "", x)
  x <- make.unique(x, sep = "_")

  colnames(tbl) <- x

  tbl

}

to_num <- function(x) {
  x <- gsub("%", "", x, fixed=TRUE)
  x <- gsub(">", "", x, fixed=TRUE)
  x <- gsub("<", "", x, fixed=TRUE)
  x <- gsub(",", "", x, fixed=TRUE)
  x <- gsub(" ", "", x, fixed=TRUE)
  as.numeric(x)
}
