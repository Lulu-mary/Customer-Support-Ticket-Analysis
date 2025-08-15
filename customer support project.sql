SELECT * FROM customer_support_tickets

-- NO OF ROWS
   SELECT COUNT(*) AS no_of_rows
   FROM customer_support_tickets;

-- NO OF COLUMNS
   SELECT COUNT(*) AS no_of_columns
   FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_NAME = 'customer_support_tickets';

-- THE DATA CONTAINS 8469 ROWS AND 17 COLUMNS

  /*   DATA CLEANING

   1. CHECKING FOR DUPLICATES
   2. HANDLING NULLS
   3. DELETIING UNWANTED COLUMNS  */

 ------- 1. CHECKING FOR DUPLICATES
   
   SELECT *
   FROM customer_support_tickets
   GROUP BY Ticket_ID, Customer_Name, Customer_Email, Customer_Age,
            Customer_Gender, Product_Purchased, Date_of_Purchase,
			Ticket_Type, Ticket_Subject, Ticket_Description,
			Ticket_Status, Resolution, Ticket_Priority,
			Ticket_Channel, First_Response_Time,
			Time_to_Resolution, Customer_Satisfaction_Rating
   HAVING COUNT(*) > 1
   --- There are no duplicates in the data

   ------- 2. HANDLING NULLS
   /* The columns that contain null values are; 
         Resolution, First_response_time, Time_to_resolution, Customer_satisfaction_rating */

	UPDATE customer_support_tickets
	SET Resolution = 'Not resolved'
	WHERE Resolution IS NULL;

	UPDATE customer_support_tickets
	SET Customer_Satisfaction_Rating = (SELECT AVG(Customer_Satisfaction_Rating)
	                                    FROM customer_support_tickets)
	WHERE Customer_Satisfaction_Rating IS NULL;

  ------- 3. DELETING UNWANTED COLUMNS

   ALTER TABLE customer_support_tickets
   DROP COLUMN Customer_Email;

   ALTER TABLE customer_support_tickets
   DROP COLUMN Ticket_Description;


   --- AFTER DATA CLEANING, THE DATA CONTAINS 8469 ROWS AND 15 COLUMNS


   ---------------------------------------------------------
   ------========= EXPLORATORY DATA ANALYSIS =========------

  -- 1. WHAT IS THE TOTAL NUMBER OF TICKETS SUBMITTED?

     SELECT COUNT(*) AS number_of_tickets
	 FROM customer_support_tickets;


  -- 2. WHAT IS THE NUMBER OF RESOLVED AND UNRESOLVED TICKETS?

     SELECT 'count' AS aggregation,
	         SUM(CASE WHEN Resolution = 'Not resolved' THEN 0 ELSE 1 END) AS resolved,
			 SUM(CASE WHEN Resolution = 'Not resolved' THEN 1 ELSE 0 END) AS unresolved
	 FROM customer_support_tickets;
	 

 -- 3. WHAT IS THE AVERAGE CUSTOMER SATISFACTION RATING?
     
	 SELECT ROUND(AVG(Customer_Satisfaction_Rating), 1) AS avg_customer_rating
	 FROM customer_support_tickets;
	 
	
 -- 4. WHAT IS THE AVERAGE RESOLUTION TIME?

	 SELECT CONVERT(TIME, 
	                DATEADD(SECOND,
	                        AVG(DATEDIFF(SECOND, Time_to_Resolution, First_Response_Time)), 0)) AS avg_resolution_time
	 FROM customer_support_tickets
	 WHERE Ticket_Status = 'Closed';


 -- 5. WHAT ARE THE MOST COMMON ISSUE TYPES REPORTED?

     SELECT Ticket_Type,
	        COUNT(*) AS number_of_tickets
	 FROM customer_support_tickets
	 GROUP BY Ticket_Type
     ORDER BY number_of_tickets DESC;


 -- 6. HOW MANY TICKETS WERE SUBMITTED THROUGH EACH CHANNEL?
     
	 SELECT Ticket_Channel,
	        COUNT(*) AS number_of_tickets
     FROM customer_support_tickets
	 GROUP BY Ticket_Channel
	 ORDER BY number_of_tickets DESC;

 -- 7. WHAT IS THE PERCENTAGE OF RESOLVED TICKETS PER-100 TICKETS FOR EACH TICKET PRIORITY?

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
	

 -- 8. FOR THE TOP 5 PRODUCTS WITH THE MOST TICKETS, WHAT WAS THE MOST COMMON ISSUE TYPE REPORTED FOR EACH?

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
	

 -- 9. CUSTOMER SEGMENTATION
     
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


 -- 10. GENDER DISTRIBUTION

     SELECT Customer_Gender,
	        COUNT(*) AS number_of_tickets,
			ROUND(CAST(COUNT(*) AS numeric)*100/(SELECT COUNT(*) FROM customer_support_tickets), 1) AS percent_of_total
	 FROM customer_support_tickets
	 GROUP BY Customer_Gender
	 ORDER BY number_of_tickets DESC;