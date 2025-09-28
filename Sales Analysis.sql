-- Import Data & Create Table
USE `analysis`;

CREATE TABLE sales_data (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    sku_id VARCHAR(50),
    sku_name VARCHAR(50),
    category VARCHAR(50),
    flavor VARCHAR(50),
    size VARCHAR(50),
    platform VARCHAR(50),
    Province VARCHAR(50),
    order_date DATE,
    year INT,
    month VARCHAR(20),
    quarter VARCHAR(10),
    quantity INT,
    price INT,
    discount DECIMAL(5,2),
    admin_marketplace DECIMAL(5,2),
    gross_revenue INT,
    net_revenue INT,
    COGS INT,
    gross_profit INT,
    payment_method VARCHAR(50),
    order_status VARCHAR(50),
    Semester VARCHAR(50),
    Region VARCHAR(50),
    month2 VARCHAR(50)
);


LOAD DATA INFILE 'C:/Users/waras/OneDrive/Documents/File/F93D3000.csv'
INTO TABLE sales_data
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
  (order_id, customer_id, sku_id, sku_name, category, flavor, size, platform, Province, order_date, year, month, quarter,
  quantity, price,discount, admin_marketplace, gross_revenue, net_revenue, cogs, gross_profit, payment_method, order_status, Semester, Region, month2);
  
-- Analysis Data --
-- 1 Sales & Revenue --
-- Quarterly Revenue (Completed Order)
select quarter, 
  ifnull(sum(case when year(order_date) = 2024 then net_revenue end),0) as revenue_2024, 
  ifnull(sum(case when year(order_date) = 2025 then net_revenue end),0) as revenue_2025,
  ifnull(concat(round(((sum(case when year(order_date) = 2025 then net_revenue end) - 
  sum(case when year(order_date) = 2024 then net_revenue end)) / 
  sum(case when year(order_date) = 2024 then net_revenue end)) *100),'%'),0) as growth
  from sales_data
  where order_status = 'completed'
  group by quarter
  order by quarter
  
  -- Monthly Revenue
select month(order_date) as Month, 
  ifnull(sum(case when year(order_date) = 2024 then net_revenue end),0) as revenue_2024,
  ifnull(sum(case when year(order_date) = 2025 then net_revenue end),0) as revenue_2025,
 ifnull(concat(round(((sum(case when year(order_date) = 2025 then net_revenue end) - 
  sum(case when year(order_date) = 2024 then net_revenue end)) / 
  sum(case when year(order_date) = 2024 then net_revenue end))*100),'%'),0) as growth
  from sales_data
  where order_status = 'Completed'
  group by month(order_date)
  order by month(order_date)
  
  -- Transactions by Payment Method
select Semester, payment_method,
  count(case when year(order_date) = 2024 then order_id end) as transaction_2024,
  count(case when year(order_date) = 2025 then order_id end) as transaction_2025
from sales_data
where order_status = 'Completed'
group by Semester, payment_method
order by Semester

-- Transactions by Order Status
select order_status, count(order_id) as transactions, count(distinct customer_id) as customer
from sales_data
where year(order_date) = 2024
group by order_status

-- Transactions by Discount
select discount, count(order_id) as transactions, 
  sum(quantity) as quantity_sold, 
  sum(net_revenue) as revenue,
  sum(gross_profit) as profit
from sales_data
where order_status = 'Completed'and year(order_date) = 2024
group by discount

-- 2 Product Performance --
-- Quarterly Revenue by Category
select quarter, 
  sum(case when category = 'Snack' then net_revenue end) as snack,
  sum(case when category = 'Beverage' then net_revenue end) as beverage
from sales_data
where order_status = 'Completed' and year(order_date) = 2024
group by quarter
order by quarter

-- Revenue Over Time by Category Product
select month(order_date) as number, month, 
  sum(case when category = 'Snack' then net_revenue end) as snack,
  sum(case when category = 'Beverage' then net_revenue end) as beverage
from sales_data
where order_status = 'Completed' and year(order_date) = 2024
group by month(order_date), month
order by month(order_date)

-- Quantity Sold by Product Name
select sku_name, sum(quantity) as quantity_sold
from sales_data
where order_status = 'Completed' and year(order_date) = 2024
group by sku_name

