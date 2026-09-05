-- Simulates "model_c": third of three upstream models feeding a combined table.
-- Orders from everyone NOT in BUILDING or AUTOMOBILE (so all three models
-- together cover every order with no overlap, and no gaps).

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
where customers.market_segment not in ('BUILDING', 'AUTOMOBILE')
