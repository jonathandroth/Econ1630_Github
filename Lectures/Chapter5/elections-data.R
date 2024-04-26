library(readr)
library(haven)
library(readxl)
library(stringr)
library(dplyr)
library(ggplot2)
library(fixest)
source("~/Dropbox/Econ1630_Animations/Code/fte_theme.R")

voter_data <- read_tsv("~/Dropbox/Econ1630_Spring2022/Lectures/Chapter5/countypres_2000-2020.tab")
income_data <- readxl::read_xlsx("~/Dropbox/Econ1630_Spring2022/Lectures/Chapter5/household_inc.xlsx",
                                 skip = 4)


income_data <- income_data %>%
                  rename(medianIncome = Median_Household_Income_2019) %>%
                  select(FIPS_Code, State, medianIncome) %>%
                  mutate(FIPS_Code= as.numeric(FIPS_Code))
                  #mutate(FIPS_Code = str_sub(FIPS_Code, start = -4))


voter_data <-
left_join(voter_data %>% mutate(county_fips = as.numeric(county_fips)), income_data,
          by = c("state_po" = "State", "county_fips" = "FIPS_Code"))


voter_data_clinton <-
  voter_data %>%
  dplyr::filter(year == 2016) %>%
  dplyr::filter(grepl(x=candidate, pattern = "CLINTON")) %>%
  dplyr::mutate(DemVoteShareClinton = candidatevotes/totalvotes)

voter_data_obama <-
  voter_data %>%
  dplyr::filter(year == 2012) %>%
  dplyr::filter(grepl(x=candidate, pattern = "OBAMA")) %>%
  dplyr::mutate(DemVoteShareObama = candidatevotes/totalvotes)



voter_data <-
voter_data %>%
  dplyr::filter(year == 2020) %>%
  dplyr::filter(grepl(x=candidate, pattern = "BIDEN")) %>%
  dplyr::mutate(DemVoteShare = candidatevotes/totalvotes)


voter_data <-
voter_data %>% left_join(voter_data_clinton %>% select(state, county_fips, DemVoteShareClinton),
                         by = c("state", "county_fips"))

voter_data <-
  voter_data %>% left_join(voter_data_obama %>% select(state, county_fips, DemVoteShareObama),
                           by = c("state", "county_fips"))



feols(DemVoteShare ~ DemVoteShareObama + DemVoteShareClinton, voter_data %>%
        filter(state_po == "TX"), se = "hetero")


obama_on_clinton  <-
feols(DemVoteShareObama ~ DemVoteShareClinton, voter_data %>%
        filter(state_po == "TX"), se = "hetero")

voter_data_tx <- voter_data[which(voter_data$state_po == "TX"),]
voter_data_tx$predicted_obama <- predict(obama_on_clinton)

voter_data_tx <-
voter_data_tx %>%
  mutate(residual_obama = DemVoteShareObama - predicted_obama)

voter_data_tx%>%
  feols(DemVoteShare ~ residual_obama)

voter_data %>%
  filter(state_po == "TX") %>%
  ggplot(aes(x = DemVoteShareObama, y = DemVoteShare))+
  geom_point() +
  ylab("Vote Share - Biden") +
  xlab("Vote Share - Obama") +
  ggtitle("Biden vote vs Obama vote") +
  fte_theme()

ggsave("~/Dropbox/Econ1630_Spring2022/Lectures/Chapter5/biden-obama.png",
       width = 6, height =4)


voter_data %>%
  filter(state_po == "TX") %>%
  ggplot(aes(x = DemVoteShareClinton, y = DemVoteShare))+
  geom_point() +
  ylab("Vote Share - Biden") +
  xlab("Vote Share - Clinton") +
  ggtitle("Biden vote vs Clinton vote") +
  fte_theme()

ggsave("~/Dropbox/Econ1630_Spring2022/Lectures/Chapter5/biden-clinton.png",
       width = 6, height =4)


voter_data %>%
  filter(state_po == "TX") %>%
  ggplot(aes(x = DemVoteShareClinton, y = DemVoteShareObama))+
  geom_point() +
  xlab("Vote Share - Clinton") +
  ylab("Vote Share - Obama") +
  ggtitle("Obama vote vs Clinton vote") +
  fte_theme()

ggsave("~/Dropbox/Econ1630_Spring2022/Lectures/Chapter5/obama-clinton.png",
       width = 6, height =4)


voter_data %>%
  filter(state_po == "TX") %>%
  mutate(ObamaMinusClinton = DemVoteShareObama - DemVoteShareClinton) %>%
  ggplot(aes(x = ObamaMinusClinton, y = DemVoteShare))+
  geom_point()+
  xlab("Vote Share - Obama Minus Clinton") +
  ylab("Vote Share - Biden") +
  ggtitle("Obama vote vs Clinton vote") +
  fte_theme()

ggsave("~/Dropbox/Econ1630_Spring2022/Lectures/Chapter5/biden-obama-minus-clinton.png",
       width = 6, height =4)




voter_data_tx %>%
  ggplot(aes(x = residual_obama, y = DemVoteShare))+
  geom_point()+
  xlab("Vote Share - Obama Minus Predicted") +
  ylab("Vote Share - Biden") +
  fte_theme() +
  geom_smooth(method =  "lm", se = F)


ggsave("~/Dropbox/Econ1630_Spring2022/Lectures/Chapter5/biden-obama-residuals.png",
       width = 6, height =4)


voter_data_tx %>%
  ggplot(aes(x = DemVoteShareObama, y = DemVoteShare))+
  geom_point()+
  xlab("Vote Share - Clinton") +
  ylab("Vote Share - Biden") +
  fte_theme() +
  geom_smooth(method = "lm",formula=y~ poly(x, 10, raw=T), se = F)


voter_data_tx %>%
feols(DemVoteShare ~ poly(DemVoteShareClinton,15))
