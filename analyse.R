#!/usr/bin/Rscript
##
## Janzen-Connell Model
## Plot/animate the simulation map of the JCM.
## (c) Daniel Vedder, MIT license
##

library(ggplot2)
library(ggforce)
library(reshape2)

datafile = "jcm_data.csv"

spec_colours = c("cornflowerblue", "darkorange1", "mediumvioletred", "gold",
                 "darkblue", "darkmagenta", "tan2", "darkolivegreen4",
                 "chartreuse", "forestgreen", "yellowgreen", "firebrick4",
                 "mediumorchid1", "wheat4", "cadetblue1", "seagreen1")

## Plot a map of the simulation arena for this update
plot_map = function(update, data, mapname="map") {
    d = data[which(data$update==update),]
    ggplot(data=d) +
        geom_circle(show.legend=FALSE,
                    mapping=aes(x0=x, y0=y, r=(size/2), colour=infected,
                                fill=spec_colours[species])) +
        coord_fixed(ratio=1, xlim=c(-500,500), ylim=c(-500,500)) +
        scale_color_manual(values=c("TRUE"="red", "FALSE"="black")) +
        scale_size_continuous(range=c(min(data$size)/5,max(data$size)/5)) +
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
plot_series = function(dfile=datafile) {
    simname = gsub(".csv", "", dfile)
    d = read.csv(dfile, comment.char="#")
    for (u in unique(d$update)) {
        plot_map(u, d, simname)
    }
}

## Calculate Shannon diversity and equitability for one update
## (cf. Begon, Townsend & Harper (2006), p.471)
shannon = function(udata) {
    species = unique(udata$species)
    p = sapply(species, function(s) dim(udata[which(udata$species==s),])[1]/dim(udata)[1])
    h = sum(sapply(p, function(i) i * log(i))) * -1
    j = h / log(length(species))
    return(c(h,j))
}

## Plot population and diversity development over time
plot_statistics = function(dfile=datafile, toFile=TRUE) {
    simname = gsub(".csv", "", dfile)
    d = read.csv(dfile, comment.char="#")
    if (toFile) jpeg(paste0(simname,"_stats.jpg"), height=720, width=720)
    updates = unique(d$update)
    popsize = sapply(updates, function(u) dim(d[which(d$update==u),])[1])
    shdiv = sapply(updates, function(u) shannon(d[which(d$update==u),]))
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

plot_runs = function(runfiles) {
    for (r in runfiles) {
        print(paste("Analysing", r))
        plot_statistics(r)
        plot_series(r)
    }
}

## Calculate core measures for each scenario:
## - species range (hectare)
## - population density (ind./ha)
## - species proportion (% of community size)
analyse_experiment = function(runfiles) {
    expframe = c()
    for (r in runfiles) {
        sce = strsplit(r, "_")[[1]][1] #scenario
        rep = gsub(".csv", "", strsplit(r, "_")[[1]][2]) #replicate
        dat = read.csv(r, comment.char="#") #complete rundata
        end = dat[which(dat$update==max(dat$update)),] #last update
        com = dim(end)[1] #community size
        for (s in 1:16) {
            spe = end[which(end$species==s),]
            pop = dim(spe)[1] #population size
            if (pop == 0) {
                rng = 0 #species range
                den = 0 #population density
                div = 0 #species proportion
            }
            else {
                rng = (max(spe$x)-min(spe$x))*(max(spe$y)-min(spe$y))/10000
                den = pop/rng #population density
                div = (pop/com)*100 #species proportion
            }
            expframe = rbind(expframe, c(sce, rep, s, rng, den, div))
        }
    }
    colnames(expframe) = c("scenario", "replicate", "species", "range",
                           "density", "proportion")
    return(expframe)
}

## Violin plots showing core measures for each scenario
plot_experiment = function(expdata) {
    ## reshape the data for ggplot2
    d = melt(as.data.frame(expdata), variable.name="measure",
             id.vars=c("scenario", "replicate", "species"))
    d$value = as.numeric(d$value)
    ## range plot
    ggplot(data=d[which(d$measure=="range"),], aes(x=scenario, y=value)) +
        geom_violin(aes(fill=scenario)) +
        scale_x_discrete(limits=c("null", "nopat", "lopat", "hipat"),
                         labels=c("(1) Neutral", "(2) No pathogen",
                                  "(3) Low transmission",
                                  "(4) High transmission")) +
        guides(fill="none") +
        labs(x="Scenario", y="Population range (ha)", tag="A") +
        theme_classic()
    ggsave("range.pdf", width=6, height=3)
    ## density plot
    ggplot(data=d[which(d$measure=="density"),], aes(x=scenario, y=value)) +
        geom_violin(aes(fill=scenario)) +
        scale_x_discrete(limits=c("null", "nopat", "lopat", "hipat"),
                         labels=c("(1) Neutral", "(2) No pathogen",
                                  "(3) Low transmission",
                                  "(4) High transmission")) +
        guides(fill="none") +
        labs(x="Scenario", y="Population density (ind./ha)", tag="B") +
        theme_classic()
    ggsave("density.pdf", width=6, height=3)
    ## proportion plot
    ggplot(data=d[which(d$measure=="proportion"),], aes(x=scenario, y=value)) +
        geom_violin(aes(fill=scenario)) +
        scale_x_discrete(limits=c("null", "nopat", "lopat", "hipat"),
                         labels=c("(1) Neutral", "(2) No pathogen",
                                  "(3) Low transmission",
                                  "(4) High transmission")) +
        guides(fill="none") +
        labs(x="Scenario", y="Population size (% community size)", tag="C") +
        theme_classic()
    ggsave("proportion.pdf", width=6, height=3)
}

## A boxplot showing how many species survived in each scenario
plot_survival = function(expdata) {
    ## Find the number of survivors in a given run
    n_survivors = function(scenario, run) {
        dim(expdata[intersect(which(expdata[,"replicate"]==as.character(run)),
                              intersect(which(expdata[,"scenario"]==scenario),
                                        which(expdata[,"proportion"] > 0))),])[1]
    }
    sdata = c()
    for (s in c("null", "nopat", "lopat", "hipat")) {
        for (i in 0:19) {
            surv = n_survivors(s, i)
            if (is.null(surv)) surv = 0
            sdata = rbind(sdata, c(s, surv))
        }
    }
    colnames(sdata) = c("scenario", "survivors")
    sdata = as.data.frame(sdata)
    sdata$survivors = as.numeric(as.character(sdata$survivors))
    ## Plot the processed data
    ggplot(data=sdata, aes(x=scenario, y=survivors)) +
        ## I don't need the distribution shape here
        geom_violin(aes(fill=scenario)) +
        scale_x_discrete(limits=c("null", "nopat", "lopat", "hipat"),
                         labels=c("(1) Neutral", "(2) No pathogen",
                                  "(3) Low transmission",
                                  "(4) High transmission")) +
        guides(fill="none") +
        labs(x="Scenario", y="Species richness") +
        theme_classic()
    ggsave("survival.pdf", width=6, height=4)
}

## analyse all csv files passed via commandline arguments
## if "all" is passed as well, do a whole-experiment analysis instead
csv = commandArgs()[grepl(".csv", commandArgs())]
if (length(csv) > 0) {
    if (any(grepl("all", commandArgs()))) {
        expdata = analyse_experiment(csv)
        plot_experiment(expdata)
        plot_survival(expdata)
    }
    else {
        plot_runs(csv)
    }
}
