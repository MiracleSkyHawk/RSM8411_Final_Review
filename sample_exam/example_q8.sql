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

-------------------------------------------------
select * from analytical_sales_table;

-- rank based on the moving total of the past 12 months given any months

create view moving_sales_rank_view as (
    with m as (
    select month, dealership_id, sum(sales_count) as sales_total_count, sum(monthly_total) as monthly_sales_total, 
    latitude, longitude
    from analytical_sales_table
    where channel = 'dealership'
    group by month, dealership_id, latitude, longitude
    order by month),
    k as (
    select *, sum(monthly_sales_total) over (partition by dealership_id order by month rows between 11 preceding and current row) as moving_total_12
    from m
    )
    select *, rank() over (partition by month order by moving_total_12 DESC) as sales_rank
    from k
    order by month, sales_rank);


select * from moving_sales_rank_view;

-------------------------------------------------

create view sales_rank_view as (
    with m as (
    select month, dealership_id, sum(sales_count) as sales_total_count, sum(monthly_total) as monthly_sales_total, 
    latitude, longitude
    from analytical_sales_table
    where channel = 'dealership'
    group by month, dealership_id, latitude, longitude
    order by month)
    select *, rank() over (partition by month order by monthly_sales_total DESC) as sales_rank
    from m
    order by month, sales_rank);


select * from sales_rank_view;


