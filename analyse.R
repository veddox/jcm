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

## Plot a map of the simulation arena for this update
plot_map = function(update, data, mapname="map") {
    ggplot(data=data[which(data$Update==update),]) +
        ##TODO keep fill colour constant across time
        ##TODO change line colour depending on infection status
        geom_circle(mapping=aes(x0=X, y0=Y, r=(Size/2), fill=as.factor(Species)),
                    show.legend=FALSE) +
        coord_fixed(ratio=1, xlim=c(-500,500), ylim=c(-500,500)) +
        scale_colour_manual(values=rainbow(max(data$Species))) +
        scale_size_continuous(range=c(min(data$Size)/5,max(data$Size)/5)) +
        ##XXX this could probably be done with ggforce:
        ##theme_no_axes(theme_grey())
        theme(panel.background=element_rect(colour="black",size=1,fill="lightgray"),
              panel.grid=element_blank(),
              axis.title=element_blank(),
              axis.ticks=element_blank(),
              axis.text=element_blank(),
              plot.margin=unit(c(0.5,0.5,0.4,0.4), "cm")) +
        labs(title=paste("Update:", update))
    ggsave(paste0(mapname,"_",update,".jpg"))
}

## Plot a series of maps for this simulation run
plot_series = function(dfile=datafile, simname="jcm_run") {
    d = read.csv(dfile, comment.char="#")
    for (u in unique(d$Update)) {
        plot_map(u, d, simname)
    }
}

## Create an animated GIF of the simulation map over time
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

## Calculate Shannon diversity and equitability for one update
## (cf. Begon, Townsend & Harper (2006), p.471)
shannon = function(udata) {
    species = unique(udata$Species)
    p = sapply(species, function(s) dim(udata[which(udata$Species==s),])[1]/dim(udata)[1])
    h = sum(sapply(p, function(i) i * log(i))) * -1
    j = h / log(length(species))
    return(c(h,j))
}

## Plot population and diversity development over time
plot_statistics = function(dfile=datafile, simname="jcm_run", toFile=TRUE) {
    d = read.csv(dfile, comment.char="#")
    if (toFile) jpeg(paste0(simname,"_stats.jpg"), height=720, width=720)
    updates = unique(d$Update)
    popsize = sapply(updates, function(u) dim(d[which(d$Update==u),])[1])
    shdiv = sapply(updates, function(u) shannon(d[which(d$Update==u),]))
    diversity = shdiv[1,]
    equitability = shdiv[2,]
    par(mfrow=c(2,1), mai=c(0.9, 0.9, 0.2, 0.2))
    plot(updates, popsize, ylab="Population size", type="l", col="orange",
         xlab="Time")
    plot(updates, diversity, col="green", type="l", xlab="Time",
         ylab="Diversity", ylim=c(0, max(diversity)+0.5))
    lines(updates, equitability, col="blue")
    #TODO add legend
    if (toFile) dev.off()
}

## --- TODO ---
##
## * GIF animations
## * show infected trees
##
