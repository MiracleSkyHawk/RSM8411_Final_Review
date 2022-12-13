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

create table analytical_table as (
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
    order by DATE_TRUNC('month', sales_transaction_date));


select * from analytical_table;

-------------------------------------------------

CREATE FUNCTION update_sales() 
RETURNS TRIGGER AS 
    $$
        DECLARE

        new_latitude double precision;
        new_longitude double precision;
        new_monthly_total double precision;
        new_monthly_count bigint;
        new_model text;
        
        temp_monthly_total double precision;
        temp_monthly_count bigint;

            BEGIN
                
                select model into new_model from products where product_id = new.product_id;
                select latitude, longitude into new_latitude, new_longitude from dealerships where dealership_id = new.dealership_id;
                
                select monthly_total into temp_monthly_total from analytical_table where 
                month=DATE_TRUNC('month', new.sales_transaction_date) and product_id = new.product_id and dealership_id = new.dealership_id;
                
                select sales_count into temp_monthly_count from analytical_table where 
                month=DATE_TRUNC('month', new.sales_transaction_date) and product_id = new.product_id and dealership_id = new.dealership_id;                
                
                if temp_monthly_total is not NULL then
                
                    new_monthly_count := temp_monthly_count + 1;
                    new_monthly_total := temp_monthly_total + new.sales_amount;

                    update analytical_table set sales_count = new_monthly_count, monthly_total = new_monthly_total
                    where product_id = new.product_id and dealership_id = new.dealership_id 
                    and DATE_TRUNC('month', new.sales_transaction_date) = month;
                    
                    return new;
                    
                 else
                    insert into analytical_table
                    values(new_model, DATE_TRUNC('month', new.sales_transaction_date), new.product_id, new.channel, new.dealership_id,
                    1, new.sales_amount, new_latitude, new_longitude);
                    
                    return new;
                    
                 end if;

            END; 
    $$
LANGUAGE PLPGSQL;

CREATE TRIGGER update_sales_trigger
AFTER INSERT ON sales
FOR EACH ROW
EXECUTE PROCEDURE update_sales();

