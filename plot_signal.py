# #!/usr/bin/env python2

# from pylab import *
import serial
# import numpy as np

s = serial.Serial('/dev/ttyUSB0', 115200)

import matplotlib.pyplot as plt
import numpy as np
import time

fig = plt.figure()
ax = fig.add_subplot(111)

data = [500 for i in range(100)]
data[0] = 500
data[1] = 1000

# some X and Y data
x = np.arange(100)
y = data

li, = ax.plot(x, y)

# draw and show it
fig.canvas.draw()
plt.show(block=False)

# loop to update the data
while True:
    try:
        try:
            x = float(s.readline().strip())
        except ValueError:
            continue

        data.append(x)
        data = data[-100:]
        
        # set the new data
        li.set_ydata(data)

        # ax.relim()
        # ax.autoscale_view(True,True,True) 
        fig.canvas.draw()

        # time.sleep(0.001)
        plt.pause(0.0001)                       #add this it will be OK.
    except KeyboardInterrupt:
        break
