#Note - at a 95% confidence level the critical value of W is 0.947
#For large datasets (such as what we're working with here), the Shapiro test will have trouble testing normality

library(rvest)
library(tidyquant)

get_stock_data <- function(stock_symbol) {

  # Yahoo Finance URL for the given stock symbol
  url <- paste0("https://finance.yahoo.com/quote/", stock_symbol)

  # Read HTML tables
  tables <- read_html(url) %>% html_table(fill = TRUE)

  # Extract summary data
  summary_table <- tables[[2]]

  return(summary = summary_table)
  }

df <- data.frame(Stock = character(), Return = numeric(), Stdev = numeric(), MktCap = numeric(), Beta = numeric(), Kurtosis = numeric(), Skew = numeric(), WShapiro = numeric(), pvalue = numeric())

add_stock_to_dataframe <- function(df, stock_symbol) {

  # Get stock data
  stock_data <- get_stock_data(stock_symbol)
  
  # Pull Market Capitalization from Yahoo using quantmod
  mktcap <- getQuote(stock_symbol, what = yahooQF(c("Market Capitalization")))[1,2]

  xtsTicker <- getSymbols(stock_symbol, auto.assign = FALSE)
  daily_returns <- dailyReturn(xtsTicker, type = "log")
  
  # Calculate Average Daily Return
  avg_returns <- mean(daily_returns)

  # Calculate Standard Deviation of Returns
  stdev <- sd(daily_returns, na.rm = FALSE)
  
  # Calculate the kurtosis of daily percent returns
  kurt <- kurtosis(daily_returns)
  
  # Calculate the skew of daily percent returns
  skew <- skewness(daily_returns)
  
  # Calculate the normality of daily percent returns
  shapiro_w <- shapiro.test(as.vector(daily_returns))[[1]]
  shapiro_p <- shapiro.test(as.vector(daily_returns))[[2]]

  # Extract Beta from the summary table
  beta <- as.numeric(gsub(",", "", stock_data[2,2]))

  # Add data to the existing dataframe
  df <- rbind(df, c(stock_symbol, avg_returns, stdev, mktcap, beta, kurt, skew, shapiro_w, shapiro_p))
  colnames(df) <- c("Stock", "Return", "Stdev", "MktCap", "Beta", "Kurtosis", "Skew", "WShapiro", "pvalue")
                 
  return(df)
}

stock_symbols <- c("AAPL", "MSFT", "GOOGL", "AMZN", "META")


API <- function(d_f, stock_symbols) {
  
  # Wipe dataframe on initiation
  d_f <- data.frame(Stock = character(), Return = numeric(), Stdev = numeric(), MktCap = numeric(), Beta = numeric(), Kurtosis = numeric(), Skew = numeric(), WShapiro = numeric(), pvalue = numeric())
  
  for (symbol in stock_symbols) {
  
    d_f <- add_stock_to_dataframe(d_f, symbol)
  
  }

  # Convert Beta and Kurtosis columns to numeric at the last iteration
  d_f <- cbind(d_f[1], lapply(d_f[2:9], as.numeric))
  
  #Round excess digits (Beta does not neet to be rounded)
  d_f$Return = lapply(d_f$Return, function(x) format(x, scientific = FALSE, digits = 2))
  d_f$Stdev = lapply(d_f$Stdev, function(x) round(x, 3))
  d_f$Kurtosis = lapply(d_f$Kurtosis, function(x) round(x, 2))
  d_f$Skew = lapply(d_f$Skew, function(x) round(x, 2))
  d_f$WShapiro = lapply(d_f$WShapiro, function(x) round(x, 4))
  d_f$pvalue = lapply(d_f$pvalue, function(x) format(x, scientific = TRUE, digits = 3))
  
  return(d_f)
}

df <- API(df, stock_symbols)
