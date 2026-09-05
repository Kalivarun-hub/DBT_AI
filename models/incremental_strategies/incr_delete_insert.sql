-- STRATEGY: delete+insert
-- For every unique_key value present in the new batch, dbt first DELETEs all
-- existing rows with that key from the target, then INSERTs the new batch.
-- Different from merge: if a source key had MULTIPLE rows previously and now
-- has fewer (or the join logic changes), delete+insert cleans out the old set
-- entirely rather than trying to match row-by-row.
-- Use when: you reload whole "buckets" at once (e.g. all lineitems for an
-- order, all rows for a given day/partition) and want a clean slate per bucket
-- rather than a row-level merge.

{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='delete+insert'
    )
}}

select
    order_id,
    line_number,
    part_id,
    quantity,
    extended_price,
    ship_date
from {{ ref('stg_lineitem') }}

{% if is_incremental() %}
where ship_date > (select max(ship_date) from {{ this }})
{% endif %}
