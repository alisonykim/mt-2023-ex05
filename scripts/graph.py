#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# graph.py

"""
Visualize impact of beam size on BLEU scores and time taken for translation
Program call:
    python3 scripts/graph.py
"""


import seaborn as sns
import os
import pandas as pd
import matplotlib.pyplot as plt


logs_dir = 'translations/logs'


def extract_data(logfile):
    '''
    Get bleu scores and time from log files
    :return: Tuple with bleu score and time
    '''
    with open(logfile, 'r', encoding='utf-8') as f:
        data = [line.strip() for line in f]
        bleu = data[2]
        bleu_score = bleu.split()[-1]
        bleu_score = float(bleu_score.rstrip(','))
        time = data[-1]
        time = int(time.split()[-1])
    return (bleu_score, time)


log_data = {'beam_size': [], 'bleu': [], 'time': []}

# iterate over log files and extract data
for filename in os.listdir(logs_dir):
    f = os.path.join(logs_dir, filename)
    beam_size = int(filename.split('.')[-2])
    log_data['beam_size'].append(beam_size)
    if os.path.isfile(f):
        bleu, time = extract_data(f)
        log_data['bleu'].append(bleu)
        log_data['time'].append(time)


df = pd.DataFrame(data=log_data)
# sort by beam size
#sorted_df = df.sort_values(by='beam_size')

# plot bleu scores wrt beam size
bleu_plot = sns.lineplot(data=df, x="beam_size", y="bleu")
bleu_plot.set(xlabel='Beam Size', ylabel='BLEU Score')
bleu_plot.set_title('Impact of Beam Size on BLEU Scores')
plt.show()

# plot time wrt beam size
time_plot = sns.lineplot(data=df, x="beam_size", y="time")
time_plot.set(xlabel='Beam Size', ylabel='Time (seconds)')
time_plot.set_title('Impact of Beam Size on Time')
plt.show()

# save graphs
plot_path = 'translations/graphs'
if not os.path.exists(plot_path):
    os.makedirs(plot_path)
bleu_plot.figure.savefig(plot_path+'/'+'bleu_graph.png')
time_plot.figure.savefig(plot_path+'/'+'time_graph.png')