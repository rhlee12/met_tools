## Plot wind roses from met station data.
## Data must contain named columns
##
# Load required pkgs
require(ggplot2)
require(readxl)


# Point R to the fil
wind.data.location="~/Desktop/2013-2016 MetData_DD_WindRose.xlsx" # where does the wind data live?
sheet="Data" # if using xls files, what is the name of the sheet with the data?
speed.name="Average Wind Speed" # what is the name of the speed column
dir.name="Wind Direction" #what is the name of the direction column
save.dir="~/Desktop/" # Where do you want to save the output plot?
speed.bins=c(0, 1, 2, 3, 4, 5)

# Read in data, coerce to data frame
data=data.frame(readxl::read_xlsx(path = wind.data.location, sheet = sheet))

# Fixing column names - specific to this file
colnames(data)=c("Water Year", "Date", colnames(data)[3:ncol(data)])
data=data[-1,]

#Function definition - hit source in the upper right to load the function, and execude script
wind.rose.plot = function(data, speed.name, dir.name, speed.bins, plot.title, save.dir){
  options(stringsAsFactors = F)
  #no title if none give
  if(missing(plot.title)){plot.title=""}
  
  # Set default bin breakdowns
  if(missing(speed.bins)){speed.bins=c(0, 2, 4, 6, 8, 10)}
  
  #Make breaks for direction
  dir.bins=36
  degree.steps<-as.numeric(360/dir.bins)
  dir.bin.seq<-seq(0, 360, by=360/dir.bins)
  
  # remove spaces in column names, replace w/ "." as R does
  speed.name=gsub(pattern = " ", replacement = ".", x = speed.name)
  dir.name=gsub(pattern = " ", replacement = ".", x = dir.name)
  
  # make only wind speed and direciton data frame
  plotable.df=data.frame(speed=data[,grep(x=colnames(data), pattern = speed.name)],
                         direction=data[,grep(x=colnames(data), pattern = dir.name)])
  
  # Cut the data up
  plotable.df=cbind(plotable.df, 
                    speed.cut = cut(as.numeric(plotable.df$speed), breaks = speed.bins),
                    dir.cut= cut(as.numeric(plotable.df$direction), breaks = dir.bin.seq)
  )
  
  # Clean up the binned wind speeds (make them nice labels)
  plotable.df$speed.cut=gsub(pattern = ",", replacement = " to ", x = plotable.df$speed.cut)
  plotable.df$speed.cut=gsub(pattern = "\\(|\\]", replacement = "", x = plotable.df$speed.cut)
  plotable.df$speed.cut=paste0(plotable.df$speed.cut, " m/s")
  plotable.df$speed.cut[grepl(x = plotable.df$speed.cut, pattern = "NA m/s")]=NA
  
  # Breakdowns of percentages, for labeling
  ## How many counts of wind dir?
  total.counts=sum(table(plotable.df$dir.cut))
  ## Max observed counts by dir
  max.y=max(table(plotable.df$dir.cut))
  ## Math for locations of NESW
  label.y=max.y*.9
  ## Set breaks for the percent labels
  y.breaks=seq(from=0, to=round(max.y), length.out = 5)
  ## make percentage labels
  y.labs=paste0(round(seq(from=0, to=round(max.y/total.counts*100), length.out = 5), digits = 1), "%")
  
  #Make and prettify the plot
  plot.out=ggplot2::ggplot(data = plotable.df, ggplot2::aes(x=dir.cut, fill=speed.cut))+
    ggplot2::geom_bar(width = .95, show.legend = T, na.rm = T)+
    ggplot2::theme_linedraw()+
    ggplot2::coord_polar(theta = "x", start = 0)+
    ggplot2::scale_y_continuous(breaks=y.breaks, labels = NULL)+
    ggplot2::labs(x="", y="")+
    ggplot2::labs(title=title)+
    ggplot2::scale_x_discrete(labels=NULL, drop=F)+
    ggplot2::scale_fill_discrete(h = c(0, 240), c=100, name="Wind Speed", direction = 1, na.value = "white", h.start = 90)+
    ggplot2::geom_vline(xintercept=c(0.5, 9.5, 18.5, 27.5))+#crosshairs
    ggplot2::theme(axis.line.x =ggplot2::element_line(colour = "gray"))+
    ggplot2::annotate(x = c(0.8, 9.2, 18.2, 27.8), y = rep(label.y, 4), geom="text", label=c("N", "E", "S", "W"))+
    ggplot2::annotate(x = c(4.7, 4.7, 4.7, 4.7), y = y.breaks[2:5], geom="text", label=y.labs[2:5], angle=-45)
  
  ggplot2::ggsave(filename = "windrose.pdf", plot = plot.out, device = "pdf", path = save.dir, width = 10, height = 7.5, units = "in", dpi = 180)
  return(plot.out)
}

## Run the function
wind.rose.plot(data=data, 
               speed.name=speed.name,
               dir.name=dir.name,
               speed.bins = speed.bins,
               save.dir=save.dir)
