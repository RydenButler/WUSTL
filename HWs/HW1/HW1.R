setwd("~/Documents/GitHub/WUSTL")
Data <- read.csv('HW1.csv')

# Store separate data for each speaker
Lehrer <- Data[which(Data$Speaker == 'lehrer'), ]
Obama <- Data[which(Data$Speaker == 'obama'), ]
Romney <- Data[which(Data$Speaker == 'romney'), ]

# Empty plot
plot(x = 1, type='n', xlim = c(-50, 50), ylim = c(0, max(Data$Number)),
     xlab = 'Negative Words                     Positive Words \nWord Tone', 
     ylab = "Statement #", axes=F)
# Add axes
axis(2, at = seq(0,max(Data$Number),20), labels = rev(seq(0,max(Data$Number),20)), las = 2)
axis(3, at = seq(-50,50,10), labels = c(rev(seq(0,50,10)), seq(10,50,10)))
axis(1, at = seq(-50,50,10), labels = c(rev(seq(0,50,10)), seq(10,50,10)))
abline(v=0, lty = 2, lwd = 3)
# plot positive rates over time
lines(y = Obama$Number, x = rev(Obama$Positive)+0.5, type = 'l', col = 'blue')
lines(y = Romney$Number, x = rev(Romney$Positive)+0.5, type = 'l', col = 'red')
lines(y = Lehrer$Number, x = rev(Lehrer$Positive)+0.5, type = 'l', col = 'green')
# plot negative rates over time
lines(y = Obama$Number, x = rev(Obama$Negative)*(-1)-0.5, type = 'l', col = 'blue')
lines(y = Romney$Number, x = rev(Romney$Negative)*(-1)-0.5, type = 'l', col = 'red')
lines(y = Lehrer$Number, x = rev(Lehrer$Negative)*(-1)-0.5, type = 'l', col = 'green')
# add legend
legend("topleft", 
       legend = c('Obama', 'Romney', 'Lehrer'), 
       col = c('blue', 'red', 'green'),
       lty = 1,
       bty = 'n',
       cex = 0.5)


# In general, the trends demonstrate an overall greater use of positive words 
#   than negative ones. There is also a clear tendency for Obama to use more 
#   positive words than Romney in temporally proximate statements. Lehrer's 
#   statements remains generally lacking in either positive or negative word use
#   though their are notable exceptions at the opening remarks (many positive 
#   words) and around statement number 100 (having both more negative and 
#   positive) words than Lehrer's average. There is no clear evidence of
#   candidate tone changing in response to the other's remarks. Instead it
#   appears that temporally proximate statements (made in regard to a similar 
#   topic) are most closely related to the measured tone.