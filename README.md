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
After data cleaning, the data contained 8469 rows and 15 columns.
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
SELECT CONVERT(TIME, 
               DATEADD(SECOND,
                       AVG(DATEDIFF(SECOND, Time_to_Resolution, First_Response_Time)), 0)) AS avg_resolution_time
FROM customer_support_tickets
WHERE Ticket_Status = 'Closed';
```
| avg_resolution_time |
| ------------------- |
| 00:03:27            |
### 5️⃣ What are the most common issue types reported?
```sql
SELECT Ticket_Type,
       COUNT(*) AS Number_of_tickets
FROM customer_support_tickets
GROUP BY Ticket_Type
ORDER BY Number_of_tickets DESC;
```
| Ticket_Type            |  Number_of_tickets |
| ---------------------- |  ----------------- |
| Refund request         |  1752              |
| Technical issue        |  1747              |
| Cancellation request   |  1695              |
| Product inquiry        |  1641              |
| Billing inquiry        |  1634              |
### 6️⃣ How many tickets were submitted through each channel?
```sql
SELECT Ticket_Channel,
       COUNT(*) AS Number_of_tickets
FROM customer_support_tickets
GROUP BY Ticket_Channel
ORDER BY Number_of_tickets DESC;
```
| Ticket_Channel    | Number_of_tickets |
| ----------------- | ----------------- |
| Email             | 2143              |
| Phone             | 2132              |
| Social media      | 2121              |
| Chat              | 2073              |
### 7️⃣ What is the percentage of resolved tickets per 100 tickets for each ticket priority?
```sql
SELECT *,
       ROUND((CAST(resolved_tickets AS numeric)/number_of_tickets)*100, 2) AS resolved_per_100
FROM 
   (
    SELECT Ticket_Priority,
           COUNT(*) AS number_of_tickets,
           SUM(CASE WHEN Resolution = 'Not Resolved' THEN 0 ELSE 1 END) AS resolved_tickets
    FROM customer_support_tickets
    GROUP BY Ticket_Priority
    ) AS sub
ORDER BY resolved_per_100 DESC;
```
| Ticket_Priority  | number_of_tickets | resolved_tickets | resolved_per_100 |
| ---------------- | ----------------- | ---------------- | ---------------- |
| Critical         | 2129              | 726              | 34.10            |
| High             | 2085              | 705              | 33.81            |
| Medium           | 2192              | 694              | 31.66            |
| Low              | 2063              | 644              | 31.22            |
### 8️⃣ For the top 5 products with the most tickets, what was the most common issue type reported for each?
```sql
WITH top_5_products AS (
        SELECT TOP(5) Product_Purchased,
	           COUNT(*) AS number_of_tickets
	    FROM customer_support_tickets
	    GROUP BY Product_Purchased
	    ORDER BY number_of_tickets DESC
	),

ticket_type_rank AS ( 
	    SELECT Product_Purchased,
	           Ticket_Type,
	           COUNT(*) AS ticket_type_count,
		       RANK() OVER(PARTITION BY Product_Purchased
		                   ORDER BY COUNT(*) DESC) AS row_rank 	   
	    FROM customer_support_tickets
	    GROUP BY Product_Purchased, Ticket_Type
	)

	    SELECT a.Product_Purchased, a.number_of_tickets,
	           b.Ticket_Type, b.ticket_type_count
	    FROM top_5_products AS a
	    JOIN ticket_type_rank AS b 
	    ON a.Product_Purchased = b.Product_Purchased
	    WHERE b.row_rank = 1 
	    ORDER BY a.number_of_tickets DESC;
```
| Product_Purchased    | number_of_tickets | Ticket_Type          | ticket_type_count |
| -------------------- | ----------------- | -------------------- | ----------------- |
| Canon EOS            | 240               | Product inquiry      | 52                |
| GoPro Hero           | 228               | Technical issue      | 57                |
| Nest Thermostat      | 225               | Product inquiry      | 50                |
| Amazon Echo          | 221               | Refund request       | 51                |
| Philips Hue Lights   | 221               | Cancellation request | 49                |
### 9️⃣ Customer segmentation by age
```sql
WITH Customers_Segment AS (
	    SELECT CASE WHEN Customer_Age BETWEEN 18 AND 25 THEN '18-25'
	                WHEN Customer_Age BETWEEN 26 AND 35 THEN '26-35'
				    WHEN Customer_Age BETWEEN 36 AND 45 THEN '36-45'
				    WHEN Customer_Age BETWEEN 46 AND 55 THEN '46-55'
				    WHEN Customer_Age BETWEEN 56 AND 65 THEN '56-65'
				   ELSE 'Over 65' END AS customer_segment,
			    COUNT(*) AS tickets_count
	    FROM customer_support_tickets
	    GROUP BY Customer_Age
	)
		
		SELECT customer_segment, 
	           SUM(tickets_count) AS number_of_tickets,
			   ROUND(SUM(tickets_count)*100 / (SELECT CAST(SUM(tickets_count) AS numeric) 
			                         FROM Customers_Segment), 1) AS percent_of_total
	    FROM Customers_Segment
	    GROUP BY customer_segment;
```
| customer_segment | number_of_tickets | percent_of_total |
| ---------------- | ----------------- | ---------------- |
| 18-25            | 1285              | 15.2             |
| 26-35            | 1594              | 18.8             |
| 36-45            | 1561              | 18.4             |
| 46-55            | 1633              | 19.3             |
| 56-65            | 1619              | 19.1             |
| Over 65          | 777               | 9.2              |
### 🔟 Ticket submission by gender
```sql
 SELECT Customer_Gender,
        COUNT(*) AS number_of_tickets,
        ROUND(CAST(COUNT(*) AS numeric)*100/(SELECT COUNT(*) FROM customer_support_tickets), 1) AS percent_of_total
FROM customer_support_tickets
GROUP BY Customer_Gender
ORDER BY number_of_tickets DESC;
```
| Customer_Gender | number_of_tickets | percent_of_total |
| --------------- | ----------------- | ---------------- |
| Male            | 2896              | 34.2             |
| Female          | 2887              | 34.1             |
| Other           | 2686              | 31.7             |
