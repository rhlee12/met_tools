## Plot wind roses from met station data.
## Data must contain named columns
##
# Load required pkgs
require(ggplot2)
require(readxl)
# Point R to the fil
wind.data.location="~/Desktop/2013-2016 MetData_DD_WindRose.xlsx"
sheet="Data"
speed.name="Average Wind Speed"
dir.name="Wind Direction"

# Read in data, coerce to data frame
data=data.frame(readxl::read_xlsx(path = wind.data.location, sheet = sheet))

# Fixing column names
colnames(data)=c("Water Year", "Date", colnames(data)[3:ncol(data)])
data=data[-1,]

#Function definition
wind.rose.plot = function(data, speed.name, dir.name, speed.bins, dir.bins, save.dir){
    #
    options(stringsAsFactors = F)

    # Set default bin breakdowns
    if(missing(speed.bins)){speed.bins=10}
    if(missing(dir.bins)){dir.bins=36}

    #Make breaks for direction
    degree.steps<-as.numeric(360/dir.bins)
    dir.bin.seq<-seq(0, 360, by=360/dir.bins)

    # remove spaces in column names, replace w/ "." as R does
    speed.name=gsub(pattern = " ", replacement = ".", x = speed.name)
    dir.name=gsub(pattern = " ", replacement = ".", x = dir.name)

    # make only wind speed and direciton data frame
    plotable.df=data.frame(speed=data[,grep(x=colnames(data), pattern = speed.name)],
                           direction=data[,grep(x=colnames(data), pattern = dir.name)])

    # Cut the data up
    plotable.df=cbind(plotable.df, speed.cut = cut(as.numeric(plotable.df$speed), breaks = speed.bins),
                      dir.cut= cut(as.numeric(plotable.df$direction), breaks = dir.bin.seq))
    plotable.df=rbind(plotable.df,
                      data.frame(speed=rep(NA, times=length(levels(plotable.df$dir.cut))),
                                 direction=rep(NA, times=length(levels(plotable.df$dir.cut))),
                                 dir.cut=levels(plotable.df$dir.cut),
                                 speed.cut=rep(0, times=length(levels(plotable.df$dir.cut)))
                      )
    )




    #plotable.df<-stats::na.omit(plotable.df)

    # Make labels and title
    bgn.labels<- unique((dir.bin.seq-(degree.steps/2))%%360)
    end.labels<- unique((dir.bin.seq+(degree.steps/2))%%360)
    dir.labels<-paste0(bgn.labels, "-", end.labels)
    title=""
    #Make and prettify the plot
    ggplot2::ggplot(data = plotable.df, ggplot2::aes(x=dir.cut, fill=speed.cut, colors=factor(speed.cut)))+
        ggplot2::geom_bar(width = .95, show.legend = T, na.rm = T)+
        ggplot2::theme_linedraw()+
        ggplot2::coord_polar(theta = "x", start = 0)+
        ggplot2::xlab("")+
        ggplot2::ylab("Count")+
        ggplot2::labs(title=title)+
        ggplot2::scale_x_discrete(labels=dir.labels)+
        ggplot2::scale_fill_discrete(h = c(0, 240), l=65, c=100, name="Wind Speed, m/s")+
        ggplot2::geom_vline(xintercept=c(0.5, 9.5, 18.5, 27.5))+
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = (90-end.labels)%%180))

}
