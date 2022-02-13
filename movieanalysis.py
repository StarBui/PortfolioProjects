##  Movie Correlation Analysis 
# Data Source: https://www.kaggle.com/danielgrijalvas/movies/code?datasetId=2745&sortBy=voteCount

## Import libraries 
# Data Wrangling 
import numpy as numpy
import pandas as pd
import os

# Visualisationn libraries
import matplotlib.pyplot as plt
%matplotlib inline
import seaborn as sns

# Read data
df = pd.read_csv('/Users/taibui/code/MovieIndustry/movies.csv')
df.shape
df.head(5)


# Check for missing data
df.isnull().sum()

# Find top gross revenue movies
df.sort_values(by = ['gross'], inplace= False, ascending = False)

# Displays all rows in table 
pd.set_option('display.max_rows', None)

# Dropping any duplicates
df.drop_duplicates()
df['company'].drop_duplicates().sort_values(ascending=False)

# Budget Correlations
figure = plt.figure(figsize=(15,5))
plt.scatter(x=df['budget'], y=df['gross'])
plt.title('Budget Vs Gross Earnings')
plt.ylabel('Gross Earnings')
plt.xlabel('Film Budget')
plt.show()

# Plot budget vs gross using seaborn
sns.regplot(x='budget', y='gross',data = df, scatter_kws={'color':'red'},line_kws={'color':'blue'})

# Look at correlation between movie characteristics
correlation_matrix= df.corr(method='pearson')
sns.heatmap(correlation_matrix, annot=True)
plt.title('Correlation Matrix')
plt.ylabel('Movie Features')
plt.xlabel('Movie Features')
plt.show()

# Look at company
# For categorical data, change to numeric for analysis
df_num = df.copy()
for col in df_num.columns:
    if(df_num[col].dtype == 'object'):
        df_num[col] = df_num[col].astype('category')
        df_num[col] = df_num[col].cat.codes


# Look at correlation including categorical variables 
correlation_matrix= df_num.corr(method='pearson')
sns.heatmap(correlation_matrix, annot=True)
plt.title('Correlation Matrix')
plt.ylabel('Movie Features')
plt.xlabel('Movie Features')
plt.show()

# Easily indentify high correlation variables
df_num.corr().unstack().sort_values(ascending=False)