-- Quantity Sold by Snack Size
select size, sum(quantity)
from sales_data
where order_status = 'Completed' and year(order_date) = 2024 and category= 'Snack'
group by size

-- Quantity Sold by Drink Size
select size, sum(quantity)
from sales_data
where order_status = 'Completed' and year(order_date) = 2024 and category= 'Drink'
group by size

-- Top 5 Snack Quantity Sold 2024
select sku_id, sku_name, flavor, size, sum(quantity) as quantity, sum(net_revenue) as revenue
from sales_data
where order_status = 'Completed' and category = 'Snack' and year(order_date) = 2024
group by sku_id, sku_name, flavor, size
order by sum(quantity) desc
limit 5

-- Top 5 Drink Quantity Sold 2024
select sku_id, sku_name, flavor, size, sum(quantity) as quantity, sum(net_revenue) as revenue
from sales_data
where order_status = 'Completed' and category = 'Beverage' and year(order_date) = 2024
group by sku_id, sku_name, flavor, size
order by sum(quantity) desc
limit 5

-- 3 Platform Performance --
-- Quarterly Revenue by Platform
select quarter, 
  sum(case when platform = 'Shopee' then net_revenue end) as Shopee,
  sum(case when platform = 'TiktokShop' then net_revenue end) as TiktokShop,
  sum(case when platform = 'Tokopedia' then net_revenue end) as Tokopedia,
  sum(case when platform = 'Lazada' then net_revenue end) as Lazada
from sales_data
where order_status = 'Completed' and year(order_date) = 2024
group by quarter
  order by quarter
  
  -- Monthly Revenue by Platform
select month(order_date) as number, month, 
  sum(case when platform = 'Shopee' then net_revenue end) as Shopee,
  sum(case when platform = 'TiktokShop' then net_revenue end) as TiktokShop,
  sum(case when platform = 'Tokopedia' then net_revenue end) as Tokopedia,
  sum(case when platform = 'Lazada' then net_revenue end) as Lazada
from sales_data
where order_status = 'Completed' and year(order_date) = 2024
group by month(order_date), month
order by month(order_date)

-- Quantity Sold by Platform & Product Category
select platform, 
  sum(case when category = 'Snack' then quantity end) as Snack, 
  sum(case when category = 'Beverage' then quantity end) as Beverage
from sales_data
where order_status = 'Completed' and year(order_date) = 2024
group by platform

-- Transactions by Platform
select platform, count(order_id) as transactions 
from sales_data
where order_status = 'Completed' and year(order_date) = 2024
group by platform

-- Contribution Platform to revenue
select platform, 
  sum(net_revenue) as revenue, 
  concat(round(sum(net_revenue) / sum(sum(net_revenue)) over () * 100,2),'%') as contribution
from sales_data
where order_status = 'Completed' and year(order_date) = 2024
group by platform

-- Best - Selling Item by Platform (2024)
select t.platform, 
  t.sku_name, 
  t.qty_sold
  from (select platform, 
  sku_name, 
  sum(quantity) as qty_sold, 
  rank() over (partition by platform order by sum(quantity) desc) as rnk 
  from sales_data
  where order_status = 'Completed' and year(order_date) = 2024
  group by platform, sku_name) as t
  where t.rnk =1
  order by t.platform desc;
  
  -- 4 Regional Analysis --
-- Revenue by Province
select Province, sum(net_revenue) as revenue, 
  concat(round(sum(net_revenue) / sum(sum(net_revenue)) over () *100,2),'%') as contribution
from sales_data
where order_status = 'Completed' and year(order_date) = 2024
group by Province
order by contribution desc

-- Monthly Revenue by Region
select month(order_date) as number, monthname(order_date) as month,
  sum(case when Region = 'Bali' then net_revenue end) as Bali,
  sum(case when Region = 'Java' then net_revenue end) as Java,
  sum(case when Region = 'Kalimantan' then net_revenue end) as Kalimantan,
  sum(case when Region = 'Maluku' then net_revenue end) as Maluku,
  sum(case when Region = 'Nusa Tenggara' then net_revenue end) as Nusa_Tenggara,
  sum(case when Region = 'Papua' then net_revenue end) as Papua,
  sum(case when Region = 'Sulawesi' then net_revenue end) as Sulawesi,
  sum(case when Region = 'Sumatera' then net_revenue end) as Sumatera
