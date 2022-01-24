
# state-metro area data

# navigation notes ----
# alt-o, shift-alt-o
# alt-l, shift-alt-l

# alt-r

# package-building notes ----

# http://r-pkgs.had.co.nz/

# Install Package: 'Ctrl + Shift + B'
# Check Package: 'Ctrl + Shift + E'
# Test Package: 'Ctrl + Shift + T'



# notes ----
# info:
# https://download.bls.gov/pub/time.series/sm/sm.txt

# location for full files
#  https://download.bls.gov/pub/time.series/compressed/tape.format/
# also see:
#  https://download.bls.gov/pub/time.series/sm/




# libraries ---------------------------------------------------------------
library(devtools)
library(usethis)

library(magrittr)
library(plyr) # needed for ldply; must be loaded BEFORE dplyr
library(tidyverse)
options(tibble.print_max = 60, tibble.print_min = 60) # if more than 60 rows, print 60 - enough for states
# ggplot2 tibble tidyr readr purrr dplyr stringr forcats
library(readr)
library(vroom)
library(fs)
library(archive)

library(btools)

sessionInfo()
devtools::session_info()
(.packages()) %>% sort

# run things ----
# use_package()
# use_package("ggplot2")
# use_usethis()
# devtools::check()

# globals ----
dir_eesm <- r"(E:\data\BLSData\eesm)"

url_base <- "https://download.bls.gov/pub/time.series/compressed/tape.format/"
url_sm <- "http://download.bls.gov/pub/time.series/sm/"


# fn_area <- "sm.area"
# fn_dtype <- "sm.data_type"
# fn_ind <- "sm.industry"
# fn_ssector <- "sm.supersector"
# fn_state <- "sm.state"


# download documents ------------------------------------------------------
doclist <- c("sm.area", "sm.data_type", "sm.footnote", "sm.industry", "sm.period", "sm.seasonal", "sm.series", "sm.state", "sm.supersector", "sm.txt")
urls <- paste0(url_sm, doclist)

purrr::map(urls, function(x) download.file(x, destfile=file.path(dir_eesm, path_file(x)), mode="wb"))

fn_doc <- "tapeformat.doc"
download.file(paste0(url_base, fn_doc), destfile=file.path(dir_eesm, fn_doc), mode="wb")


# download data -----------------------------------------------------------
# fn_data <- "bls.eesm.date202002.gz" # starts 1990
# fn_data <- "bls.eesm.date202108.gz" # starts 1990
fn_data <- "bls.eesm.date202111.gz" # starts 1990
download.file(paste0(url_base, fn_data), file.path(dir_eesm, fn_data), mode="wb")

# fname <- paste0("bls.eesm.date", dyear, formatC(dmonth, width=2, flag="0")) # format ensures leading zero for months 1-9
# zfname <- paste0(fname, ".Z")

# read documenation ----
area <- read_tsv(file.path(dir_eesm, str_subset(doclist, "area")))
ind <- read_tsv(file.path(dir_eesm, str_subset(doclist, "industry")))
dtype <- read_tsv(file.path(dir_eesm, str_subset(doclist, "data_type")))
ssector <- read_tsv(file.path(dir_eesm, str_subset(doclist, "super")))
state <- read_tsv(file.path(dir_eesm, str_subset(doclist, "state")))

# data type
# data_type_code	data_type_text
# 01	All Employees, In Thousands
# 02	Average Weekly Hours of All Employees
# 03	Average Hourly Earnings of All Employees, In Dollars
# 06	Production or Nonsupervisory Employees, In Thousands
# 07	Average Weekly Hours of Production Employees
# 08	Average Hourly Earnings of Production Employees, In Dollars
# 11	Average Weekly Earnings of All Employees, In Dollars
# 26	All Employees, 3-month average change, In Thousands, seasonally adjusted
# 30	Average Weekly Earnings of Production Employees, In Dollars
# also, diffusion indexes

# read data ----
# file is space delimited
(cnames <- c("code", "year", "annavg", paste0("m", 1:12))) # note that when annavg is 01 it is NA

# if needed, unzip and read the file
# df <- read_delim(here::here("dataraw", "data", "bls.eesm.date202002"),
#                  delim=" ", trim_ws=TRUE,
#                  col_names=cnames,
#                  skip=0, n_max=10)
# glimpse(df)
# df[1:10, 1:5]

# must read full file if we read from zip, before n_max is applied
# df <- read_table(file.path(dir_eesm, fn_data),
#                  col_names=cnames,
#                  col_types="cicnnnnnnnnnnnn", # for safety
#                  skip=1,
#                  n_max=Inf)

