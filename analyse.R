#!/usr/bin/Rscript
##
## Janzen-Connell Model
## Plot/animate the simulation map of the JCM.
## (c) Daniel Vedder, MIT license
##

library(ggplot2)
library(ggforce)
library(gganimate)

d = read.csv("jcm_data.csv", comment.char="#")

ggplot(data=d) +
    geom_circle(mapping=aes(x0=X, y0=Y, r=Size, fill=as.factor(Species)),
                show.legend=FALSE) +
    coord_fixed(ratio=1, xlim=c(-500,500), ylim=c(-500,500)) +
    scale_colour_manual(values=rainbow(max(d$Species))) +
    scale_size_continuous(range=c(min(d$Size)/5,max(d$Size)/5)) +
    labs(x="", y="") +
    theme(panel.background=element_rect(colour="black",size=1,fill="lightgray"),
          panel.grid=element_blank(),
          axis.ticks=element_blank(),
          axis.text=element_blank(),
          plot.margin=unit(c(0,0,0,0), "cm"))

ggsave("map0.jpg")
