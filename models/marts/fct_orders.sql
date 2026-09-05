{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

with order_items as (

    select * from {{ ref('int_order_items') }}

),

aggregated as (

    select
        order_id,
        customer_id,
        order_date,
        order_status,
        {{ order_status_label('order_status') }} as order_status_label,
        count(distinct line_number)               as line_item_count,
        sum(quantity)                              as total_quantity,
        sum(net_item_revenue)                       as total_net_revenue,
        {{ cents_to_dollars('sum(net_item_revenue) * 100') }} as total_net_revenue_usd_rounded

    from order_items
    group by 1, 2, 3, 4

)

select * from aggregated

{% if is_incremental() %}
where order_date > (select max(order_date) from {{ this }})
{% endif %}
