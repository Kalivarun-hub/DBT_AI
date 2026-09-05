{% snapshot customers_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='check',
        check_cols=['customer_name', 'address', 'nation_key', 'account_balance', 'market_segment']
    )
}}

select
    c_custkey    as customer_id,
    c_name       as customer_name,
    c_address    as address,
    c_nationkey  as nation_key,
    c_acctbal    as account_balance,
    c_mktsegment as market_segment

from {{ source('tpch', 'customer') }}

{% endsnapshot %}
-- Note: {{ source('tpch','customer') }} resolves to tpch_demo.raw.customer (the writable
-- copy), so the UPDATE in setup_scripts/02_demo_inserts_and_updates.sql is what this
-- snapshot picks up on the next `dbt snapshot` run.
