hhs_regions <- read.table(text="region;region_number;regional_office;state_or_territory
Region 1;1;Boston;Connecticut, Maine, Massachusetts, New Hampshire, Rhode Island, Vermont
Region 2;2;New York;New Jersey, New York, Puerto Rico, Virgin Islands
Region 3;3;Philadelphia;Delaware, District of Columbia, Maryland, Pennsylvania, Virginia, West Virginia
Region 4;4;Atlanta;Alabama, Florida, Georgia, Kentucky, Mississippi, North Carolina, South Carolina, Tennessee
Region 5;5;Chicago;Illinois, Indiana, Michigan, Minnesota, Ohio, Wisconsin
Region 6;6;Dallas;Arkansas, Louisiana, New Mexico, Oklahoma, Texas
Region 7;7;Kansas City;Iowa, Kansas, Missouri, Nebraska
Region 8;8;Denver;Colorado, Montana, North Dakota, South Dakota, Utah, Wyoming
Region 9;9;San Francisco;Arizona, California, Hawaii, Nevada, American Samoa, Commonwealth of the Northern Mariana Islands, Federated States of Micronesia, Guam, Marshall Islands, Republic of Palau
Region 10;10;Seattle;Alaska, Idaho, Oregon, Washington", sep=";", stringsAsFactors=FALSE, header=TRUE)

library(stringr)
do.call(rbind.data.frame, lapply(1:nrow(hhs_regions), function(i) {
  x <- hhs_regions[i,]
  rownames(x) <- NULL
  out <- data.frame(x[, c(1:3)],
             str_split(x$state_or_territory, ", ")[1],
             stringsAsFactors=FALSE)
  colnames(out) <- c("region", "region_number", "regional_office", "state_or_territory")
  out
})) -> hhs_regions

str(hhs_regions)

library(rvest)
library(magrittr)

  pg <- html("https://www.cdc.gov/std/stats18/census.htm")
pg %>% html_table() %>% extract2(1) %>% as.list -> cens
do.call(rbind.data.frame, lapply(names(cens), function(x) {
  data.frame(region=x,
             state=cens[[x]][cens[[x]]!=""],
             stringsAsFactors=FALSE)
})) -> census_regions

devtools::use_data(hhs_regions, census_regions, overwrite=TRUE)
