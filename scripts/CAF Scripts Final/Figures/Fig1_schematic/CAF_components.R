# Heuristic figure of the climate adaptation feedback
# Top panel: cold and hot climate distributions, with and without climate change
# Middle panel: other fuels and elec dose response functions for cold and hot countries
# Bottom panel: CO2 response for each country, showing both a high and low intensity example

library(ggplot2)
library(RColorBrewer)
library(cowplot)
library(dplyr)

wd = '/Users/tammacarleton/Dropbox/Works_in_progress/git_repos/adaptation_multiplier'

#######################################################  
# 1. Temperature distributions (cold and hot countries)
#######################################################
set.seed(2468)
c0 = rnorm(1000, mean = -5, sd=5)
c1 = rnorm(1000, mean = 0, sd=5)
h0 = rnorm(1000, mean = 23, sd=5)
h1 = rnorm(1000, mean = 26, sd=5)
temps = data.frame(cbind(c0,c1,h0,h1))

bu = brewer.pal(n = 8, name = "RdYlBu")[7]
rd = brewer.pal(n = 8, name = "RdYlBu")[2]
min = min(temps$c0)
max = max(temps$h1)

gc = ggplot(temps) + geom_density(aes(x=c0), fill=bu, color=bu, alpha=0.8) + 
  geom_density(aes(x=c1), fill=rd, color=rd, alpha=0.6) + xlim(min,max) + xlab(expression(paste("Daily temperature (",degree,"C)"))) +
  theme_classic() + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
gc
gh = ggplot(temps) + geom_density(aes(x=h0), fill=bu, color=bu, alpha=0.8) + 
  geom_density(aes(x=h1), fill=rd, color=rd, alpha=0.6) + xlim(min,max) + xlab(expression(paste("Daily temperature (",degree,"C)"))) + 
  theme_classic() + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
gh

############################################
# 2. Temperature response functions
############################################
dailyT = seq(-25,50,.25)
aC = 2
hC = 20
kC = 0
aH = 1
hH = 20
kH = 0
y = (aC*(dailyT-hC)^2+kC)*(dailyT<hC) + (aH*(dailyT-hH)^2+kH)*(dailyT>=hC)
plot(dailyT,y)

makeresponse = function(temps, aC, hC, kC, aH, hH, kH) {
  y = (aC*(dailyT-hC)^2+kC)*(dailyT<hC) + (aH*(dailyT-hH)^2+kH)*(dailyT>=hC)
}

coldOTHER = makeresponse(dailyT,2,20,0,.5,20,0)
hotOTHER = makeresponse(dailyT, .05,20,0,.2,20,0)
coldELEC = makeresponse(dailyT, 1,20,0,1.8,20,0)
hotELEC = makeresponse(dailyT, .01,20,0,.8,20,0)

EJdf = data.frame(cbind(dailyT, coldOTHER, hotOTHER,coldELEC,hotELEC)) 

# plot
min = 0
max = 4000
rc = ggplot(EJdf) + geom_line(aes(y=coldOTHER, x=dailyT), color= bu, size=1) +
  geom_line(aes(y=coldELEC,x=dailyT), color=rd, size=1)+ ylim(min,max) + xlab(expression(paste("Daily temperature (",degree,"C)")))+ 
  annotate(geom="text", x=40, y=1800, label="Electricity",color=rd,size=3) + annotate(geom="text", x=40, y=1625, label="Other fuels",color=bu,size=3)+
  theme_classic() + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) + ylab("EJ")
rh = ggplot(EJdf) + geom_line(aes(y=hotOTHER, x=dailyT), color= bu, size=1) +
  geom_line(aes(y=hotELEC,x=dailyT), color=rd, size=1)+ ylim(min,max) + xlab(expression(paste("Daily temperature (",degree,"C)")))+ 
  annotate(geom="text", x=40, y=1800, label="Electricity",color=rd,size=3) + annotate(geom="text", x=40, y=1625, label="Other fuels",color=bu,size=3)+
  theme_classic() + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) + ylab("EJ")

