#!/usr/bin/env python

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import config

from read_cdaw import cdaw
from savefig import save

# Convert strings to numerics
# df = df.convert_objects(convert_numeric=True)
# Drop NaNs
# df.dropna(axis='rows',how='any',inplace=True)
cdaw.describe()
# Generate some initial plots for CDAW
cdaw.hist()
save(path=os.path.join(config.wp3_path,"cdaw_cme_catalog/cdaw_hist"),verbose=True)
#plt.show()



# Read in the WP3 catalogue
wp3 = pd.read_csv(os.path.join(config.wp3_path,'HCME_WP3_V02.csv'))

wp3_speeds=wp3[['FP speed[kms-1]','SSE speed[kms-1]','HM speed[kms-1]']]
wp3_speeds.plot(kind='hist',stacked=True,bins=100)
save(path=os.path.join(config.wp3_path,"wp3_speeds_hist"),verbose=True)



