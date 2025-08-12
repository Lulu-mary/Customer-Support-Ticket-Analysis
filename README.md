# Customer-Support-Ticket-Analysis
## 📝 Project Overview
This project explores the use of SQL to analyze customer support ticket data to understand common issues and how they were resolved. It demonstrates skills in **data cleaning, analysis, and insight generation.** 

## 📂 Dataset
The dataset was sourced from Kaggle, and it consists of customer inquiries like hardware issues, network bugs, etc, for various tech products. 
- **Source:** [Link to dataset](https://www.kaggle.com/datasets/suraj520/customer-support-ticket-dataset)
- **Rows:** 8469
- **Columns:** 17
- **Key Columns:** 'Ticket ID', 'Ticket Type', 'Ticket Status', 'Ticket Priority', 'Ticket Channel', 'Customer Gender'
- **Data Format:** CSV → imported into Microsoft SQL Server

## Data Cleaning
- Checking for Duplicates
  ```sql
   SELECT *
   FROM customer_support_tickets
   GROUP BY Ticket_ID, Customer_Name, Customer_Email, Customer_Age, Customer_Gender, Product_Purchased, Date_of_Purchase, Ticket_Type, Ticket_Subject, Ticket_Description, Ticket_Status, Resolution, Ticket_Priority, Ticket_Channel, First_Response_Time, Time_to_Resolution, Customer_Satisfaction_Rating
   HAVING COUNT(*) > 1;
  ```
  Result: There were no duplicates in the dataset.

- Handling Nulls: The columns that contained null/missing values were 'Resolution', 'First_response_time', 'Time_to_resolution', and 'Customer_satisfaction_rating'. Nulls in the 'Resolution' column were replaced with **unresolved**, while those of 'Customer_satisfaction_rating' were replaced with the **average customer satisfaction rating**. Nulls in the 'Resolution' and 'First_response_time' columns were left blank.