from sales_data
where order_status = 'Completed' and year(order_date) = 2024
group by month(order_date), monthname(order_date)
order by month(order_date)

-- Revenue & Contribution by Region
select Region, sum(net_revenue), 
  round(sum(net_revenue) / sum(sum(net_revenue)) over () *100,2) as contribution_pct
from sales_data
where order_status = 'Completed' and year(order_date) = 2024
group by Region
order by contribution_pct desc

-- Best - Selling Item by Region (2024)
select t.Region, t.sku_name, qty_sold
  from (select Region, sku_name, sum(quantity) as qty_sold, rank () over (partition by Region order by sum(quantity)desc ) as rnk
  from sales_data where order_status = 'Completed' and year(order_date) = 2024
  group by Region, sku_name) as t
  where t.rnk = 1
  group by t.Region, t.sku_name
  
  -- 5 Customer Analysis --
-- Total Customer 2024 & 2025
select month(order_date) as number, monthname(order_date) as month, 
  count(distinct case when year(order_date)=2024 then customer_id end ) as cust_2024,
  count(distinct case when year(order_date)=2025 then customer_id end ) as cust_2025
from sales_data
where order_status = 'Completed'
group by month(order_date), monthname(order_date)
order by number

-- Top 5 Spender in S1 2025
select customer_id, 
  count(order_id) as frequency, 
  sum(quantity) as qty_purchased, 
  sum(net_revenue) as purchased
from sales_data
where year(order_date) = 2025 and Semester = 'S1' and order_status = 'Completed'
group by customer_id
order by purchased desc
limit 5

-- Create Table RFM Analysis --
create table rfm_s22024 as
select customer_id, 
  max(order_date) as recent_order, 
  datediff('2025-01-01',max(order_date)) as recency,
  count(order_id) as frequency, 
  sum(net_revenue) as monetary,
  case when datediff('2025-01-01',max(order_date)) <=25 then 4
       when datediff('2025-01-01',max(order_date)) <=75 then 3
       when datediff('2025-01-01',max(order_date)) <=125 then 2
       else 1
  end as R_Score,
  case when count(order_id) <=4 then 1
       when count(order_id) <=8 then 2
       when count(order_id) <=12 then 3
       else 4
  end as F_Score,
  case when sum(net_revenue) <=60000 then 1
       when sum(net_revenue) <=360000 then 2
       when sum(net_revenue) <=660000 then 3
       else 4
  end as M_Score
from sales_data
where year(order_date) = 2024 and Semester = 'S2' and order_status = 'Completed'
group by customer_id

create table rfm_analysis2024 as
select r.customer_id, 
  r.R_Score, 
  r.F_Score, 
  r.M_Score, 
  ((r.R_Score*100) + (r.F_Score*10) + r.M_Score) as rfm_Score,
  s.segment,
case when r.R_Score = 4 then 'Most Active'
     when r.R_Score = 3 then 'Quite Active'
     when r.R_Score = 2 then 'Moderately inactive'
else 'Dormant' 
  end as RScore,
case when r.F_Score = 4 then 'Power Buyer'
     when r.F_Score = 3 then 'Frequent'
     when r.F_Score = 2 then 'Infrequent'
else 'Rare' 
  end as FScore,
case when r.M_Score = 4 then 'High Spender'
     when r.M_Score = 3 then 'Medium - High'
     when r.M_Score = 2 then 'Low Spender'
else 'Very Low Spender' 
  end as MScore
from rfm_s22024  as r join rfm_segments as s
on s.rfm_score = cast(((r.R_Score*100) + (r.F_Score*10) + r.M_Score)as char) collate utf8mb4_0900_ai_ci;

-- RFM Analysis H2 2024 
select segment, count(customer_id)
from rfm_analysis2024
group by segment
-- RScore
select RScore, count(customer_id)
from rfm_analysis2024
group by RScore
-- FScore
select FScore, count(customer_id)
from rfm_analysis2024
group by FScore
-- MScore
select MScore, count(customer_id)
from rfm_analysis2024
group by MScore
