-- STRATEGY: append
-- Simplest strategy. Every run just INSERTs whatever the select returns.
-- No dedup, no update — if the same row shows up twice, you get a duplicate.
-- Use when: source is genuinely append-only (event logs, immutable audit trails)
-- and you never need to update or overwrite a previously-loaded row.

{{
    config(
        materialized='incremental',
        incremental_strategy='append'
    )
}}

select
    order_id,
    customer_id,
    total_price,
    order_date,
    order_status
from {{ ref('stg_orders') }}

{% if is_incremental() %}
where order_date > (select max(order_date) from {{ this }})
{% endif %}