# use archive_read
# we don't need the time series identification rows that begin with TS, so we'll drop them
# (skip=1)
df <- read_table(archive_read(file.path(dir_eesm, fn_data),
                              path_ext_remove(fn_data),
                              format="raw",
                              filter="gzip"),
                 col_names=cnames,
                 col_types="cicnnnnnnnnnnnn", # for safety
                 skip=1,
                 n_max=Inf)


# haven't figured out how to get read_table equiv using vroom
# df <- vroom(archive_read(file.path(dir_eesm, fn_data),
#                          path_ext_remove(fn_data),
#                          format="raw",
#                          filter="gzip"),
#             trim_ws = TRUE,
#             delim=" ",
#             col_names=cnames,
#             col_types="cicnnnnnnnnnnnn", # for safety
#             skip=1,
#             n_max=10)
df
problems(df)
glimpse(df)
df[1:10, 1:5]
ht(df)

df2 <- df %>%
  filter(str_sub(code, 1, 1)!="T") %>%
  mutate(across(.cols=-c(code, year),
                ~ ifelse(.=="01", NA_character_, .)))
  # mutate_at(vars(-code, -year), ~ ifelse(.=="01", NA_character_, .))
glimpse(df2)
ht(df2)

df3 <- df2 %>%
  # filter(row_number() < 5) %>%
  # mutate(code="MSMU01266207072200001") %>%
  # select(code) %>%
  mutate(season=str_sub(code, 4, 4),
         stcode=str_sub(code, 5, 6),
         area=str_sub(code, 7, 11),
         ssector=str_sub(code, 12, 13),
         ind=str_sub(code, 12, 19),
         dtype=str_sub(code, 20, 21))
ht(df3)

# The series_id (MSMU01266207072200001) can be broken out into:
# monthly data = M
# survey abbreviation	=		SM
# seasonal (code) 	=		U
# state_code		=		01
# area_code		=		26620
# supersector_code	=		70
# industry_code		=		70722000
# data_type_code		=		01

df4 <- df3 %>%
  left_join(area %>% select(area=area_code, areaf=area_name), by = "area") %>%
  left_join(ssector %>% select(ssector=supersector_code , ssectorf=supersector_name ), by = "ssector") %>%
  left_join(ind %>% select(ind=industry_code , indf=industry_name), by = "ind") %>%
  left_join(dtype %>% select(dtype=data_type_code, dtypef=data_type_text), by = "dtype") %>%
  left_join(state %>% select(stcode=state_code, stname=state_name), by = "stcode") %>%
  mutate(stabbr=state.abb[match(stname, state.name)]) %>%
  mutate(stabbr=case_when(stcode==11 ~ "DC",
                          stcode==72 ~ "PR",
                          stcode==78 ~ "VI",
                          TRUE ~ stabbr))

glimpse(df4)

#
# count(df4, stcode, stname) %>%
#   mutate(stabbr=state.abb[match(stname, state.name)]) %>%
#   mutate(stabbr=case_when(stcode==11 ~ "DC",
#                           stcode==72 ~ "PR",
#                           stcode==78 ~ "VI",
#                           TRUE ~ stabbr))

count(df4, area, areaf) %>% ht
count(df4, dtype, dtypef)
count(df4, ssector, ssectorf)
count(df4, ind, indf) %>% ht
count(df4, stcode, stabbr, stname)

df5 <- df4 %>%
  select(-code) %>%
  pivot_longer(m1:m12) %>%
  filter(!is.na(value)) %>%
  mutate_at(vars(annavg, value), ~ as.numeric(.))
ht(df5)

# create and save annual file ----
eesm_a <- df5 %>%
  filter(name=="m12") %>% # we want the annual average as of December (I think)
  select(-value) %>%
  select(-annavg, everything(), annavg) %>%
  filter(!is.na(annavg)) %>%
  select(-name) %>%
  select(year, season, dtype, dtypef, ssector, ssectorf, ind, indf,
         stabbr, stcode, stname, area, areaf, value=annavg) # not renaming of annavg to value
glimpse(eesm_a)
summary(eesm_a)

use_data(eesm_a, overwrite = TRUE)

# create and save monthly file ----
eesm_m <-  df5 %>%
  select(-annavg) %>%
  filter(!is.na(value)) %>%
  mutate(date=paste0(year, "-", str_sub(name, 2, -1), "-01") %>% as.Date()) %>%
  select(date, season, dtype, dtypef, ssector, ssectorf, ind, indf,
         stabbr, stcode, stname, area, areaf, value)
glimpse(eesm_m)
ht(eesm_m)
summary(eesm_m)

system.time(use_data(eesm_m, overwrite = TRUE)) # this takes a LONG time ~ 4 mins new pc

# junk below here ----
memory()




