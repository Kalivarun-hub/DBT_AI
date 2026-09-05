{% snapshot customers_snapshot %}

{{
    config(
        target_schema='RAW',
        unique_key='customer_id',
        strategy='check',
        check_cols=['customer_name', 'address', 'nation_key', 'account_balance', 'market_segment']
    )
}}

select * from {{ ref('stg_customers') }}

{% endsnapshot %}
