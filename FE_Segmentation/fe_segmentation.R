#Segmentation Analysis of Fire Emblem: Three Houses character growth rates

library(rvest)
library(factoextra)
library(cluster)
library(lattice)

# Data Import................................................................................................................


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
rownames(fe_stats) <- fe_stats[,1]
fe_stats <- fe_stats[2:11]

fe_scale <- data.frame(scale(fe_stats[1:9]))


# Segmentation..................................................................................................................

fviz_nbclust(fe_scale, kmeans, method = "silhouette")
fviz_nbclust(fe_scale, kmeans, method = "gap_stat")
fviz_nbclust(fe_scale, kmeans, method = "wss")

km2 <- kmeans(fe_scale, centers = 2, nstart = 25)
km3 <- kmeans(fe_scale, centers = 3, nstart = 25)
km4 <- kmeans(fe_scale, centers = 4, nstart = 25)
km5 <- kmeans(fe_scale, centers = 5, nstart = 25)

fviz_cluster(km2, data = fe_scale, ellipse.type = "norm", ggtheme = theme_minimal())
fviz_cluster(km3, data = fe_scale, ellipse.type = "norm", ggtheme = theme_minimal())
fviz_cluster(km4, data = fe_scale, ellipse.type = "norm", ggtheme = theme_minimal())
#5 Cluster is worthless statistically but useful for showing when adding more clusters stops becoming useful
fviz_cluster(km5, data = fe_scale, ellipse.type = "norm", ggtheme = theme_minimal())

# Data Viz......................................................................................................................

fe_stats <- cbind(fe_stats, km4[1])
fe_stats[,11] <- as.factor(fe_stats_test[,11])

aggregate(fe_stats[1:9], by = list(Cluster = fe_stats$cluster), mean)


barplot(table(fe_stats$Group), main = "Members of Each House", ylab = "Count", xlab = "Group", col = c("green", "red", "blue", "yellow", "snow", "navy", "grey"))
barplot(table(fe_stats$cluster), main = "Members of Each House", ylab = "Count", xlab = "Group")
xyplot(Str ~ Mag, group=cluster, data=fe_stats, auto.key=list(space="right"), jitter.x=TRUE, jitter.y=TRUE, pch = 19)
