#Segmentation Analysis of Fire Emblem: Three Houses character growth rates

library(rvest)
library(factoextra)
library(cluster)
library(lattice)
library(plotly)
library(corrplot)

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
                   House = numeric())


for (i in 1:length(tables)) {
  
        tables[[i]]$House <- i
        init <- rbind(init, tables[[i]])
        
  }


fe_stats <- data.frame(init)
fe_stats$House <- as.factor(fe_stats$House)

fe_stats <- fe_stats[!grepl("(NPC)", fe_stats$Name),]
#fe_stats <- fe_stats[!grepl("Cyril", fe_stats$Name),]


rownames(fe_stats) <- fe_stats[,1]
fe_stats <- fe_stats[-1]

#fe_stats[30,1:9] <- fe_stats[32,1:9] + 20

fe_scale <- data.frame(scale(fe_stats[-10]))


# Segmentation..................................................................................................................

set.seed(1721)

fviz_nbclust(fe_scale, kmeans, method = "silhouette")
fviz_nbclust(fe_scale, kmeans, method = "gap_stat")
fviz_nbclust(fe_scale, kmeans, method = "wss")

km2 <- kmeans(fe_scale, centers = 2, nstart = 25)
km3 <- kmeans(fe_scale, centers = 3, nstart = 25)
km4 <- kmeans(fe_scale, centers = 4, nstart = 25)
km5 <- kmeans(fe_scale, centers = 5, nstart = 25)



fviz_cluster(km2, data = fe_scale, ellipse.type = "norm", ggtheme = theme_minimal(), repel = TRUE)
fviz_cluster(km3, data = fe_scale, ellipse.type = "norm", ggtheme = theme_minimal(), repel = TRUE)
fviz_cluster(km4, data = fe_scale, ellipse.type = "norm", ggtheme = theme_minimal(), repel = TRUE)
fviz_cluster(km5, data = fe_scale, ellipse.type = "norm", ggtheme = theme_minimal(), repel = TRUE)

# Data Analysis...................................................................................................................

fe_stats <- cbind(fe_stats, km4[1])
fe_stats[,11] <- as.factor(fe_stats[,11])

aggregate(fe_stats[1:9], by = list(Cluster = fe_stats$cluster), mean)

aggregate(fe_stats[1:9], by = list(House = fe_stats$House), mean)

# Significant predictive model attained by step-wise regression
regr <- lm(as.numeric(cluster) ~ HP + Mag + Dex + Def, data = fe_stats)

# Data Viz........................................................................................................................

corrplot(cor(fe_stats[,1:9]))

distance <- get_dist(fe_stats[1:9])
fviz_dist(distance, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))

barplot(table(fe_stats$House), main = "Members of Each House", ylab = "Count", xlab = "House", col = c("green", "red", "blue", "yellow", "snow", "navy", "grey"))
barplot(table(fe_stats$cluster), main = "Members of Each House", ylab = "Count", xlab = "House")

xyplot(Str ~ Mag, group=cluster, data=fe_stats, auto.key=list(space="right"), jitter.x=TRUE, jitter.y=TRUE, pch = 19)

plot_ly(
  text = rownames(fe_stats),
  x = fe_stats$HP, 
  y = fe_stats$Mag, 
  z = fe_stats$Def, 
  type = "scatter3d", 
  mode = "markers", 
  color = as.factor(fe_stats$cluster)) %>%
  layout(title = "",
         scene = list(xaxis = list(title = "HP"),
                      yaxis = list(title = "Magic"),
                      zaxis = list(title = "Defence")))
