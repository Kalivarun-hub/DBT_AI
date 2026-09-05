-- Simulates "model_b": second of three upstream models feeding a combined table.
-- Orders from customers in the AUTOMOBILE market segment.

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
)

select
    orders.order_id,
    orders.customer_id,
    orders.total_price       as amount,
    orders.order_date        as updated_at
from orders
inner join customers
    on orders.customer_id = customers.customer_id
where customers.market_segment = 'AUTOMOBILE'
