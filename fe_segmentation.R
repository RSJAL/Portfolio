# Segmentation Analysis of Fire Emblem: Three Houses characters

library(rvest)

url <- "https://serenesforest.net/three-houses/characters/growth-rates/"

tables <- read_html(url) %>% html_table(fill = TRUE)

init <- data.frame(Name = character(), 
                   HP = numeric(), 
                   Str = numeric(), 
                   Mag = numeric(), 
                   Dex = numeric(), 
                   Spd = numeric(), 
                   Lck = numeric(), 
                   Def = numeric(), 
                   Res = numeric(), 
                   Cha = numeric(),
                   Group = numeric())


for (i in 1:length(tables)) {
  
        tables[[i]]$Group <- i
        init <- rbind(init, tables[[i]])
        
  }



fe_stats <- data.frame(init)
fe_stats$Group <- as.factor(fe_stats$Group)

fe_stats <- fe_stats[!grepl("(NPC)", fe_stats$Name),]
rownames(fe_stats) <- NULL

barplot(table(fe_stats$Group), main = "Members of Each House", ylab = "Count", xlab = "Group", col = c("green", "red", "blue", "yellow", "snow", "navy", "grey"))