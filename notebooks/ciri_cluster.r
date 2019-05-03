# Gaussian Mixture Model on CIRI data (cluster model)

library(tidyverse)
library(mclust)

# Read in data, get rid of weird codings
# The -777 should probably be kept at some point, though,
# since it indicates government collapse.
ciri = read_csv("../data/CIRI_Data_1981_2011.csv", 
                na=c("-66", "-77", "-999"))

# Remove some country codes, old measures, and indices
ciri_all = ciri %>% 
  select(-CIRI, -COW, 
         -UNREG, -UNSUBREG, -PHYSINT,
         -NEW_EMPINX, 
         #-CTRY, -YEAR, -UNCTRY, 
         -POLITY, -OLD_RELFRE, -OLD_EMPINX, -OLD_MOVE, -WOSOC)
ciri_all = as.data.frame(ciri_all)

# This might be problematic: many countries will be systematically left out.
ciri_all = na.omit(ciri_all)

colnames(ciri_all) = c("Country", "Year", "UNCountry", "Disappearances", "Extrajudicial Killing",
                       "Political Imprisonment",
                       "Torture by Govt",
                       "Freedom of Assembly",
                       "Freedom of Foreign Movement",
                       "Freedom of Domestic Movement",
                       "Freedom of Speech",
                       "Electoral Self-Determination",
                       "Freedom of Religion",
                       "Worker's Rights",
                       "Women's Economic Rights",
                       "Women's Political Rights",
                       "Judiciary Independence")

# Cluster the countries (don't worry bias in sample for now)
mcbic_all = mclustBIC(ciri_all %>% select(-Country, -Year, -UNCountry))
# Show BIC for different numbers of clusters and different models
plot(mcbic_all)

# Run the best fitting model, by BIC
mc_all = Mclust(ciri_all %>% select(-Country, -Year, -UNCountry))

# To run a specific model, with a specific number of clusters
#mc_all = Mclust(ciri_all, G=5, modelName = "EEV")

table(mc_all$classification)

# Transform for plotting
ciri_class = ciri_all
ciri_class$class = mc_all$classification

ciri_class_long = ciri_class %>%
  select(-Country, -Year, -UNCountry) %>% 
  group_by(class) %>% 
  summarise_all(mean) %>% 
  gather(violation, score, -class) %>% 
  mutate(violation=factor(violation,
                          levels=c("Disappearances",
                                   "Extrajudicial Killing",
                                   
                                   "Torture by Govt",
                                   "Judiciary Independence",
                                   
                                   "Freedom of Foreign Movement",
                                   "Freedom of Domestic Movement",
                                   
                                   "Freedom of Speech",
                                   "Freedom of Assembly",
                                   "Electoral Self-Determination",
                                   "Freedom of Religion",
                                   "Political Imprisonment",
                                   "Worker's Rights",
                                   
                                   "Women's Economic Rights",
                                   "Women's Political Rights"))) %>% 
  mutate(class=factor(class)) 

# Plot Radar Graph
ggplot(data = ciri_class_long, aes(x=violation,y=score,group=class, fill=class, color=class)) +
  geom_line() +
  scale_x_discrete() +
  #facet_wrap(.~class) + # small multiples
  coord_polar() +
  ggtitle("All Country-Years Class Profiles") #+
#theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))

# Line Graph
ggplot(data = ciri_class_long, aes(x=violation,y=score,group=class, fill=class, color=class)) +
  geom_line() +
  scale_x_discrete() +
  coord_polar() +
  ggtitle("All Country-Years Class Profiles") +
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))


# What countries are in each group? 
# (The order of groups can shift each time the model is run,
# so the group/class/cluster numbers are meaningless.)
ciri_class %>% filter(Year==2011 & class==3) %>% pull(Country)
ciri_class %>% filter(Year==2011 & class==4) %>% pull(Country)

# Over the years, which groups do each country fall into?
# Count number of years a Country is classified into each group.
ciri_class %>% 
  group_by(Country) %>% 
  count(class) %>% 
  spread(class,n) %>% 
  print(n=Inf)



##############################
# Hierarchical Cluster Model of Violations
##############################
# Transpose the data
tciri = t(ciri_all %>% select(-Country, -Year, -UNCountry))
rownames(tciri) = c("Disappearances", "Extrajudicial Killing",
                    "Political Imprisonment",
                    "Torture by Govt",
                    "Freedom of Assembly",
                    "Freedom of Foreign Movement",
                    "Freedom of Domestic Movement",
                    "Freedom of Speech",
                    "Electoral Self-Determination",
                    "Freedom of Religion",
                    "Worker's Rights",
                    "Women's Economic Rights",
                    "Women's Political Rights",
                    "Judiciary Independence")

# Calculate distance matrix (Euclidean)
dist_all = dist(tciri)

plot(hclust(dist_all),
     xlab="",
     sub="",
     main="CIRI Hierarchical Cluster Model, all years")


