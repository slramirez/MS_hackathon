
# Load in libraries for data cleaning.
library(tidyverse)
library(ggplot2)
library(mclust)

# Read in CIRI data and select columns of interest.
ciri = read_csv("../data/CIRI_DATA_2016.csv", na=c("-66", "-77", "-999", "-99"))
names(ciri) = tolower(names(ciri))
ciri = select(ciri,unctry,countryname,year,disap,kill,tort,polpris,assn,formov,
              dommov,speech,elecsd,new_relfre,worker,wecon,wopol,injud) %>% 
  arrange(countryname, year)

# This might be problematic: many countries may be systematically left out.
# Test the number of countries retrained, and it remains about the same. May change when subset by year.
ciri = na.omit(ciri)
oldNames = colnames(ciri)

colnames(ciri) = c("UNCountry", "Country", "Year",  "Disappearances", "Extrajudicial Killing",
                       "Torture by Govt", "Political Imprisonment",
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
# Reference old and new names.
ref = data.frame(oldNames, names = colnames(ciri))

# Hold results by year in a list.
ciri_clusters = list()
# Cluster and transform data for plotting.
clusterBYyear = function(df, year){
  # Subset by year
  df = df %>% filter(Year == year)
  # Run Model
  mod = Mclust(df %>% select(-Country, -Year, -UNCountry))
  # Add classification to df
  df$class = mod$classification
  
  # Make df into long and summ
  df_long = df %>%
    select(-Country, -Year, -UNCountry) %>% 
    group_by(class) %>% 
    summarise_all(median) %>% 
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
  
  fin = list(model = mod, df_long = df_long, df = df)
  return(fin)
}

ciri_clusters[['2013']] = clusterBYyear(ciri, 2013)
ciri_clusters[['2014']] = clusterBYyear(ciri, 2014)
ciri_clusters[['2015']] = clusterBYyear(ciri, 2015)

# Determine wide format.
wide = bind_rows(ciri_clusters$`2013`$df, ciri_clusters$`2014`$df, ciri_clusters$`2015`$df)
# Revert to original ciri headers for Gareth
back = data.frame(current = names(wide)) %>% left_join(.,ref,by= c('current'='names'))
colnames(wide) = back$oldNames
colnames(wide)[18] = 'class'
write_csv(wide, "../data/cluster_word.csv")

# Database
library(DBI)
library(dbplyr)
library(RSQLite)

# Connect to Hack DB.
con = dbConnect(SQLite(), dbname = "../data/MS_hackathon.db")
#dbRemoveTable(con,"CIRI_Cluster")
# Write to Hack DB.
dbWriteTable(con,"CIRI_Cluster",wide)




# Plot Radar Graph
cols <- c("8" = "red", "4" = "blue", "6" = "darkgreen", "10" = "orange")

ciri_clusters[['2013']]$df_long %>% arrange(violation) %>% 
ggplot(data = ., aes(x=violation, y=score, group=class, fill=class)) +
  geom_polygon(alpha = 0.5) +
  scale_x_discrete(labels = c("Disappearances" = "Disappearances",
                              "Extrajudicial Killing" = "Extrajudicial Killing",
                              
                              "Torture by Govt" = expression("Government \n Torture"),
                              "Judiciary Independence"= expression("Judiciary \n Ind."),
                              
                              "Freedom of Foreign Movement"="F. of Foreign Move.",
                              "Freedom of Domestic Movement"="F. of Domestic Move.",
                              
                              "Freedom of Speech"="F. of Speech",
                              "Freedom of Assembly"="F. of Assembly",
                              "Electoral Self-Determination"="Electoral Self-Determination",
                              "Freedom of Religion"="F. of Religion",
                              "Political Imprisonment"=expression("Polit. Impris."),
                              "Worker's Rights"="Worker's Rights",
                              
                              "Women's Economic Rights"=expression("Women's Econ. \n Rights"),
                              "Women's Political Rights"=expression("Women's Polit. \n Rights"))) +
  scale_fill_manual(values = c("#6699CC", "#FFF275", "#FF8C42","#FF3C38","#A23E48","#20BF55","#0B4F6C","#757575")) +
  facet_wrap(.~class) + # small multiples
  coord_polar(clip = "off") +
  theme_bw() +
  theme(legend.direction = "horizontal", legend.position = "top",
        panel.spacing = unit(1, "lines"),
        axis.title = element_blank(), 
        strip.text = element_blank(), 
        axis.line = element_blank(), 
        axis.text.y.left = element_blank(), axis.ticks = element_blank(),
        legend.title = element_blank(), panel.border = element_blank(), legend.text = ) +
  guides(fill = guide_legend(label.position = "bottom"))

ggsave("../interactive_map/cluster_imgs/2015.png", width = 11, height = 8, units = "in", dpi = 200)

