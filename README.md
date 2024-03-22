# Portfolio
Projects of Personal and Professional Interest


This file uses the rvest and tidyquant packages to pull financial data covering several SP500 companies from the web and create a dataframe containing this data in R. After importing the data is used to evaluate the kurtosis (how big the tails of the distribution are), skew (if the dataset leans away from the mean), and normality of the logarithmic returns on each stock.

The motivating hypothesis which required this data was that there should be a negative relationship between the kurtosis of the log returns and the beta of said returns. A low kurtosis implies the data is spread further from the mean, and beta is a measure of how reactive the stock is to the rest of the market. While the existence of this relationship would have limited practical application, I was curious to see if my hunch was correct. This hypothesis will be explored in another block.
