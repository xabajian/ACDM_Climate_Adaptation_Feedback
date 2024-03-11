library(rworldmap)
library(classInt)
library(RColorBrewer)
library(haven)
install.packages('read_data')

setwd("/Users/xabajian/Dropbox/adaptation_multiplier_data/processedData")
#getting smallexample data and joining to a map

library(haven)
country_year_emissions_factor <- read_dta("country_year_emissions_factor_2010s_imputed.dta")


sPDF <- joinCountryData2Map(country_year_emissions_factor
                            ,joinCode = "ISO3"
                            ,nameJoinColumn = "ISO3"
                            ,mapResolution = "coarse")

#getting class intervals
classInt <- classIntervals( sPDF[["mean_2010s_electric"]]
                            ,n=12, style = "jenks")
#catMethod = classInt[["brks"]]
catMethod = c(0, 0.5, 1, 1.5, 2,2.5,3,3.5,4,4.5,5)
#getting colours
colourPalette <- brewer.pal(12,'RdPu')
#plot map
mapDevice() #create world map shaped window
mapParams <- mapCountryData(sPDF
                            ,nameColumnToPlot="mean_2010s_otherfuels"
                            #,nameColumnToPlot="mean_2010s_electric mean_2010s_otherfuels"
                            ,addLegend=FALSE
                            ,catMethod = catMethod
                            ,colourPalette=colourPalette
                            ,mapTitle = "Imputed Other Fuels Emissions Factors, 2010-18")
                            #,mapTitle = "Imputed Electricity Emissions Factors, 2010-18")
#adding legend
do.call(addMapLegend
        ,c(mapParams
           ,legendLabels="all"
           ,legendWidth=0.5
           ,legendIntervals="data"
           ,legendMar = 2))