############################################
# 3. CO2 responses
############################################
min = 0
max = 2000
fctCANOTHER = 0.5092992
fctCANELEC = 0.1529889
fctSWEOTHER = .2762191
fctSWEELEC = .0143556	
fctINDOTHER = 1.387864
fctINDELEC = 0.7831666
fctBRAOTHER = 0.6156878
fctBRAELEC = 0.1164444	
EJdf = EJdf %>% mutate(CANCO2 = coldOTHER*fctCANOTHER + coldELEC*fctCANELEC) %>%
  mutate(INDCO2 = hotOTHER*fctINDOTHER + hotELEC*fctINDELEC) %>% 
  mutate(SWECO2 = coldOTHER*fctSWEOTHER + coldELEC*fctSWEELEC) %>%
  mutate(BRACO2 = hotOTHER*fctBRAOTHER + hotELEC*fctBRAELEC)

purp = brewer.pal(n = 11, name = "Spectral")[11]
teal = brewer.pal(n = 11, name = "BrBG")[11]
ec = ggplot(EJdf) + geom_line(aes(y=CANCO2, x=dailyT), color= purp, size=1) +  geom_line(aes(y=SWECO2, x=dailyT), color=purp, alpha=.7, size=1, linetype="dashed") +
  ylim(min,max) + xlab(expression(paste("Daily temperature (",degree,"C)")))+ theme_classic() +
   theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) + ylab(expression(CO[2])) + 
  annotate(geom="text", x=40, y=1800, label="Canada",color=purp,size=3) + annotate(geom="text", x=40, y=1625, label="Sweden",color=purp,alpha=.7,size=3)
ec
eh = ggplot(EJdf) + geom_line(aes(y=INDCO2, x=dailyT), color= teal, size=1) + geom_line(aes(y=BRACO2, x=dailyT), color= teal, alpha=.7, size=1, linetype="dashed") +
  ylim(min,max) + xlab(expression(paste("Daily temperature (",degree,"C)")))+ theme_classic() +
   theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) + ylab(expression(CO[2])) + 
  annotate(geom="text", x=40, y=1800, label="India",color=teal,size=3) + annotate(geom="text", x=40, y=1625, label="Brazil",color=teal,alpha=.7,size=3)
eh

############################################
# 4. Global CAF and temp change
############################################

time = seq(2020,2100,1)
posCO2 = .01*(time-2020)^3
negCO2 = -.01*(time-2020)^3
dftime = data.frame(cbind(time,posCO2,negCO2))

panelc = ggplot(dftime) + geom_line(aes(x=time,y=posCO2), color=rd, size=1) +
  geom_line(aes(x=time,y=negCO2), color=bu, size=1) + 
  geom_hline(yintercept=0, color="grey",linetype="solid", size=1) +
  ylab(expression(paste("Global ",CO[2]))) + xlab("") +
  annotate(geom="text", x=2060, y=3500, label="Positive global CAF",color=rd,size=3) + 
  annotate(geom="text", x=2060, y=-3500, label="Negative global CAF",color=bu,alpha=1,size=3) +
  annotate(geom="text", x=2082, y=400, label="No adaptation",color="grey",alpha=1,size=3) +
  theme_classic() + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) 
panelc

dftime = dftime %>% mutate(temp=.01*time-2020) %>% mutate(tempPOS = temp+.0001*posCO2, tempNEG=temp+.0001*negCO2)

paneld = ggplot(dftime) + geom_line(aes(x=time,y=tempPOS), color=rd, size=1) +
  geom_line(aes(x=time,y=tempNEG), color=bu, size=1) + 
  geom_line(aes(x=time,y=temp),color="grey",size=1) +
  ylab(expression(paste("GMST (",degree,"C)"))) + xlab("") +
  annotate(geom="text", x=2060, y=-1998.8, label="Positive global CAF",color=rd,size=3) + 
  annotate(geom="text", x=2075, y=-1999.6, label="Negative global CAF",color=bu,alpha=1,size=3) +
  theme_classic()+
  theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) 
paneld

# plot grid so far
p = plot_grid(gc,gh,rc,rh,ec,eh,panelc,paneld,nrow=4,labels="auto")
p

# save
ggsave(file.path(wd, "figures", "CAF_components.pdf"), plot = p, width = 5, height = 8)

