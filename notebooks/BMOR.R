# Load in libraries for data cleaning.
library(tidyverse)
library(naniar)
library(ggplot2)
library(MARSS)
library(brms)
library(shinystan)

# Read in CIRI data and select columns of interest.
ciri = read_csv("../data/CIRI_DATA_2016.csv")
names(ciri) = tolower(names(ciri))
ciri = select(ciri,countryname,year,disap,kill,tort,polpris,assn,formov,
              dommov,speech,elecsd,new_relfre,worker,wecon,wopol,injud) %>% 
  arrange(countryname, year)
# Replace -66, -999 and -77 with NA.
ciri = replace_with_na_all(ciri, condition = ~.x<0)

# Create lagged variables.
ciri = ciri %>% group_by(countryname) %>% mutate(disap_lag = c(NA,diff(disap)),
                                   kill_lag = c(NA,diff(kill)),
                                   tort_lag = c(NA,diff(tort)),
                                   polpris_lag = c(NA,diff(polpris)),
                                   assn_lag = c(NA,diff(assn)),
                                   formov_lag = c(NA,diff(formov)),
                                   dommov_lag = c(NA,diff(dommov)),
                                   speech_lag = c(NA,diff(speech)),
                                   elecsd_lag = c(NA,diff(elecsd)),
                                   new_relfre_lag = c(NA,diff(new_relfre)),
                                   worker_lag = c(NA,diff(worker)),
                                   wecon_lag = c(NA,diff(wecon)),
                                   wopol_lag = c(NA,diff(wopol)),
                                   injud_lag = c(NA,diff(injud)))
# Limit the years
ciri$response = factor(ciri$speech_lag, ordered = T)
sub = ciri %>% filter(year<2010)
newdat = ciri %>% filter(year==2010)

# Model with country as the random effect.
mod = brm(response ~ polpris_lag + kill_lag + tort_lag + assn_lag + formov_lag + dommov_lag + 
            elecsd_lag + new_relfre_lag + worker_lag + wecon_lag + wopol_lag + injud_lag +
            (1|p|countryname), family = cumulative, data = sub, cores = 4, prior = prior(horseshoe()))

# Levels: -2 < -1 < 0 < 1 < 2
fit = fitted(mod, newdata = newdat, allow_new_levels = T)


