
cols = c("id","date","sc","pa_n","pa_s","quality","pa_fit",
	"fp_heeq_speed","fp_heeq_long","fp_carr_long","fp_heeq_lat","fp_launch",
	"sse_heeq_speed","sse_heeq_long","sse_carr_long","sse_heeq_lat","sse_launch",
	"hm_heeq_speed","hm_heeq_long","hm_carr_long","hm_heeq_lat","hm_launch"
	)

d = read.table("HCME_WP3_V02.txt",
		sep = "\t",
		col.names = cols,
		fill = FALSE,
		strip.white = TRUE
		)

