# WinCC-OA Control Extension
# Script that writes metric's data (delay, throughput, memory) into an output file

# date: 25/05/2020
# author: Nerea Luna Picón

from datetime import datetime, timedelta
import sys
import json
from statistics import mean
import time
import psutil as ps

# sudo yum install gcc python3-devel
# sudo pip3 install psutil

delays = []
#processes = []
#rams = []
start = None
end = None

# Method that calculates the time since each message arrives at WinCC-OA and the time the Kafka consumer receives that message
def calc_delay(start_string):
    end_time = datetime.now()
    # start_time = time from the message log
    start_time = start_string.replace('Z', '').replace('T', ' ')
    start_time = datetime.strptime(start_time,'%Y-%m-%d %H:%M:%S.%f')

    # Apply time correction for the different times in two machines
    start_time = start_time + timedelta(hours=2)
    #print("DELAY: ",start_time, end_time)
    delay = end_time - start_time
    # return time difference in milliseconds
    return delay.total_seconds() * 1000

# Getting memory of all processes
"""
def get_RAM():
    mysum = 0
    for process in processes:
        mysum+=process.memory_full_info().rss
    return mysum / 10 ** 9
"""

# Getting process ID
"""
for pid in ps.pids():
    try:
        process = ps.Process(pid)
        cmdline = "".join(process.cmdline())
        if 'vcsKafkaExport' in cmdline:
            print(process)
            print(cmdline)
            #processes.append(process)
    except:
        print("ERROR PID: %d" %(pid))
"""

# Method that writes memory information about the process in a file
# a+ --> opens a file for both appending and reading
with open('memory_ctrlext_test.csv', 'a+') as f1:
   for line in sys.stdin:
       f1.write('%f\n' % (ps.virtual_memory().used / 10 ** 9))
       #mem = process.memory_full_info().rss/ 10 ** 9 # memory is constant
       #print("MEMORY", mem)
       #myram = get_RAM()
       #rams.append(myram)
       #print(rams)
       if (len(delays) == 0):
           start = time.time()
           #print("START", datetime.now())
       if (len(delays) == int(sys.argv[1])):
           end = time.time()
           #print("END", datetime.now())
           break

       lines = json.loads(line)
       delay = calc_delay(lines['timestamp'])
       delays.append(delay)

# Method that writes information about the average delay and throughput in a file
# a+ --> opens a file for both appending and reading
with open('metrics_ctrlext.csv', 'a+') as f:
    avg_delay = mean(delays) # in ms
    throughput = len(delays) / (end-start) # messages per second
    f.write('%d, %f, %f\n' % (len(delays), avg_delay, throughput)) # write result to file
    print("AVG DELAY: %f ms" % (avg_delay))
    print("NUM ELEMENTS RECEIVED: ", len(delays))
    print("THROUGHPUT: %f messages/s" % (len(delays)/(end - start)))
    #print("MAXIMUM MEMORY" % max(rams))