# Heuristic figure of the climate adaptation feedback
# Top panel: cold and hot climate distributions, with and without climate change
# Middle panel: other fuels and elec dose response functions for cold and hot countries
# Bottom panel: CO2 response for each country, showing both a high and low intensity example

library(ggplot2)
library(RColorBrewer)
library(cowplot)
library(dplyr)

wd = '/Users/tammacarleton/Dropbox/Works_in_progress/git_repos/adaptation_multiplier'

#######################################################  
# 1. Temperature distributions (cold and hot countries)
#######################################################
set.seed(2468)
c0 = rnorm(1000, mean = -5, sd=5)
c1 = rnorm(1000, mean = 0, sd=5)
h0 = rnorm(1000, mean = 23, sd=5)
h1 = rnorm(1000, mean = 26, sd=5)
temps = data.frame(cbind(c0,c1,h0,h1))

bu = brewer.pal(n = 8, name = "RdYlBu")[7]
rd = brewer.pal(n = 8, name = "RdYlBu")[2]
min = min(temps$c0)
max = max(temps$h1)

gc = ggplot(temps) + geom_density(aes(x=c0), fill=bu, color=bu, alpha=0.8) + 
  geom_density(aes(x=c1), fill=rd, color=rd, alpha=0.6) + xlim(min,max) + xlab(expression(paste("Daily temperature (",degree,"C)"))) +
  theme_classic() + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
gc
gh = ggplot(temps) + geom_density(aes(x=h0), fill=bu, color=bu, alpha=0.8) + 
  geom_density(aes(x=h1), fill=rd, color=rd, alpha=0.6) + xlim(min,max) + xlab(expression(paste("Daily temperature (",degree,"C)"))) + 
  theme_classic() + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
gh

############################################
# 2. Temperature response functions
############################################
dailyT = seq(-25,50,.25)
aC = 2
hC = 20
kC = 0
aH = 1
hH = 20
kH = 0
y = (aC*(dailyT-hC)^2+kC)*(dailyT<hC) + (aH*(dailyT-hH)^2+kH)*(dailyT>=hC)
plot(dailyT,y)

makeresponse = function(temps, aC, hC, kC, aH, hH, kH) {
  y = (aC*(dailyT-hC)^2+kC)*(dailyT<hC) + (aH*(dailyT-hH)^2+kH)*(dailyT>=hC)
}

coldOTHER = makeresponse(dailyT,2,20,0,.5,20,0)
hotOTHER = makeresponse(dailyT, .05,20,0,.2,20,0)
coldELEC = makeresponse(dailyT, 1,20,0,1.8,20,0)
hotELEC = makeresponse(dailyT, .01,20,0,.8,20,0)

EJdf = data.frame(cbind(dailyT, coldOTHER, hotOTHER,coldELEC,hotELEC)) 

# plot
min = 0
max = 4000
rc = ggplot(EJdf) + geom_line(aes(y=coldOTHER, x=dailyT), color= bu, size=1) +
  geom_line(aes(y=coldELEC,x=dailyT), color=rd, size=1)+ ylim(min,max) + xlab(expression(paste("Daily temperature (",degree,"C)")))+ 
  annotate(geom="text", x=40, y=1800, label="Electricity",color=rd,size=3) + annotate(geom="text", x=40, y=1625, label="Other fuels",color=bu,size=3)+
  theme_classic() + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) + ylab("EJ")
rh = ggplot(EJdf) + geom_line(aes(y=hotOTHER, x=dailyT), color= bu, size=1) +
  geom_line(aes(y=hotELEC,x=dailyT), color=rd, size=1)+ ylim(min,max) + xlab(expression(paste("Daily temperature (",degree,"C)")))+ 
  annotate(geom="text", x=40, y=1800, label="Electricity",color=rd,size=3) + annotate(geom="text", x=40, y=1625, label="Other fuels",color=bu,size=3)+
  theme_classic() + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) + ylab("EJ")

