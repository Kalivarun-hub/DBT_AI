-- Same pre_hook/post_hook idea as incr_with_hooks.sql, but calling the
-- log_model_run macro instead of repeating raw SQL. Cleaner when you have
-- many models that all need the same hook logic.

{{
    config(
        materialized='table',
        pre_hook="{{ log_model_run('started') }}",
        post_hook="{{ log_model_run('completed') }}"
    )
}}

select
    nation_key,
    nation_name,
    region_key
from {{ ref('stg_nation') }}
