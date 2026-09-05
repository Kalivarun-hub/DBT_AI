-- STRATEGY: merge (Snowflake default when unique_key is set)
-- Generates a real SQL MERGE statement: matches on unique_key, UPDATEs matched
-- rows, INSERTs unmatched rows. This is what combined_output.sql already uses.
-- Use when: rows can change after they're first loaded (status updates, amount
-- corrections) and you need the target table to reflect the latest version only.

{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge'
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
