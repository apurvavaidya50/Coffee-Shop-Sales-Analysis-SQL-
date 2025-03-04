Create database coffee;

describe `coffee shop sales`;

Update `coffee shop sales`
SET transaction_date = str_to_date(transaction_date,'%m/%d/%Y');
set SQL_SAFE_UPdates = 0;

Alter table `coffee shop sales`
modify COLUMN transaction_date date;


set SQL_SAFE_UPdates = 0;
Update `coffee shop sales`
SET transaction_time= str_to_date(transaction_time,'%H:%i:%s');

Alter table `coffee shop sales`
modify COLUMN transaction_time time;

# Total Sales Analysis

# 1) Calculate the total sales for each respective month
# 2) Determine the month on month increase or decrease in sales
# 3) Calculate the difference in sales between the selected month and previous month

Select month(transaction_date) as Month, 
Round(sum(unit_price*transaction_qty),2) as Total_sales,
(Round(sum(unit_price*transaction_qty),2) - lag(Round(sum(unit_price*transaction_qty),2),1) over (order by  month(transaction_date))) as Month_sales_difference,
(Round(sum(unit_price*transaction_qty),2) - lag(Round(sum(unit_price*transaction_qty),2),1) over (order by  month(transaction_date)))/ lag(Round(sum(unit_price*transaction_qty),2),1) over (order by  month(transaction_date)) * 100 as MOM_Percentage 
from `coffee shop sales`
Where month(transaction_date) IN (1,2,3,4,5,6)
Group by month(transaction_date)
order by Month;

# Total Order Analysis
# Calucalte total number of orders for each respective month 
# Determine month on month increase or decrease in number of orders
# Calculate the difference in number of orders between the selected month and the previous month

Select month(transaction_date) as Month ,
count(﻿transaction_id) as Total_Orders,
(count(﻿transaction_id) - lag(count(﻿transaction_id),1) over (order by month(transaction_date))) as Orders_Month_Difference,
((count(﻿transaction_id) - lag(count(﻿transaction_id),1) over (order by month(transaction_date))) / lag(count(﻿transaction_id),1) over (order by month(transaction_date)) *100) as Order_Percentage
from `coffee shop sales`
Where month(transaction_date) IN (1,2,3,4,5,6)
Group by month(transaction_date)
Order by Month;

# Total Quantity Sold Analysis
# Calucalte total quantity sold for each respective month 
# Determine month on month increase or decrease in total quantity sold
# Calculate the difference in total quantity sold between the selected month and the previous month

Select month(transaction_date) as Month ,
sum(transaction_qty) as Total_Orders,
(sum(transaction_qty) - lag(sum(transaction_qty),1) over (order by month(transaction_date))) as Quantity_Month_Difference,
((sum(transaction_qty) - lag(sum(transaction_qty),1) over (order by month(transaction_date))) / lag(sum(transaction_qty),1) over (order by month(transaction_date)) *100) as Quantity_Percentage
from `coffee shop sales`
Where month(transaction_date) IN (1,2,3,4,5,6)
Group by month(transaction_date)
Order by Month;

# Calendar Heat Map
# Implement tooltip to display detailed metrics(sales, Orders, Quantity) when hovering over a specific day

Select transaction_date,
(concat(round(sum(transaction_qty * unit_price)/1000,1),'K')) as Total_sales,
(round(count(﻿transaction_id),1)) as Total_orders,
(concat(round(sum(transaction_qty)/1000,1),'K')) as Total_quantity
from `coffee shop sales`
Group by transaction_date;

#Sales analysis by weekdays and weekends
# Segment Sales Data into wekdays and weekends to analyse performance variation

Select 
CASE WHEN dayofweek(transaction_date) IN (1,7) then 'Weekends'
ELSE 'Weekdays'
END as Day_Type,
(concat(round(sum(transaction_qty * unit_price)/1000,1),'K')) as Total_sales
from `coffee shop sales`
where month(transaction_date) in (1,2,3,4,5,6)
Group by Day_Type;

# Sales analysis by store location
# Visualise sales data by different store locations.
# Include month over month difference metrics based on selected month in slicer
# Highlight MOM sales increase or decrease for each store location to identify trend

Select (concat(round(sum(transaction_qty * unit_price)/1000,1),'K')) as Total_sales, store_location 
from `coffee shop sales`
Where month(transaction_date) in (1,2,3,4,5,6)
Group by store_location 
Order by Total_sales DESC;

# Daily total sales , avg sales, and sales status for selected month

Select 
day_of_month,total_sales,
CASE
	WHEN total_sales > Avg_sales THEN 'ABOVE AVERAGE'
    WHEN total_sales < Avg_sales THEN 'BELOW AVERAGE'
    ELSE 'EQUAL TO AVERAGE'
END AS Sales_status
from (
	Select DAY(transaction_date) as day_of_month,
	Sum(unit_price*transaction_qty) as total_sales,
    AVG(Sum(unit_price*transaction_qty)) OVER() as Avg_sales
	from `coffee shop sales`
	where month(transaction_date) IN (2)
	Group by DAY(transaction_date)) AS Sales_data
	Order by day_of_month ;

# Sales by Product Category
Select product_category, sum(unit_price*transaction_qty) as Total_sales
from `coffee shop sales`
Where month(transaction_date) IN (1,2,3,4,5,6)
Group by product_category
Order by Total_sales Desc;

# TOP 10 product by Sales
Select product_type, sum(unit_price*transaction_qty) as Total_sales
from `coffee shop sales`
Where month(transaction_date) IN (1,2,3,4,5,6) AND product_category = 'coffee'
Group by product_type
Order by Total_sales Desc Limit 10;

# Sales Analysis by Days and Hour

Select sum(unit_price*transaction_qty) as Total_sales,
sum(transaction_qty) as Total_qty_sold,
Count(*) as Total_orders
from `coffee shop sales`
Where month(transaction_date) = 5 -- May
AND dayofweek(transaction_date) = 2 -- Mon
AND hour(transaction_time) = 8 -- Hour no.8
Group by dayname(transaction_date) ;

# Peak Sales Analysis by Hour

Select hour(transaction_time),
sum(unit_price*transaction_qty) as Total_sales
from `coffee shop sales`
where Month(transaction_date) = 5
Group by hour(transaction_time)
order by Total_sales Desc;

# Day Wise Sales

Select 
	CASE 
		WHEN dayofweek(transaction_date) = 2 THEN 'MONDAY'
        WHEN dayofweek(transaction_date) = 3 THEN 'TUESDAY'
        WHEN dayofweek(transaction_date) = 4 THEN 'WEDNESDAY'
        WHEN dayofweek(transaction_date) = 5 THEN 'THRUSDAY'
        WHEN dayofweek(transaction_date) = 6 THEN 'FRIDAY'
        WHEN dayofweek(transaction_date) = 7 THEN 'SATURDAY'
        ELSE 'SUNDAY'
	END AS Day,
    Round(sum(unit_price*transaction_qty)) as Total_sales
    from `coffee shop sales`
    Where month (transaction_date) = 5 -- May
    Group by Day;
    
        


