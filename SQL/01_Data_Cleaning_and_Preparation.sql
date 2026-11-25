use commercial_analytics;

show tables;

drop table if exists raw_dataco;

CREATE TABLE raw_dataco (
    transaction_type LONGTEXT,
    days_for_shipping_real LONGTEXT,
    days_for_shipment_scheduled LONGTEXT,
    benefit_per_order LONGTEXT,
    sales_per_customer LONGTEXT,
    delivery_status LONGTEXT,
    late_delivery_risk LONGTEXT,
    category_id LONGTEXT,
    category_name LONGTEXT,
    customer_city LONGTEXT,
    customer_country LONGTEXT,
    customer_email LONGTEXT,
    customer_first_name LONGTEXT,
    customer_id LONGTEXT,
    customer_last_name LONGTEXT,
    customer_password LONGTEXT,
    customer_segment LONGTEXT,
    customer_state LONGTEXT,
    customer_street LONGTEXT,
    customer_zipcode LONGTEXT,
    department_id LONGTEXT,
    department_name LONGTEXT,
    latitude LONGTEXT,
    longitude LONGTEXT,
    market LONGTEXT,
    order_city LONGTEXT,
    order_country LONGTEXT,
    order_customer_id LONGTEXT,
    order_date LONGTEXT,
    order_id LONGTEXT,
    order_item_cardprod_id LONGTEXT,
    order_item_discount LONGTEXT,
    order_item_discount_rate LONGTEXT,
    order_item_id LONGTEXT,
    order_item_product_price LONGTEXT,
    order_item_profit_ratio LONGTEXT,
    order_item_quantity LONGTEXT,
    sales LONGTEXT,
    order_item_total LONGTEXT,
    order_profit_per_order LONGTEXT,
    order_region LONGTEXT,
    order_state LONGTEXT,
    order_status LONGTEXT,
    order_zipcode LONGTEXT,
    product_card_id LONGTEXT,
    product_category_id LONGTEXT,
    product_description LONGTEXT,
    product_image LONGTEXT,
    product_name LONGTEXT,
    product_price LONGTEXT,
    product_status LONGTEXT,
    shipping_date LONGTEXT,
    shipping_mode LONGTEXT
);

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/DataCoSupplyChainDataset.csv'
INTO TABLE raw_dataco
CHARACTER SET latin1
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

select count(*) as total_records
from raw_dataco;

select * from raw_dataco limit 5;

select count(*) as total_columns
from information_schema.columns
where table_schema = 'commercial_analytics'
and table_name = 'raw_dataco'

#Duplicate order item records
select 
      count(*) as total_records,
	  count(distinct order_item_id) as unique_order_items
from raw_dataco;

#Missing values check
select 
	sum(case when order_id is null or trim(order_id) = '' then 1 else 0 end) as missing_order_id,
    sum(case when sales is null or trim(sales) = '' then 1 else 0 end) as missing_sales,
    sum(case when product_name is null or trim(product_name) = '' then 1 else 0 end) as missing_sales,
    sum(case when order_date is null or trim(order_date) = '' then 1 else 0 end) as missing_sales
from raw_dataco;

#create Clean Analytical Table
drop table if exists cleaned_commercial_sales;

create table cleaned_commercial_sales as
select
    transaction_type,
    
    cast(nullif(trim(days_for_shipping_real),'') as unsigned)
        as actual_shipping_days,
	
     cast(nullif(trim(days_for_shipment_scheduled),'') as unsigned)
        as scheduled_shipping_days,
    
    cast(nullif(trim(benefit_per_order),'') as decimal(18,2))
        as benefit_per_order,
	 cast(nullif(trim(sales_per_customer),'') as decimal(18,2))
        as sales_per_customer,
        
	delivery_status,
    
     cast(nullif(trim(late_delivery_risk),'') as unsigned)
        as late_delivery_risk,
	
	 cast(nullif(trim(category_id),'') as unsigned)
        as category_id,
	
    category_name,
    customer_country,
    customer_segment,
    
	cast(nullif(trim(customer_id),'') as unsigned)
        as customer_id,
	
    department_name,
    market,
    order_city,
    order_country,
    
    cast(nullif(trim(order_id),'') as unsigned)
        as order_id,
    
    case
        when order_date like '%%'
        then str_to_date(order_date, '%m/%d/%Y %H:%i')
		else str_to_date(order_date, '%y/%m%d %H:%i:%s')
	end as order_date,
    
    cast(nullif(trim(order_item_id), '') as unsigned)
        as order_item_id,
	
    cast(nullif(trim(order_item_discount), '') as decimal(18,2))
        as discount_amount,
	
    cast(nullif(trim(order_item_discount_rate), '') as decimal(18,4))
        as discount_rate,
	
    cast(nullif(trim(order_item_product_price), '') as decimal(18,2))
        as profit_ratio,
	
    cast(nullif(trim(order_item_quantity), '') as unsigned)
        as quantity,
	
    cast(nullif(trim(sales), '') as decimal(18,2))
        as sales,
	
    cast(nullif(trim(order_item_total), '') as decimal(18,2))
        as order_item_total,
	
    cast(nullif(trim(order_profit_per_order), '') as decimal(18,2))
        as order_profit,
	
    order_region,
    order_state,
    order_status,
    product_name,
    
    cast(nullif(trim(product_price), '') as decimal(18,2))
        as product_price_listed,
	
    case
        when shipping_date like '%%'
        then str_to_date(shipping_date, '%m/%d/%Y %H:%i')
		else str_to_date(shipping_date, '%y/%m%d %H:%i:%s')
	end as shipping_date,
    
    shipping_mode
    
from raw_dataco;

#Cleaned total records
select count(*) as cleaned_total_records
from cleaned_commercial_sales;

#First 5 cleaned records
select * from cleaned_commercial_sales limit 5;

#Cleaned table columns
show columns from cleaned_commercial_sales;

#Sales and profit validation
select
    sum(sales) as total_sales,
    sum(order_profit) as total_profit,
    avg(sales) as average_sales
from cleaned_commercial_sales;

#Final Day 1 Verification
select
    count(*) as total_records,
    count(distinct order_id) as total_orders,
    count(distinct customer_id) as total_customers,
    count(distinct product_name) as total_products,
    sum(sales) as total_sales,
    sum(order_profit) as total_profit
from cleaned_commercial_sales;


    


