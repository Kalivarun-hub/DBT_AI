with customers as (

    select
        c_custkey,
        c_name,
        c_address,
        c_nationkey,
        c_phone,
        c_acctbal,
        c_mktsegment
    from {{ source('tpch', 'CUSTOMER') }}

),

nations as (

    select
        n_nationkey,
        n_name,
        n_regionkey
    from {{ source('tpch', 'NATION') }}

),

regions as (

    select
        r_regionkey,
        r_name
    from {{ source('tpch', 'REGION') }}

)

select
    customers.c_custkey as customer_id,
    customers.c_name as customer_name,
    customers.c_address as address,
    customers.c_phone as customer_phone,
    customers.c_acctbal as account_balance,
    customers.c_mktsegment as market_segment,
    nations.n_nationkey as nation_key,
    nations.n_name as nation_name,
    regions.r_regionkey as region_key,
    regions.r_name as region,
    convert_timezone(
        'America/Los_Angeles',
        'Asia/Kolkata',
        current_timestamp()
    ) as audit_runtime_ist
from customers
inner join nations
    on customers.c_nationkey = nations.n_nationkey
inner join regions
    on nations.n_regionkey = regions.r_regionkey
where regions.r_name = 'ASIA'
