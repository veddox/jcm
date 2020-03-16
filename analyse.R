#!/usr/bin/Rscript
##
## Janzen-Connell Model
## Plot/animate the simulation map of the JCM.
## (c) Daniel Vedder, MIT license
##

library(ggplot2)
library(ggforce)
library(gganimate)

datafile = "jcm_data.csv"

plot_map = function(update, data, mapname="map") {
    ggplot(data=data[which(data$Update==update),]) +
        geom_circle(mapping=aes(x0=X, y0=Y, r=Size, fill=as.factor(Species)),
                    show.legend=FALSE) +
        coord_fixed(ratio=1, xlim=c(-500,500), ylim=c(-500,500)) +
        scale_colour_manual(values=rainbow(max(data$Species))) +
        scale_size_continuous(range=c(min(data$Size)/5,max(data$Size)/5)) +
        theme(panel.background=element_rect(colour="black",size=1,fill="lightgray"),
              panel.grid=element_blank(),
              axis.title=element_blank(),
              axis.ticks=element_blank(),
              axis.text=element_blank(),
              plot.margin=unit(c(0.5,0.5,0.4,0.4), "cm")) +
        labs(title=paste("Update:", update))
    ggsave(paste0(mapname,"_",update,".jpg"))
}

plot_series = function(dfile=datafile, simname="jcm_run") {
    d = read.csv(dfile, comment.char="#")
    for (u in unique(d$Update)) {
        plot_map(u, d, simname)
    }
}

render_gif = function(dfile=datafile) {
    d = read.csv(dfile, comment.char="#")
    ##TODO doesn't seem to work yet?
    gp = ggplot(data=d) +
        geom_circle(mapping=aes(x0=X, y0=Y, r=Size, fill=as.factor(Species)),
                    show.legend=FALSE) +
        coord_fixed(ratio=1, xlim=c(-500,500), ylim=c(-500,500)) +
        scale_colour_manual(values=rainbow(max(d$Species))) +
        scale_size_continuous(range=c(min(d$Size)/5,max(d$Size)/5)) +
        theme(panel.background=element_rect(colour="black",size=1,fill="lightgray"),
              panel.grid=element_blank(),
              axis.title=element_blank(),
              axis.ticks=element_blank(),
              axis.text=element_blank(),
              plot.margin=unit(c(0.5,0.5,0.4,0.4), "cm")) +
        labs(title="Update: {Update}") +
        transition_time(Update) +
        view_static() +
        ease_aes("linear")
    animate(gp, renderer=gifski_renderer("run.gif"))
}

plot_statistics = function(dfile=datafile, simname="jcm_run", toFile=TRUE) {
    d = read.csv(dfile, comment.char="#")
    if (toFile) jpeg(paste0(simname,"_stats.jpg"), height=480, width=720)
    popsize = sapply(unique(d$Update), function(u) dim(d[which(d$Update==u),])[1])
    plot(popsize, xlab="Time", ylab="Population size", type="l", col="blue")
    ##TODO diversity (Shannon-Wiener Index)
    ##XXX evenness?
    if (toFile) dev.off()
}

## --- TODO ---
##
## * GIF animations
## * show infected trees
## * record abundance & diversity
##
