# Goal: export the data needed for each model I'll fit

## packages -------------------------------------

packages <- c('data.table', 'ggplot2', 'lubridate')

miss_pkgs <- packages[!packages %in% installed.packages()[,1]]

if(length(miss_pkgs) > 0){
  install.packages(miss_pkgs)
}

invisible(lapply(packages, library, character.only = TRUE))

rm(miss_pkgs, packages)

## data -----------------------------------------

ridership <- readRDS('data/aggregations/apc_daily_bg.RDS')
setDT(ridership)
ridership[, year := year(ymd(date_key))]
ridership[, wday := wday(ymd(date_key), label = TRUE)]
# get 2017
ridership <- ridership[year == 2017]
# and set to match w covariates
ridership[, year := as.character(3)]
# remove weekends
ridership <- ridership[wday != "Sat" & wday != "Sun"]
# avg weekday
ridership <- ridership[, .(daily_boards = mean(daily_boards, na.rm = T),
                           daily_stops = mean(daily_stops, na.rm = T)), keyby = .(GEOID)]


## SCALED ##

## IMPORTANT: to reproduce honors project, use all covariates from 2017!! ##
cov <- readRDS('data/covariates/cleaned/all_covariates_scaled_ind.RDS')
setDT(cov)

# need year == '3' for lehd and year == '4' for acs
late <- c("workers", "emp_density", "w_total_jobs_here", "w_perc_jobs_white", "w_perc_jobs_men",
          "w_perc_jobs_no_college", "w_perc_jobs_less40", "w_perc_jobs_age_less30", "GEOID")
late2 <- c("workers", "emp_density", "w_total_jobs_here", "w_perc_jobs_white", "w_perc_jobs_men",
          "w_perc_jobs_no_college", "w_perc_jobs_less40", "w_perc_jobs_age_less30")

emp <- cov[year == "3", ..late]
notemp <- cov[year == "4", !..late2]

cov <- emp[notemp, on = .(GEOID)]

mod_dat <- ridership[cov, on = .(GEOID)]

saveRDS(mod_dat, 'data/modeling-dat/mod_dat.RDS')

## UNSCALED ##
cov <- readRDS('data/covariates/cleaned/all_covariates_ind.RDS')
setDT(cov)

# need year == '3' for lehd and year == '4' for acs
late <- c("workers", "emp_density", "w_total_jobs_here", "w_perc_jobs_white", "w_perc_jobs_men",
          "w_perc_jobs_no_college", "w_perc_jobs_less40", "w_perc_jobs_age_less30", "GEOID")
late2 <- c("workers", "emp_density", "w_total_jobs_here", "w_perc_jobs_white", "w_perc_jobs_men",
           "w_perc_jobs_no_college", "w_perc_jobs_less40", "w_perc_jobs_age_less30")

emp <- cov[year == "3", ..late]
notemp <- cov[year == "4", !..late2]

cov <- emp[notemp, on = .(GEOID)]

mod_dat <- ridership[cov, on = .(GEOID)]

saveRDS(mod_dat, 'data/modeling-dat/mod_dat_unscaled.RDS')
