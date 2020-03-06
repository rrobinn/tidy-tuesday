library(tidyr)
library(dplyr)
library(ggplot2)
season_goals <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-03/season_goals.csv')
game_goals <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-03/game_goals.csv')
top_250 <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-03/top_250.csv')

# summarize player-level stats 
player_stats = season_goals %>%
  dplyr::select(player, penalty_min, goals) %>%
  group_by(player) %>%
  summarize(ave_penalty = mean(penalty_min),
            ave_goals = mean(goals))

# Summarize season-level stats 
# There are some cases where a player switched teams mid-season. Average those stats together. 
season_goals2 = season_goals %>%
  dplyr::select(rank, position, player, season, age, goals, penalty_min) %>%
  group_by(player,season) %>%
  summarize(season_goals = mean(goals), # they have more than one entry per season if they switched teams
            season_penalty = mean(penalty_min))

merged = merge(season_goals2, player_stats, by = 'player')
# get plater rank
merged = merge(merged, top_250 %>% dplyr::select(raw_rank, player), by = 'player', all.x=TRUE)

# Center season averages on career averages 
merged = merged %>%
  mutate(penalty_c = season_penalty - ave_penalty,
         goals_c = season_goals - ave_goals,
         player = as.factor(player),
         year =lapply(strsplit(season, '-'), '[', 1),
         year = as.numeric(year))

# Check out skew of data
ggplot(data = merged, aes(x=season_penalty)) +
  geom_histogram(color = 'black') + 
  xlab('Average penalty minutes per season') +
  theme_bw()
ggplot(data = merged, aes(x=season_goals)) +
  geom_histogram(color = 'black') + 
  xlab('Average goals per season') + 
  theme_bw()

# Relationship b/w penalty min & season goals (uncentered)
p1 = ggplot(data = merged, aes(x = season_penalty, y=season_goals))+
  geom_point(alpha = .4) +
  xlab('Average penalty minutes per season') + 
  ylab('Average goals per season') + theme_bw()

# Relationship b/w penality min & season goals (centered on career average)
annotation = data.frame(
  x=c(-75,75),
  y=c(-40, -40),
  label = c('Penalty minutes BELOW \n career average', 
            'Penalty minutes ABOVE \n career average')
)
annotation2 = data.frame(
  x=c(-150, -150),
  y=c(25, -25),
  label = c('Goal count ABOVE \n career average', 'Goal count BELOW \n career average')
)


p2 =ggplot(data = merged, aes(x = penalty_c, y=goals_c))+
  geom_point(alpha = .4) +
  xlab('Penalty minutes per season, centered on career average') +
  ylab('Goals per season, centered on career average') + 
  scale_y_continuous(limits = c(-50,50))+ 
  scale_x_continuous(limits = c(-150, 150)) +
  geom_hline(yintercept = 0, color = 'blue') + 
  geom_vline(xintercept=0, color = 'red') +
  geom_text(data = annotation, aes(x=x, y=y,label=label), color = 'red', fontface='bold') +
  geom_text(data = annotation2, aes(x=x, y=y,label=label), color = 'blue', fontface='bold', angle = 90) +
  geom_segment(aes(x = -25, xend = -120, y = -50, yend=-50), 
               arrow = arrow(length = unit(0.5, 'cm')), color = 'red') + 
  geom_segment(aes(x = 25, xend = 120, y = -50, yend=-50), 
               arrow = arrow(length = unit(0.5, 'cm')), color = 'red') +
  geom_segment(aes(x = -130, xend = -130, y=-10, yend=-40), 
               arrow = arrow(length = unit(0.5, 'cm')), color = 'blue')  +
  geom_segment(aes(x = -130, xend = -130, y=10, yend=40), 
               arrow = arrow(length = unit(0.5, 'cm')), color = 'blue')  +
    theme_bw()


ggsave(plot=p1, filename='/Users/sifre002/Box/sifre002/7_Rscripts/TidyTuesday/20200303-HockeyGoals/uncentered.pdf')

ggsave(plot=p2, filename='/Users/sifre002/Box/sifre002/7_Rscripts/TidyTuesday/20200303-HockeyGoals/centered.pdf')

p3 = gridExtra::grid.arrange(p1,p2)
ggsave(plot=p3, filename='/Users/sifre002/Box/sifre002/7_Rscripts/TidyTuesday/20200303-HockeyGoals/grid.jpg')




