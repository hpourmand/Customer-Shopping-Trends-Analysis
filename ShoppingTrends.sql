---View first few records for a general understanding
SELECT * FROM df1 LIMIT 10;



---Summary statistics for numerical columns
SELECT 
    COUNT(DISTINCT "Customer ID") AS unique_customers,
    MIN(Age) AS min_age,
    MAX(Age) AS max_age,
    AVG(Age) AS avg_age,
    MIN("Purchase Amount (USD)") AS min_purchase,
    MAX("Purchase Amount (USD)") AS max_purchase,
    AVG("Purchase Amount (USD)") AS avg_purchase,
    AVG("Review Rating") AS avg_review_rating,
    MIN("Previous Purchases") AS min_previous_purchases,
    MAX("Previous Purchases") AS max_previous_purchases
FROM df1;



---Count distinct values of categorical columns
SELECT
    COUNT(DISTINCT Gender) AS gender_categories,
    COUNT(DISTINCT "Item Purchased") AS unique_items,
    COUNT(DISTINCT Category) AS unique_categories,
    COUNT(DISTINCT Location) AS unique_locations,
    COUNT(DISTINCT Season) AS unique_seasons,
    COUNT(DISTINCT "Shipping Type") AS unique_shipping_types,
    COUNT(DISTINCT "Discount Applied") AS discount_types,
    COUNT(DISTINCT "Promo Code Used") AS promo_code_types,
    COUNT(DISTINCT "Payment Method") AS payment_methods,
    COUNT(DISTINCT "Frequency of Purchases") AS frequency_categories
FROM df1;




---Group by 'Gender' to see its distribution
SELECT Gender, COUNT(*) AS gender_count
FROM df1
GROUP BY Gender;



---Group by 'Category' to check the most popular item categories
SELECT Category, COUNT(*) AS purchase_count
FROM df1
GROUP BY Category
ORDER BY purchase_count DESC
LIMIT 10;



---Most common seasons for purchases
SELECT Season, COUNT(*) AS season_count
FROM df1
GROUP BY Season
ORDER BY season_count DESC;




---Segment customers by frequency of purchases
SELECT "Frequency of Purchases", COUNT(*) AS customer_count
FROM df1
GROUP BY "Frequency of Purchases"
ORDER BY customer_count DESC;




---High spenders: Customers whose purchase amount is greater than 75th percentile
WITH spend_quantiles AS (
    SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY "Purchase Amount (USD)") AS q3,
           PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY "Purchase Amount (USD)") AS q1
    FROM df1
)
SELECT "Customer ID", "Purchase Amount (USD)",
    CASE
        WHEN "Purchase Amount (USD)" >= (SELECT q3 FROM spend_quantiles) THEN 'High Spender'
        WHEN "Purchase Amount (USD)" < (SELECT q1 FROM spend_quantiles) THEN 'Low Spender'
        ELSE 'Medium Spender'
    END AS spend_category
FROM df1;




---Group customers into tiers based on previous purchases
SELECT "Customer ID", "Previous Purchases",
    CASE
        WHEN "Previous Purchases" = 0 THEN 'New Customer'
        WHEN "Previous Purchases" BETWEEN 1 AND 3 THEN 'Occasional Customer'
        WHEN "Previous Purchases" BETWEEN 4 AND 10 THEN 'Regular Customer'
        ELSE 'Loyal Customer'
    END AS customer_segment
FROM df1;




---Purchase amount analysis by subscription status, discount, and promo code
SELECT "Subscription Status", AVG("Purchase Amount (USD)") AS avg_purchase_amount
FROM df1
GROUP BY "Subscription Status";

SELECT "Discount Applied", AVG("Purchase Amount (USD)") AS avg_purchase_amount
FROM df1
GROUP BY "Discount Applied";

SELECT "Promo Code Used", AVG("Purchase Amount (USD)") AS avg_purchase_amount
FROM df1
GROUP BY "Promo Code Used";




---RFM Analysis (Recency, Frequency, and Monetary Value)
WITH customer_rfm AS (
    SELECT 
        "Customer ID",
        MAX("Purchase Date") AS last_purchase_date,
        COUNT(*) AS total_purchases,
        SUM("Purchase Amount (USD)") AS total_spend
    FROM df1
    GROUP BY "Customer ID"
),
rfm_scores AS (
    SELECT
        "Customer ID",
        NTILE(4) OVER (ORDER BY last_purchase_date DESC) AS recency_score,
        NTILE(4) OVER (ORDER BY total_purchases DESC) AS frequency_score,
        NTILE(4) OVER (ORDER BY total_spend DESC) AS monetary_score
    FROM customer_rfm
)
SELECT
    "Customer ID",
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS total_rfm_score,
    CASE
        WHEN (recency_score + frequency_score + monetary_score) <= 4 THEN 'Low Value'
        WHEN (recency_score + frequency_score + monetary_score) BETWEEN 5 AND 8 THEN 'Medium Value'
        ELSE 'High Value'
    END AS customer_segment
FROM rfm_scores
ORDER BY total_rfm_score DESC;




---Total spend and frequency of purchases by customer and payment method
WITH customer_payments AS (
    SELECT
        "Customer ID",
        "Payment Method",
        COUNT(*) AS total_purchases,
        SUM("Purchase Amount (USD)") AS total_spend,
        AVG("Purchase Amount (USD)") AS avg_purchase_value
    FROM df1
    GROUP BY "Customer ID", "Payment Method"
)
SELECT 
    "Customer ID",
    "Payment Method",
    total_purchases,
    total_spend,
    avg_purchase_value,
    CASE
        WHEN total_spend >= 1000 AND total_purchases >= 10 THEN 'High-Value Customer'
        ELSE 'Regular Customer'
    END AS customer_type
FROM customer_payments
WHERE total_spend >= 1000 AND total_purchases >= 10
ORDER BY total_spend DESC, total_purchases DESC;
