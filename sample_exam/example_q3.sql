select * from countries;
select * from customer_sales;
select * from customer_survey;
select * from customers;
select * from dealerships;
select * from emails;
select * from products;
select * from public_transportation_by_zip;
select * from sales
order by sales_transaction_date;
select * from salespeople;


select * from products where model in ('Bat', 'Bat Limited Edition');
-------------------------------------------------

create view daily_totals as (
select product_id, sales_transaction_date::date, sum(sales_amount) as daily_sales
from sales
where product_id in (select product_id from products where model in ('Bat', 'Bat Limited Edition') )
group by sales_transaction_date::date, product_id
order by sales_transaction_date::date);

select * from daily_totals;
-------------------------------------------------

create table date_table as (
SELECT day::date 
FROM generate_series((select min(daily_totals.sales_transaction_date) from daily_totals), 
                     (select max(daily_totals.sales_transaction_date) from daily_totals), '1 day') AS day
)

select * from date_table;

-------------------------------------------------
with mv_avg as (
select product_id, sales_transaction_date, daily_sales, avg(daily_sales) over (partition by product_id order by sales_transaction_date
                                                                 rows between 7 preceding and current row) as moving_avg_7
from date_table
left join daily_totals
on date_table.day = daily_totals.sales_transaction_date
order by sales_transaction_date)
select t1.product_id, t1.sales_transaction_date, t1.daily_sales as daily_sales_7, t1.moving_avg_7 as moving_avg_7_7, 
t2.product_id, t2.sales_transaction_date,t2.daily_sales as daily_sales_8, t2.moving_avg_7 as moving_avg_7_8
from mv_avg t1
left join mv_avg t2
on t1.sales_transaction_date = t2.sales_transaction_date
where t1.product_id = 7 and t2.product_id = 8;

-------------------------------------------------------
-------------------------------------------------------
create view monthly_totals as (
select product_id, EXTRACT(YEAR FROM sales_transaction_date) as year, 
    EXTRACT(month FROM sales_transaction_date) as month, sum(sales_amount) as monthly_sales
from sales
where product_id in (select product_id from products where model in ('Bat', 'Bat Limited Edition') )
group by EXTRACT(YEAR FROM sales_transaction_date), EXTRACT(month FROM sales_transaction_date), product_id
order by EXTRACT(YEAR FROM sales_transaction_date), EXTRACT(month FROM sales_transaction_date));

select * from monthly_totals;
-------------------------------------------------

create table month_table as (
SELECT distinct EXTRACT(YEAR FROM month) as year, EXTRACT(month FROM month) as month
FROM generate_series((select min(sales.sales_transaction_date) from sales where product_id in (7,8)), 
                     (select max(sales.sales_transaction_date) from sales where product_id in (7,8)), '1 month') AS month
order by EXTRACT(YEAR FROM month), EXTRACT(month FROM month)
);

select * from month_table;


-------------------------------------------------
with mv_avg as (
select product_id, month_table.year, month_table.month, monthly_sales, avg(monthly_sales) over (partition by product_id order by month_table.year, month_table.month
                                                                 rows between 3 preceding and current row) as moving_avg_3
from month_table
left join monthly_totals
on month_table.year = monthly_totals.year and
    month_table.month = monthly_totals.month
order by year, month)
select t1.product_id, t1.year, t1.month, t1.monthly_sales as monthly_sales_7, t1.moving_avg_3 as moving_avg_3_7, 
t2.product_id, t2.year, t2.month, t2.monthly_sales as monthly_sales_8, t2.moving_avg_3 as moving_avg_3_8
from mv_avg t1
left join mv_avg t2
on t1.year = t2.year and t1.month = t2.month
where t1.product_id = 7 and t2.product_id = 8;


-------------------------------------------------
with mv_avg as (
select product_id, month_table.year, month_table.month, monthly_sales, avg(monthly_sales) over (partition by product_id order by month_table.year, month_table.month
                                                                 rows between 3 preceding and current row) as moving_avg_3
from month_table
left join monthly_totals
on month_table.year = monthly_totals.year and
    month_table.month = monthly_totals.month
order by year, month)
select t1.product_id, t1.year, t1.month, t1.monthly_sales as monthly_sales_7, t1.moving_avg_3 as moving_avg_3_7, 
case when t1.monthly_sales - lag(t1.monthly_sales, 1) over (order by t1.year, t1.month) >0 then 'Up' else 'Down' end trend_7,
t2.product_id, t2.year, t2.month, t2.monthly_sales as monthly_sales_8, t2.moving_avg_3 as moving_avg_3_8,
case when t2.monthly_sales - lag(t2.monthly_sales, 1) over (order by t2.year, t2.month) >0 then 'Up' else 'Down' end trend_8
from mv_avg t1
left join mv_avg t2
on t1.year = t2.year and t1.month = t2.month
where t1.product_id = 7 and t2.product_id = 8;


