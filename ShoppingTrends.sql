SELECT 
    "Customer ID", 
    "Age", 
    "Gender", 
    "Item Purchased", 
    "Purchase Amount (USD)", 
    "Location", 
    "Review Rating", 
    "Subscription Status", 
    "Shipping Type", 
    "Discount Applied", 
    "Promo Code Used", 
    "Previous Purchases"
FROM 
    shopping
WHERE 
    "Purchase Amount (USD)" > 0;  


-- Remove duplicates
WITH CleanedData AS (
    SELECT DISTINCT 
        "Customer ID", 
        "Age", 
        "Gender", 
        "Item Purchased", 
        "Purchase Amount (USD)", 
        "Location", 
        "Review Rating", 
        "Subscription Status", 
        "Shipping Type", 
        "Discount Applied", 
        "Promo Code Used", 
        "Previous Purchases"
    FROM 
        shopping
    WHERE 
        "Purchase Amount (USD)" IS NOT NULL  
)

-- Handling Missing Values by applying default values for missing data
SELECT 
    "Customer ID", 
    COALESCE(Age, 30) AS Age,  
    COALESCE(Gender, 'Unknown') AS Gender,
    "Item Purchased", 
    "Purchase Amount (USD)", 
    COALESCE(Location, 'Unknown') AS Location, 
    COALESCE("Review Rating", 3.0) AS "Review Rating", 
    "Subscription Status", 
    "Shipping Type", 
    "Discount Applied", 
    "Promo Code Used", 
    COALESCE("Previous Purchases", 0) AS "Previous Purchases"  
FROM 
    CleanedData;

