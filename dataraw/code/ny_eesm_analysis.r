


library(tidyquant)
library(timetk)
library(sweep)
library(forecast)

ny <- eesm_m %>%
  filter(stabbr=="NY", area=="00000", dtype=="01") %>%
  select(-dtype, -area, -areaf, -stcode, -stname)
glimpse(ny)
ht(ny)

nyemp <- ny %>%
  filter(ind=="00000000") %>%
  select(date, season, value)

nyemp %>%
  ggplot(aes(date, value, colour=season)) +
  geom_line() +
  geom_point()

ny2 <- nyemp %>%
  group_by(season) %>%
  arrange(date) %>%
  mutate(pchya=value / lag(value, 12) * 100 - 100) %>%
  ungroup
ht(ny2)

ny2 %>%
  ggplot(aes(date, pchya, colour=season)) +
  geom_line() +
  geom_point() +
  scale_x_date(breaks = seq(as.Date("1920-01-01"), by="5 years", length.out=20), date_labels = "%Y") +
  scale_y_continuous(breaks=seq(-10, 20, 2))


ny3 <- ny2 %>%
  filter(season=="U") %>%
  select(date, value) %>%
  nest(data = everything())

f <- function(data){
  start_period <- c(year(min(data$date)), month(min(data$date)))
  y <- ts(data$value, start = start_period, freq = 12)
  y
}
g <- function(dts){
  tibble(valsa=as.numeric(dts))
}
ny4 <- ny3 %>%
  mutate(vts=map(data, f),
         stlx=map(vts, stl, s.window="periodic"),
         seas=map(stlx, seasadj))
ny5 <- ny4 %>%
  mutate(valsa=map(seas, g)) %>%
  unnest(c(data, valsa))

ny5 %>%
  select(date, value, valsa) %>%
  pivot_longer(cols=c(value, valsa)) %>%
  ggplot(aes(date, value, colour=name)) +
  geom_line() +
  geom_point()

write_csv(ny5 %>%
            select(date, value, valsa) , "d:/temp/nyemp.csv")




ny3 <- ny2 %>%
  ungroup %>%
  filter(season=="U") %>%
  nest(data = everything()) %>%
  mutate(data.ts = map(.x       = data,
                       .f       = tk_ts,
                       select   = value,
                       start    = c(1939, 1),
                       freq     = 12))

ny4 <- ny3 %>%
  # mutate(fit.ets = map(data.ts, ets)) %>%
  # mutate(decomp = map(fit.ets, sw_tidy_decomp, timetk_idx = TRUE, rename_index = "date")) %>%
  mutate(seas=seasadj(stl(data.ts)))
unnest(decomp)
ny4


ny4 <- ny3 %>%
  mutate(stlx=map(data.ts, stl, s.window="periodic"),
         seas=seasadj(stl(data.ts, s.window = "periodic")))
unnest(decomp)
ny4

