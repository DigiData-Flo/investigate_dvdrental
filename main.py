import numpy as np
import pandas as pd
from matplotlib import pyplot as plt

df_11 = pd.read_csv('question1-1.csv')
df_112 = pd.read_csv('question1-12.csv')
df_12 = pd.read_csv('question1-2.csv')
df_13 = pd.read_csv('question1-3.csv')
df_21 = pd.read_csv('question2-1.csv')
df_22 = pd.read_csv('question2-2.csv')
df_23 = pd.read_csv('question2-3.csv')

plt.style.use('seaborn')

'''Question 1'''
title = df_11.iloc[0:10]['title']
rental_count = df_11.iloc[0:10]['count']

fig1, ax1 = plt.subplots()


ax1.bar(title, rental_count, color='#da4fa4')
ax1.set_title('Popular Family Films')
ax1.set_xlabel('Films')
ax1.set_ylabel('Rental Counts')
ax1.set_xticklabels(title, rotation=90)

'''Question 2'''
rental_duration = df_112.iloc[0:10]['rental_duration']
rental_count = df_112.iloc[0:10]['rental_count']

fig2, ax2 = plt.subplots()

film = df_112.iloc[0:10]['title']

ind = np.arange(10)
width = 0.3

ax2.bar(ind-width/2, rental_duration, width, color='#da4fa4', label='Rental Duration [days over all rentals]')
ax2.bar(ind+width/2, rental_count, width, color='#d3c43d', label='Rental Count over all')

ax2.set_title('Popular Family Films')
ax2.set_xlabel('Films')
ax2.set_ylabel('Score')
ax2.set_xticks(ind)
ax2.set_xticklabels(film, rotation=90)
ax2.legend()


categories = df_13['category'].unique()

shift = -.35
colors = ['#ffd700', '#420dab', '#d9c1c0', '#bd2f2f', '#22432a', '#8b5f65']
fig3, ax3 = plt.subplots()

for i, category in enumerate(categories):

    filt = df_13['category'] == category

    df_13_category = df_13[filt]
    quartile = df_13_category['standard_quartile']

    count = df_13_category['count_quartile']
    width = 0.1
    shift = shift + width
    print(shift)
    ax3.bar(quartile + shift, count, width, color=colors[i], label=category)
    ax3.legend()

ax3.set_title('Quartile Count')
ax3.set_xlabel('Quartile')
ax3.set_ylabel('Quartile Count')
ax3.set_xticks(quartile)

plt.show()
