-- STRATEGY: merge, restricted to specific columns
-- Same as incr_merge.sql, but only overwrites certain columns on a match —
-- other columns keep their original loaded value even if the source changes.
-- Use when: you want status/amount to update, but a column like
-- "first_loaded_at" should never change once set.

{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
        merge_update_columns=['total_price', 'order_status']
        -- alternative: merge_exclude_columns=['first_loaded_at']
    )
}}

select
    order_id,
    customer_id,
    total_price,
    order_date,
    order_status,
    current_timestamp() as first_loaded_at
from {{ ref('stg_orders') }}

{% if is_incremental() %}
where order_date > (select max(order_date) from {{ this }})
{% endif %}
