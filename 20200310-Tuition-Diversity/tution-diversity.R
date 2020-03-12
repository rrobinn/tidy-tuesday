# Load libraries
library(lmer)
library(lme4)
library(tidyr)

# Get the Data
tuition_cost <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/tuition_cost.csv')
tuition_income <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/tuition_income.csv') 
salary_potential <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/salary_potential.csv')
historical_tuition <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/historical_tuition.csv')
diversity_school <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/diversity_school.csv')


# explore
colnames(tuition_cost)
colnames(diversity_school)
colnames(salary_potential)

# Has tuition risen?
colnames(historical_tuition)
historical_tuition = historical_tuition %>%
  mutate(yr = vapply(strsplit(historical_tuition$year,"-"), `[`, 1, FUN.VALUE=character(1))) %>%
  mutate(yr = as.numeric(yr)) %>%
  mutate(tuition_type = as.factor(tuition_type))

p1  = historical_tuition %>% 
  filter(tuition_type == 'All Constant') %>%# dollar inflation adjusted     
ggplot(data = ., aes(x = yr, y = tuition_cost, group_by(type), color = type) ) + 
  geom_point() +
  geom_line() + 
  theme_bw() + 
  theme(legend.background = NULL) +
  xlab('Year') +
  ylab('Tution ($ inflation adjusted)') + 
  scale_x_continuous(breaks = seq(1985, 2015, 5))
  

# Calculate % minority & select variables 
minority_enrollment = diversity_school %>%
  filter(category == 'Total Minority') %>%
  mutate(pct_minority = enrollment/total_enrollment) %>%
  dplyr::select(name, state, total_enrollment, pct_minority)

# Join tuition and % enrollment data 
dat = dplyr::left_join(tuition_cost, minority_enrollment, by = c("name", "state"))
# join salary_potential data
salary_potential = salary_potential %>%
  mutate(state = stringr::str_replace(state_name, '-', ' '))
dat = dplyr::left_join(dat, salary_potential, by = c("name", "state"))
dat = dat %>% filter(type == 'Public' | type == 'Private') %>%
  mutate(public_dummy = ifelse(type=='Public',1,0))


# What's the relationship b/w tuition and diverstiy?

# Relationship b/w tuition and career pay 
dat %>% filter(type == 'Private') %>% 
ggplot(data = ., aes(x = in_state_tuition, y = early_career_pay)) +
  geom_point() +
  xlab('Tuition') +
  ylab('Early Career Pay')

dat %>% filter(type == 'Public') %>% 
  ggplot(data = ., aes(x = in_state_tuition, y = early_career_pay)) +
  geom_point() +
  xlab('Tuition') +
  ylab('Early Career Pay')

p2 = dat %>% 
  ggplot(data = ., aes(x = in_state_tuition, y = early_career_pay, color = type, group_by(type))) +
  geom_point() +
  geom_smooth(method= 'lm') + 
  xlab('Tuition') +
  ylab('Early Career Pay') + 
  theme_bw() +
  theme( legend.background = NULL) 

library(patchwork)
p3 = p1 / p2

ggsave(filename = '/Users/sifre002/Box/sifre002/7_Rscripts/TidyTuesday/20200310-Tuition-Diversity/tuition_increase.jpg', p1)
ggsave(filename = '/Users/sifre002/Box/sifre002/7_Rscripts/TidyTuesday/20200310-Tuition-Diversity/combined_fig.jpg', p3)



lm.0 = lm(data = dat, early_career_pay ~ 1)
lm.1 = lm(data = dat, early_career_pay ~ 1 + in_state_tuition)
lm.2 = lm(data = dat, early_career_pay ~ 1 + in_state_tuition + public_dummy)
lm.3 = lm(data = dat, early_career_pay ~ 1 + in_state_tuition + public_dummy + public_dummy:in_state_tuition)
summary(lm.3)

tuition_beta = 4.767e-01
tuition_beta*5000 # For every 5k increase in tuition, salary expectation increases by 2383.5 (for private school)
5.792e+03 # public school has higher early career salary 
interaction_beta = 4.384e-01 # for public schools, each 5k increase in tuition is associated with an even bigger bump









# MISC - to follow up with 
# Relationship b/w tuition and minority 
# dat %>% filter(type == 'Private') %>% 
#   ggplot(data = ., aes(x = in_state_tuition, y = pct_minority)) +
#   geom_point() +
#   xlab('Tuition')
# 
# dat %>% filter(type == 'Public') %>% 
#   ggplot(data = ., aes(x = in_state_tuition, y = pct_minority)) +
#   geom_point() +
#   xlab('Tuition') 
# dat %>% 
#   ggplot(data = ., aes(x = in_state_tuition, y = pct_minority, group_by(type), color = type)) +
#   geom_point() +
#   xlab('Tuition') 
# 
# ggplot(data = dat, aes(x = (in_state_tuition), y = pct_minority)) +
#   geom_point() +
#   xlab('Tuition') 


# explore distributions of interest 
# ggplot(data = dat, aes(x = pct_minority)) + 
#   geom_histogram(color = 'black')
# 
# ggplot(data = dat, aes(x = in_state_tuition)) + 
#   geom_histogram(color = 'black') +
#   facet_grid(~type)
# 
# ggplot(data = dat, (aes(x = early_career_pay))) + 
#   geom_histogram(color = 'black')