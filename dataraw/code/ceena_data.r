
# current employment statistics national data (cena)

# navigation notes ----
# alt-o, shift-alt-o
# alt-l, shift-alt-l

# alt-r
# ctrl-d

# package-building notes ----

# http://r-pkgs.had.co.nz/

# Install Package: 'Ctrl + Shift + B'
# Check Package: 'Ctrl + Shift + E'
# Test Package: 'Ctrl + Shift + T'



# notes ----
# info:
# https://download.bls.gov/pub/time.series/ce/ce.txt

# location for full files
#  https://download.bls.gov/pub/time.series/compressed/tape.format/
# also see:
#  https://download.bls.gov/pub/time.series/ce/




# libraries ---------------------------------------------------------------
library(devtools)
library(usethis)

library(magrittr)
# library(plyr) # needed for ldply; must be loaded BEFORE dplyr
library(tidyverse)
options(tibble.print_max = 60, tibble.print_min = 60) # if more than 60 rows, print 60 - enough for states
# ggplot2 tibble tidyr readr purrr dplyr stringr forcats
library(readr)
library(vroom)
library(fs)

library(btools)

sessionInfo()
devtools::session_info()
(.packages()) %>% sort
tidyverse_conflicts()

# run things ----
# use_package()
# use_package("ggplot2")
# use_usethis()
# devtools::check()

# globals ----
# url_base <- "https://download.bls.gov/pub/time.series/compressed/tape.format/"
# url_sm <- "http://download.bls.gov/pub/time.series/ce/"
#
# fn_doc <- "tapeformat.doc"
#
# fn_area <- "sm.area"
# fn_dtype <- "sm.data_type"
# fn_ind <- "sm.industry"
# fn_ssector <- "sm.supersector"
# fn_state <- "sm.state"

ddir <- r"(E:\data\BLSData\ces)"

url_base <- "https://download.bls.gov/pub/time.series/ce/"
# fn_ces <- "ce.data.0.AllCESSeries"
fn_eea <- "ce.data.01a.CurrentSeasAE"


# download documentation and data ----
#.. get documentation ONLY UPDATE AS NEEDED ----

doclist <- c("ce.datatype", "ce.footnote", "ce.industry", "ce.period", "ce.seasonal", "ce.series", "ce.supersector", "ce.txt")
urls <- paste0(url_base, doclist)

purrr::map(urls, function(x) download.file(x, destfile=file.path(ddir, path_file(x)), mode="wb"))

# download.file(paste0(url_base, fn_doc), here::here("dataraw", "docs", fn_doc), mode="wb")
#
# download.file(paste0(url_sm, fn_area), here::here("dataraw", "docs", fn_area), mode="wb")
# download.file(paste0(url_sm, fn_dtype), here::here("dataraw", "docs", fn_dtype), mode="wb")
# download.file(paste0(url_sm, fn_ind), here::here("dataraw", "docs", fn_ind), mode="wb")
# download.file(paste0(url_sm, fn_ssector), here::here("dataraw", "docs", fn_ssector), mode="wb")
# download.file(paste0(url_sm, fn_state), here::here("dataraw", "docs", fn_state), mode="wb")

#.. get full data file ----
download.file(paste0(url_base, fn_ces), file.path(ddir, fn_ces), mode="wb")
download.file(paste0(url_base, fn_eea), file.path(ddir, fn_eea), mode="wb")
download.file(paste0(url_base, fn_eea), here::here("dataraw", "data", fn_eea), mode="wb")


# read documenation ----
series <- read_tsv("https://download.bls.gov/pub/time.series/ce/ce.series")
ssector <- read_tsv("https://download.bls.gov/pub/time.series/ce/ce.supersector")
industry <- read_tsv("https://download.bls.gov/pub/time.series/ce/ce.industry")


# read data ----
# file is tab delimited
fn_eea # this is employment, all workers, individual industries
# must read full file if we read from zip, before n_max is applied
df <- read_delim(# here::here("dataraw", "data", fn_eea),
                 file.path(ddir, fn_eea),
                 delim="\t", trim_ws=TRUE,
                 skip=0, n_max=Inf)
count(df, footnote_codes)

eea1 <- df %>%
  left_join(series %>%
               select(series_id, supersector_code, industry_code, data_type_code, seasonal, series_title),
             by = "series_id")
glimpse(eea1)
summary(eea1)
count(eea1, supersector_code) # 22 we need descriptions
count(eea1, industry_code) # 881, we need descriptions
count(eea1, data_type_code) # all 01, we can drop
count(eea1, seasonal) # all S, we can drop
count(eea1, series_title) # 874

eea2 <- eea1 %>%
  left_join(ssector, by="supersector_code") %>%
  left_join(industry, by="industry_code")
glimpse(eea2)
summary(eea2)

# d <- "1939M0101"
# as.Date(d, format="%YM%m%d")

eea3 <- eea2 %>%
  mutate(date=as.Date(paste0(year, period, "01"), format="%YM%m%d")) %>%
  select(date, value,
         series=series_id, seriesf=series_title,
         ssector=supersector_code, ssectorf=supersector_name,
         ind=industry_code, indf=industry_name, naics=naics_code,
         level=display_level, sort=sort_sequence)
glimpse(eea3)
summary(eea3)
count(eea3, sort, level, ssector, ssectorf, ind, indf)
count(eea3 %>% filter(level==4), sort, level, ssector, ssectorf, ind, indf, series, seriesf)
count(eea3 %>% filter(level==1), sort, level, ssector, ssectorf, ind, indf, series, seriesf)
count(eea3 %>% filter(level==2), sort, level, ssector, ssectorf, ind, indf, series, seriesf)

count(eea3 %>% filter(ssector==90, level==4), sort, level, ssector, ssectorf, ind, indf, series, seriesf)

gind <- "90922000" # sgxed
gind <- "90931611" # lged
gind <- "20000000"
eea3 %>%
  filter(ind==gind) %>%
  ggplot(aes(date, value)) +
  geom_line()

# create and save the file ----
eeasa <- eea3
use_data(eeasa, overwrite = TRUE)

# junk below here ----
memory()




