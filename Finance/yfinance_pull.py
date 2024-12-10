import tkinter as tk
from tkinter import messagebox
from tkcalendar import Calendar
import yfinance as yf
import pandas as pd
from datetime import datetime

# Function to fetch the data and save it to CSV
def fetch_and_save_data():
    ticker_symbol = ticker_entry.get()  # Get the ticker symbol from the input box
    
    # Get the start and end date from the calendar widgets
    start_date = start_calendar.get_date()
    end_date = end_calendar.get_date()
    
    # Check if the ticker symbol is empty
    if not ticker_symbol:
        messagebox.showerror("Input Error", "Please enter a ticker symbol.")
        return
    
    # Check if the "Max Data" checkbox is selected
    use_max_data = max_data_var.get()
    
    try:
        # Get data on this ticker
        ticker_data = yf.Ticker(ticker_symbol)

        # If max data checkbox is checked, fetch all data; otherwise, fetch data within the date range
        if use_max_data:
            ticker_df = ticker_data.history(period='max')  # Fetch all available data
            file_name = f"{ticker_symbol}_historical_data_max.csv"
        else:
            # Convert calendar dates to proper format (string)
            start_date_str = datetime.strptime(start_date, '%m/%d/%Y').strftime('%Y-%m-%d')
            end_date_str = datetime.strptime(end_date, '%m/%d/%Y').strftime('%Y-%m-%d')

            # Fetch data between the selected date range
            ticker_df = ticker_data.history(start=start_date_str, end=end_date_str)
            file_name = f"{ticker_symbol}_historical_data_{start_date_str}_to_{end_date_str}.csv"

        # Save the DataFrame to a CSV file
        ticker_df.to_csv(file_name)

        # Notify the user that the file has been saved
        messagebox.showinfo("Success", f"Data saved as {file_name}")

    except Exception as e:
        # In case of error, show a message box
        messagebox.showerror("Error", f"Error fetching data for {ticker_symbol}: {str(e)}")


# Create the main application window
root = tk.Tk()
root.title("Yahoo Finance Data Fetcher")

# Create and place the label and entry box for the ticker symbol
ticker_label = tk.Label(root, text="Enter Ticker Symbol:")
ticker_label.pack(pady=10)

ticker_entry = tk.Entry(root)
ticker_entry.pack(pady=5)

# Create and place the label and calendar for the start date
start_label = tk.Label(root, text="Select Start Date:")
start_label.pack(pady=10)

start_calendar = Calendar(root, selectmode='day', date_pattern='mm/dd/y')
start_calendar.pack(pady=5)

# Create and place the label and calendar for the end date
end_label = tk.Label(root, text="Select End Date:")
end_label.pack(pady=10)

end_calendar = Calendar(root, selectmode='day', date_pattern='mm/dd/y')
end_calendar.pack(pady=5)

# Create and place the checkbox for using max data
max_data_var = tk.BooleanVar()  # Variable to store checkbox state
max_data_checkbox = tk.Checkbutton(root, text="Fetch Maximum Available Data", variable=max_data_var)
max_data_checkbox.pack(pady=10)

# Create and place the "Fetch Data" button
fetch_button = tk.Button(root, text="Fetch Data & Save to CSV", command=fetch_and_save_data)
fetch_button.pack(pady=20)

# Run the application
root.mainloop()
