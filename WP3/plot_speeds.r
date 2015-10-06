# Read in the WP3 CSV file
wp3 <- read.csv("HCME_WP3_V02.csv")

# Print the number of rows and variables, and names of the variables
dim(wp3)
names(wp3)

names(wp3) <- c("ID",
		"Date",
		"Spacecraft",
		"LN",
		"PA_N",
		"LS",
		"PA_S",
		"Quality",
		"PA_Fit",
		"FP_Speed",
		"FP_SpeedErr",
		"FP_Phi",
		"FP_PhiErr",
		"FP_HEEQLon",
		"FP_HEEQLat",
		"FP_CarrLon",
		"FP_LaunchUTC",
		"SSE_Speed",
                "SSE_Speed Err",
                "SSE_Phi",
                "SSE_PhiErr",
                "SSE_HEEQLon",
                "SSE_HEEQLat",
                "SSE_CarrLon",
                "SSE_LaunchUTC",
		"HM_Speed",
                "HM_Speed Err",
                "HM_Phi",
                "HM_PhiErr",
                "HM_HEEQLon",
                "HM_HEEQLat",
                "HM_CarrLon",
                "HM_LaunchUTC")


# Simple plots

#dev.copy("CME_speeds.png",width=8,height=8,unit="in",res=300)
pdf("CME_Speeds_FP_SSE.pdf",width=8,height=3)
par(mfrow=c(1,3),pty="s")
plot(wp3$FP_Speed, wp3$SSE_Speed, 
	xlab="FP Speed (km/s)", ylab="SSE Speed (km/s)",#main="WP3 CME Speeds",
	xlim=c(0,3000), ylim=c(0,3000),
	pch=3)
abline(0,1,col="black",lty=5)
reg <- lm(wp3$SSE_Speed~wp3$FP_Speed)
abline(reg,col="red")
legend("bottomright",c(paste("y =",signif(reg$coefficients[[2]],digits=2),"x +",round(reg$coefficients[[1]])),"y = x"),lty=c(1,5),col=c("red","black"),bty="n",cex=0.8)

plot(wp3$FP_Speed, wp3$HM_Speed,
        xlab="FP Speed (km/s)", ylab="HM Speed (km/s)",main="WP3 CME Speeds",
        xlim=c(0,5000), ylim=c(0,5000),
        pch=3)
abline(0,1,col="black",lty=5)
reg <- lm(wp3$HM_Speed~wp3$FP_Speed)
abline(reg,col="red")
legend("bottomright",c(paste("y =",signif(reg$coefficients[[2]],digits=2),"x +",round(reg$coefficients[[1]])),"y = x"),lty=c(1,5),col=c("red","black"),bty="n",cex=0.8)

plot(wp3$HM_Speed, wp3$SSE_Speed,
        xlab="HM Speed (km/s)", ylab="SSE Speed (km/s)",#main="WP3 CME Speeds",
        xlim=c(0,5000), ylim=c(0,5000),
        pch=3)
abline(0,1,col="black",lty=5)
reg <- lm(wp3$SSE_Speed~wp3$HM_Speed)
abline(reg,col="red")
legend("bottomright",c(paste("y =",signif(reg$coefficients[[2]],digits=2),"x +",round(reg$coefficients[[1]])),"y = x"),lty=c(1,5),col=c("red","black"),bty="n",cex=0.8)


dev.off()


