elect * from countries;
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
with t as (
select s.*, point(c.latitude, c.longitude) as customer_point, point(d.latitude, d.longitude) as dealership_point, 
    point(c.latitude, c.longitude) <@> point(d.latitude, d.longitude) as c_to_d_distance
from sales s
left join customers c
on s.customer_id = c.customer_id
left join dealerships d
on s.dealership_id = d.dealership_id)
select dealership_id, avg(c_to_d_distance) as avg_distance
from t
group by dealership_id
order by dealership_id;