############################################
# 3. CO2 responses
############################################
min = 0
max = 2000
fctCANOTHER = 0.5092992
fctCANELEC = 0.1529889
fctSWEOTHER = .2762191
fctSWEELEC = .0143556	
fctINDOTHER = 1.387864
fctINDELEC = 0.7831666
fctBRAOTHER = 0.6156878
fctBRAELEC = 0.1164444	
EJdf = EJdf %>% mutate(CANCO2 = coldOTHER*fctCANOTHER + coldELEC*fctCANELEC) %>%
  mutate(INDCO2 = hotOTHER*fctINDOTHER + hotELEC*fctINDELEC) %>% 
  mutate(SWECO2 = coldOTHER*fctSWEOTHER + coldELEC*fctSWEELEC) %>%
  mutate(BRACO2 = hotOTHER*fctBRAOTHER + hotELEC*fctBRAELEC)

purp = brewer.pal(n = 11, name = "Spectral")[11]
teal = brewer.pal(n = 11, name = "BrBG")[11]
ec = ggplot(EJdf) + geom_line(aes(y=CANCO2, x=dailyT), color= purp, size=1) +  geom_line(aes(y=SWECO2, x=dailyT), color=purp, alpha=.7, size=1, linetype="dotted") +
  ylim(min,max) + xlab(expression(paste("Daily temperature (",degree,"C)")))+ theme_classic() +
   theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) + ylab(expression(CO[2])) + 
  annotate(geom="text", x=40, y=1800, label="Canada",color=purp,size=3) + annotate(geom="text", x=40, y=1625, label="Sweden",color=purp,alpha=.7,size=3)
ec
eh = ggplot(EJdf) + geom_line(aes(y=INDCO2, x=dailyT), color= teal, size=1) + geom_line(aes(y=BRACO2, x=dailyT), color= teal, alpha=.7, size=1, linetype="dotted") +
  ylim(min,max) + xlab(expression(paste("Daily temperature (",degree,"C)")))+ theme_classic() +
   theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) + ylab(expression(CO[2])) + 
  annotate(geom="text", x=40, y=1800, label="India",color=teal,size=3) + annotate(geom="text", x=40, y=1625, label="Brazil",color=teal,alpha=.7,size=3)
eh

############################################
# 4. Global CAF and temp change
############################################

time = seq(2020,2100,1)
posCO2 = .01*(time-2020)^3
negCO2 = -.01*(time-2020)^3
dftime = data.frame(cbind(time,posCO2,negCO2))

panelc = ggplot(dftime) + geom_line(aes(x=time,y=posCO2), color=rd, size=1) +
  geom_line(aes(x=time,y=negCO2), color=bu, size=1) + 
  geom_hline(yintercept=0, color="grey",linetype="solid", size=1) +
  ylab(expression(paste("Global ",CO[2]))) + xlab("") +
  annotate(geom="text", x=2060, y=3500, label="Positive global CAF",color=rd,size=3) + 
  annotate(geom="text", x=2060, y=-3500, label="Negative global CAF",color=bu,alpha=1,size=3) +
  annotate(geom="text", x=2082, y=400, label="No adaptation",color="grey",alpha=1,size=3) +
  theme_classic() + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) 
panelc

dftime = dftime %>% mutate(temp=.01*time-2020) %>% mutate(tempPOS = temp+.0001*posCO2, tempNEG=temp+.0001*negCO2)

paneld = ggplot(dftime) + geom_line(aes(x=time,y=tempPOS), color=rd, size=1) +
  geom_line(aes(x=time,y=tempNEG), color=bu, size=1) + 
  geom_line(aes(x=time,y=temp),color="grey",size=1) +
  ylab(expression(paste("GMST (",degree,"C)"))) + xlab("") +
  annotate(geom="text", x=2060, y=-1998.8, label="Positive global CAF",color=rd,size=3) + 
  annotate(geom="text", x=2075, y=-1999.6, label="Negative global CAF",color=bu,alpha=1,size=3) +
  theme_classic()+
  theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) 
paneld

# plot grid so far
p = plot_grid(gc,gh,rc,rh,ec,eh,panelc,paneld,nrow=4,labels="auto")
p

# save
ggsave(file.path(wd, "figures", "CAF_components.pdf"), plot = p, width = 6, height = 9)

