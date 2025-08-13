# Customer-Support-Ticket-Analysis
## 📝 Project Overview
This project explores the application of SQL to analyze customer support ticket data, aiming to identify common issues and their resolution methods. It demonstrates skills in **data cleaning, analysis, and insight generation.** 

## 📂 Dataset
The dataset was sourced from Kaggle, and it consists of customer inquiries like hardware issues, network bugs, etc, for various tech products. 
- **Source:** [Link to dataset](https://www.kaggle.com/datasets/suraj520/customer-support-ticket-dataset)
- **Rows:** 8469
- **Columns:** 17
- **Key Columns:** 'Ticket ID', 'Ticket Type', 'Ticket Status', 'Ticket Priority', 'Ticket Channel', 'Customer Gender'
- **Tool Used:** Microsoft SQL Server

## 🛠 Data Cleaning
- **Checking for Duplicates**
  ```sql
   SELECT *
   FROM customer_support_tickets
   GROUP BY Ticket_ID, Customer_Name, Customer_Email, Customer_Age, Customer_Gender, Product_Purchased, Date_of_Purchase, Ticket_Type, Ticket_Subject, Ticket_Description, Ticket_Status, Resolution, Ticket_Priority, Ticket_Channel, First_Response_Time, Time_to_Resolution, Customer_Satisfaction_Rating
   HAVING COUNT(*) > 1;
  ```
  Result: There were no duplicates in the dataset.

- **Handling Nulls:** The columns that contained null/missing values were 'Resolution', 'First_response_time', 'Time_to_resolution', and 'Customer_satisfaction_rating'. Nulls in the 'Resolution' column were replaced with **Not resolved**, while those of 'Customer_satisfaction_rating' were replaced with the **average customer satisfaction rating**. Nulls in the 'Resolution' and 'First_response_time' columns were left blank.
```sql
-- Resolution Column
UPDATE customer_support_tickets
SET Resolution = 'Not resolved'
WHERE Resolution IS NULL;

-- Customer_satisfaction_rating Column
UPDATE customer_support_tickets
SET Customer_Satisfaction_Rating = (SELECT AVG(Customer_Satisfaction_Rating)
                                    FROM customer_support_tickets)
WHERE Customer_Satisfaction_Rating IS NULL;
```
- **Deleting Unwanted Columns:** The 'Customer_Email' and 'Ticket_Description' columns were deleted because they were not needed for the analysis.
```sql
-- Customer_Email Column
ALTER TABLE customer_support_tickets
DROP COLUMN Customer_Email;

-- Ticket_Description Column
ALTER TABLE customer_support_tickets
DROP COLUMN Ticket_Description;
```
## 💻 Exploratory Data Analysis
### 1️⃣ What is the total number of tickets submitted?
```sql
SELECT COUNT(*) AS number_of_tickets
FROM customer_support_tickets;
```
| number_of_tickets |
| ----------------- |
| 8469              |
### 2️⃣ What is the number of resolved and unresolved tickets?
```sql
SELECT 'count' AS aggregation,
       SUM(CASE WHEN Resolution = 'Not resolved' THEN 0 ELSE 1 END) AS resolved,
			 SUM(CASE WHEN Resolution = 'Not resolved' THEN 1 ELSE 0 END) AS unresolved
FROM customer_support_tickets;
```
| aggregation 	| resolved 	| unresolved 	|
|-------------	|----------	|------------	|
| count       	| 2769     	| 5700       	|
### 3️⃣ What is the average customer satisfaction rating?
```sql
SELECT ROUND(AVG(Customer_Satisfaction_Rating), 1) AS avg_customer_rating
FROM customer_support_tickets;
```
| avg_customer_rating |
| ------------------- |
| 3.0                 |
### 4️⃣ What is the average resolution time?
```sql

```
