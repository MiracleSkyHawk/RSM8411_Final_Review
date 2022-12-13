CREATE TABLE customer_sales
    (email varchar PRIMARY KEY,
    phone varchar,
    sales json,
    last_name varchar,
    date_added timestamp,
    first_name varchar,
    customer_id INT);

with customer_json (doc) as (
   values 
    ('[
        {
            "email": "hpurselowev@oaic.gov.au",
            "phone": "239-462-4672",
            "sales": [
                {
                    "product_id": 8,
                    "product_name": "Bat Limited Edition",
                    "sales_amount": 559.992,
                    "sales_transaction_date": "2019-03-29T10:13:23"
                },
                {
                    "product_id": 7,
                    "product_name": "Bat",
                    "sales_amount": 599.99,
                    "sales_transaction_date": "2019-02-18T15:17:44"
                }
            ],
            "last_name": "Purselowe",
            "date_added": "2019-02-07T00:00:00",
            "first_name": "Hamnet",
            "customer_id": 32
        }
    ]'::json)
)
insert into customer_sales (email, phone, sales, last_name, date_added, first_name, customer_id)
select p.*
from customer_json l
  cross join lateral json_populate_recordset(null::customer_sales, doc) as p;

      
select * from customer_sales;


--------------------------------
CREATE TABLE customer_sales_1nf
    (email varchar,
    phone varchar,
    last_name varchar,
    date_added timestamp,
    first_name varchar,
    customer_id INT,
    product_id INT,
    product_name varchar,
    sales_amount decimal(8,3),
    sales_transaction_date timestamp
    );
    
    
with d as (
select *, json_array_elements(sales) as sales_json from customer_sales
),
e as (
select email, phone, last_name, date_added, first_name, customer_id, (sales_json -> 'product_id')::text::int as product_id, 
(sales_json -> 'product_name')::text::varchar as product_name, 
(sales_json -> 'sales_amount')::text::decimal(8,3) as sales_amount, 
(sales_json -> 'sales_transaction_date')::text::timestamp as sales_transaction_date
from d)
INSERT INTO customer_sales_1nf
SELECT email, phone, last_name, date_added, first_name, customer_id, product_id, product_name, sales_amount, sales_transaction_date
FROM e;

select * from customer_sales_1nf;

--------------------------------
CREATE TABLE customer_info
    (
    customer_id INT PRIMARY KEY,
    email varchar,
    phone varchar,
    last_name varchar,
    date_added timestamp,
    first_name varchar);
    

INSERT INTO customer_info
SELECT customer_id, email, phone, last_name, date_added, first_name
FROM customer_sales_1nf
GROUP BY customer_id, email, phone, last_name, date_added, first_name;

--------------------------------
CREATE TABLE sales
    (
    customer_id INT,
    product_id INT,
    sales_amount decimal(8,3),
    sales_transaction_date timestamp,
    PRIMARY KEY (customer_id, product_id) );
    
INSERT INTO sales
SELECT customer_id, product_id, sales_amount, sales_transaction_date
FROM customer_sales_1nf;

ALTER TABLE sales
ADD FOREIGN KEY (customer_id) 
    REFERENCES customer_info;

--------------------------------
CREATE TABLE products
    (
    product_id INT PRIMARY KEY,
    product_name varchar);

INSERT INTO products
SELECT product_id, product_name
FROM customer_sales_1nf
GROUP BY product_id, product_name;


ALTER TABLE sales
ADD FOREIGN KEY (product_id) 
    REFERENCES products;
    
--------------------------------
select * from customer_info;
select * from sales;
select * from products;