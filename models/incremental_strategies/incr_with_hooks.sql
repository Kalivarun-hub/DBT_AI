-- Demonstrates pre_hook (runs before the model builds) and post_hook (runs after).
-- Common real use cases: audit logging, grants, row-count checks, cache refresh
-- triggers, cleanup of staging/temp tables.

{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',

        pre_hook=[
            "insert into tpch_demo.raw.audit_log (model_name, event, event_at)
             select '{{ this.name }}', 'run_started', current_timestamp()"
        ],

        post_hook=[
            "insert into tpch_demo.raw.audit_log (model_name, event, event_at)
             select '{{ this.name }}', 'run_completed', current_timestamp()",

           
        ]
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
