SELECT * FROM distribution_sales;

CREATE TABLE factories (
    division VARCHAR(50) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    factory VARCHAR(100) NOT NULL
);

SELECT * FROM factories;

SELECT 
    s."Order_ID",
    s."Order_Date",
	s."Ship_Date",
	s."Shipping_Days",
	s."Ship_Mode",
    s."Customer_ID",
    s."City",
    s."State/Province",
	s."Postal_Code",
    s."Division",
	s."Region",
    s."Product_Name",
    s."Sales",
    s."Units",
    s."Gross_Profit",
    s."Cost",
    f."factory"
FROM distribution_sales AS s
FULL JOIN factories AS f
    ON s."Product_Name" = f."product_name"
   AND s."Division" = f."division";

ALTER TABLE distribution_sales
ADD COLUMN "Shipping_Days" INTEGER;

UPDATE distribution_sales
SET "Shipping_Days" = "Ship_Date" - "Order_Date";

ALTER TABLE distribution_sales
ALTER COLUMN "Ship_Date" TYPE DATE
USING TO_DATE("Ship_Date", 'DD-MM-YYYY');


ALTER TABLE distribution_sales
ALTER COLUMN "Order_Date" TYPE DATE
USING TO_DATE("Order_Date", 'DD-MM-YYYY');










--• Which factory-to-customer routes are consistently efficient?

SELECT 
    f."factory",
    s."City",
    s."State/Province",
	COUNT(*) AS total_orders,
    ROUND(AVG(s."Ship_Date" - s."Order_Date")::NUMERIC,2) AS avg_shipping_days
FROM distribution_sales AS s
JOIN factories AS f
    ON s."Product_Name" = f."product_name"
   AND s."Division" = f."division"
GROUP BY f."factory", s."City", s."State/Province"
HAVING COUNT(*) >= 5
ORDER BY avg_shipping_days ASC;


--• Which routes experience frequent delays?

SELECT 
    f."factory",
    s."City",
    s."State/Province",
	COUNT(*) AS total_orders,
    ROUND(AVG(s."Ship_Date" - s."Order_Date")::NUMERIC,2) AS avg_shipping_days
FROM distribution_sales AS s
JOIN factories AS f
    ON s."Product_Name" = f."product_name"
   AND s."Division" = f."division"
GROUP BY f."factory", s."City", s."State/Province"
HAVING COUNT(*) >= 5
ORDER BY avg_shipping_days DESC;

--• How shipping performance varies by region, state, and ship mode?

SELECT 
    s."Region",
    s."State/Province",
    s."Ship_Mode",
    COUNT(*) AS total_orders,
    ROUND(AVG(s."Ship_Date" - s."Order_Date")::NUMERIC,2) AS avg_shipping_days
FROM distribution_sales AS s
GROUP BY s."Region", s."State/Province", s."Ship_Mode"
HAVING COUNT(*) >= 5
ORDER BY avg_shipping_days DESC;


--• Where operational bottlenecks exist geographically?

SELECT 
    s."Region",
    s."State/Province",
    COUNT(*) AS total_orders,
    ROUND(AVG(s."Ship_Date" - s."Order_Date")::NUMERIC,2) AS avg_shipping_days,
    SUM(s."Cost") / NULLIF(SUM(s."Sales"), 0) AS cost_to_sales_ratio
FROM distribution_sales AS s
GROUP BY s."Region", s."State/Province"
HAVING COUNT(*) > 5
ORDER BY cost_to_sales_ratio DESC, avg_shipping_days DESC;


--Why logistics optimization remains reactive instead of data-driven?

SELECT 
    s."Product_Name",
    s."Division",
    COUNT(*) AS total_orders
FROM distribution_sales AS s
LEFT JOIN factories AS f
    ON s."Product_Name" = f."product_name"
   AND s."Division" = f."division"
WHERE f."factory" IS NULL
GROUP BY s."Product_Name", s."Division"
ORDER BY total_orders DESC;
















