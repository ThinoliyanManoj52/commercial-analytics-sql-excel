use commercial_analytics;

select database();

#Overall Sales & Profit Analysis
select
    count(*) as total_records,
    count(distinct order_id) as total_orders,
    count(distinct customer_id) as total_customers,
    count(distinct product_name) as total_products,
    
    round(sum(sales),2) as total_gross_sales,
    
    round(sum(order_item_total),2) as total_net_sales,
    
    round(
        sum(order_item_total * profit_ratio)
        / nullif(sum(order_item_total),0) * 100,
        2
        ) as estimated_profit_margin_percentage,
        
	round(
		sum(order_item_total)
        / nullif(count(distinct order_id),0),
        2
        ) as average_order_value
        
from cleaned_commercial_sales;

#Monthly Sales Performance
select
    date_format(order_date,'%y-%m') as sales_month,
    count(distinct order_id) as total_orders,
    
    round(sum(sales),2) as gross_sales,
    
    round(sum(order_item_total), 2) as net_sales,
    
    round(
         sum(order_item_total * profit_ratio),2
    ) as estimated_profit
    
from cleaned_commercial_sales
    
group by date_format(order_date, '%y-%m')
    
order by sales_month;
    
#Product Category Performance
select 
     category_name,
     
     count(distinct order_id) as total_orders,
     
     sum(quantity) as total_quantity_sold,
     
     round(sum(order_item_total), 2) as total_sales,
     
     round(
          sum(order_item_total * profit_ratio), 2
	) as estimated_profit,
    
    round(
          sum(order_item_total * profit_ratio)
          / nullif(sum(order_item_total), 0) * 100,
          2
	)as profit_margin_percentage
    
from cleaned_commercial_sales

group by category_name

order by total_sales desc;
          
#Top 10 Profitable Products
select
     product_name,
     category_name,
     
     sum(quantity) as total_quantity_sold,
     
     round(sum(order_item_total), 2)  as total_sales,
     
     round(
         sum(order_item_total * profit_ratio),2
         ) as estimated_profit
from cleaned_commercial_sales

group by
    product_name,
    category_name
    
order by estimated_profit desc
limit 10;

#Bottom 10 Profitable Products
select
     product_name,
     category_name,
     
     sum(quantity) as total_quantity_sold,
     
     round(sum(order_item_total), 2)  as total_sales,
     
     round(
         sum(order_item_total * profit_ratio),2
         ) as estimated_profit
from cleaned_commercial_sales

group by
    product_name,
    category_name
    
order by estimated_profit asc
limit 10;

#Market performance Analysis
select
     market,
     
     count(distinct order_id) as total_orders,
     
     count(distinct customer_id) as total_customers,
     
     round(sum(order_item_total), 2) as total_sales,
     
     round(
         sum(order_item_total * profit_ratio),2
         ) as estimated_profit
         
from cleaned_commercial_sales

group by market
    
order by estimated_profit desc;

#Regional Sales Analysis
select
     order_region,
     
     count(distinct order_id) as total_orders,
     
     count(distinct order_item_total) as total_sales,
     
     round(
         sum(order_item_total * profit_ratio),2
         ) as estimated_profit
         
from cleaned_commercial_sales

group by order_region
    
order by total_sales desc;

#Customer Behaviour Analysis (top 10 customers)
select 
     customer_id,
     
     count(distinct order_id) as total_orders,
     
     round(sum(order_item_total), 2) as total_purchase_value,
     
     round(
         sum(order_item_total * profit_ratio), 2
         ) as estimated_profit
from cleaned_commercial_sales

group by customer_id

order by total_purchase_value desc

limit 10;

#Customer Behaviour Analysis (repeat customer analysis)
select 
     count(*) as total_customers,
     
     sum(
         case
             when total_orders > 1 then 1
             else 0
		end
	) as repeat_customers,
    
    sum(
         case
             when total_orders = 1 then 1
             else 0
		end
	) as one_time_customers
    
from (
    select 
         customer_id,
         count(distinct order_id) as total_orders
	from cleaned_commercial_sales
    
    group by customer_id
    
    ) as customer_summary;
    
#Discount Impact Analysis
select 
     case 
         when discount_rate = 0 then 'No Discount!'
         when discount_rate <= 0.10 then 'Low Discount!'
         when discount_rate = 0.20 then 'Medium Discount!'
         else 'High Discount!'
	 end as discount_category,
     
     count(*) as total_records,
     
     round(sum(order_item_total),2) as total_sales,
     
     round(
         sum(order_item_total * profit_ratio), 2
	) as estimated_profit,
    
    round(avg(profit_ratio) * 100,2)
        as average_profit_margin_percentage

from cleaned_commercial_sales
group by discount_category
order by estimated_profit desc;

#Shipping Mode Performance
select
     shipping_mode,
     
     count(*) as total_records,
     
     round(avg(actual_shipping_days),2)
         as average_actual_shipping_days,
	
    round(avg(scheduled_shipping_days),2)
         as average_scheduled_shipping_days,
	
    sum(
       case 
           when actual_shipping_days > scheduled_shipping_days
           then 1
           else 0
		end
        ) as delayed_records

from cleaned_commercial_sales

group by shipping_mode

order by delayed_records desc;

#Delivery Status Analysis
select 
	delivery_status,
    
    count(*) as total_records,
    
    count(distinct order_id) as total_orders,
    
    round(
        count(*) * 100.0 /
        (select count(*) from cleaned_commercial_sales),
        2
        ) as percentage_of_records
        
from cleaned_commercial_sales
group by delivery_status
order by total_records desc;

#Order Status Analysis
select 
     order_status,
     
     count(distinct order_id) as total_orders,
     
     round(sum(order_item_total), 2) as total_sales

from cleaned_commercial_sales
group by order_status
order by total_orders desc;

#Advanced SQL: Month-on-Month Sales Growth
with monthly_sales as (
     select
          date_format(order_date, '%y-%m') as sales_month,
          sum(order_item_total) as total_sales
	from cleaned_commercial_sales
    group by date_format(order_date,'%y-%m')
    ),
    
sales_comparison as (
     select
          sales_month,
          total_sales,
          
          lag(total_sales) over (
			order by sales_month
            ) as previous_month_sales
            
	 from monthly_sales
     )
     
     select
         sales_month,
         
         round(total_sales, 2) as current_month_sales,
         
         round(previous_month_sales, 2)
           as previous_month_sales,
           
		round(
			(total_sales - previous_month_sales)
            / nullif(previous_month_sales, 0) * 100,
            2
		) as sales_growth_percentage

from sales_comparison
order by sales_month;

#Final Business Performance Summary
select 
     count(distinct order_id) as total_orders,
     count(distinct customer_id) as total_customers,
     
     round(sum(order_item_total), 2) as total_net_sales,
     
     round(
         sum(order_item_total * profit_ratio),2
         ) as estimated_shipping_profits,
         
         round(
              avg(actual_shipping_days), 2
              ) as average_shipping_days,
              
              sum(
                 case 
                     when actual_shipping_days > scheduled_shipping_days
                     then 1
                     else 0
				end
			) as delayed_records,
            
            round(
                sum(
                   case
                       when actual_shipping_days > scheduled_shipping_days
                       then 1
                       else 0
					end
				) * 100.0 / count(*),
                2
			 ) as delayed_record_percentage
             
from cleaned_commercial_sales;
     

