with lineitem as (

    select * from {{ ref('stg_lineitem') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

joined as (

    select
        lineitem.order_id,
        lineitem.line_number,
        lineitem.part_id,
        lineitem.supplier_id,
        lineitem.quantity,
        lineitem.extended_price,
        lineitem.discount_pct,
        lineitem.extended_price * (1 - lineitem.discount_pct) as net_item_revenue,
        orders.customer_id,
        orders.order_date,
        orders.order_status

    from lineitem
    left join orders
        on lineitem.order_id = orders.order_id

)

select * from joined
