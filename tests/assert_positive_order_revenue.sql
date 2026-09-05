-- Custom test: net revenue should never be negative.
-- dbt fails the test if this query returns any rows.

select order_id, total_net_revenue
from {{ ref('fct_orders') }}
where total_net_revenue < 0
