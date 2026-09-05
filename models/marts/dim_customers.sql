with snapshot as (

    select * from {{ ref('customers_snapshot') }}

),

region_mapping as (

    select * from {{ ref('region_mapping') }}

),

final as (

    select
        snapshot.customer_id,
        snapshot.customer_name,
        snapshot.address,
        snapshot.nation_key,
        snapshot.account_balance,
        snapshot.market_segment,
        region_mapping.region_group,
        region_mapping.is_priority_market,
        snapshot.dbt_valid_from,
        snapshot.dbt_valid_to,
        case when snapshot.dbt_valid_to is null then true else false end as is_current

    from snapshot
    left join region_mapping
        on snapshot.nation_key = region_mapping.nation_key

)

select * from final
