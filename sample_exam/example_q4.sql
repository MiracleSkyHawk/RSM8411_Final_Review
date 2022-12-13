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

select p.model, DATE_TRUNC('month', sales_transaction_date) as month, s.product_id, channel, 
    s.dealership_id, count(*) as sales_count, sum(sales_amount) as monthly_total, 
    d.latitude, d.longitude
from sales s
left join dealerships d
on s.dealership_id = d.dealership_id
left join products p
on s.product_id = p.product_id
group by p.model, DATE_TRUNC('month', sales_transaction_date) , s.product_id, channel, 
    s.dealership_id, d.latitude, d.longitude
order by DATE_TRUNC('month', sales_transaction_date);