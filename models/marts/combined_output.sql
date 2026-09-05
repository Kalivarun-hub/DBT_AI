-- Loads from three upstream models (model_a, model_b, model_c) into ONE table.
-- unique_key + incremental_strategy='merge' makes dbt generate the INSERT-or-UPDATE
-- logic automatically: new order_ids get inserted, existing order_ids with a newer
-- updated_at get updated. No hand-written INSERT/UPDATE SQL required.

{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge'
    )
}}

with combined as (

    select
        order_id,
        customer_id,
        amount,
        updated_at,
        'model_a' as source_model
    from {{ ref('model_a') }}

    union all

    select
        order_id,
        customer_id,
        amount,
        updated_at,
        'model_b' as source_model
    from {{ ref('model_b') }}

    union all

    select
        order_id,
        customer_id,
        amount,
        updated_at,
        'model_c' as source_model
    from {{ ref('model_c') }}

)

select * from combined

{% if is_incremental() %}
-- Only pull rows that are new or changed since the last run.
where updated_at > (select max(updated_at) from {{ this }})
{% endif %}
