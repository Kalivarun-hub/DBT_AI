-- TRUNCATE-AND-LOAD PATTERN (dbt-native, no external macro loop needed for
-- a single model dbt itself owns).
--
-- A plain `materialized='table'` does CREATE OR REPLACE under the hood, which
-- silently drops any GRANTs applied directly on the table. This pattern instead
-- truncates the existing table via pre_hook, then does a full incremental
-- "append" load (no is_incremental() filter) — the table object itself is
-- never dropped, so grants persist across every run.
--
-- Use this when: you want a full reload every run (like Matillion's
-- truncate-then-load), AND the table already has grants/permissions you don't
-- want to reapply every time.

{{
    config(
        materialized='incremental',
        incremental_strategy='append',
        pre_hook="truncate table if exists {{ this }}"
    )
}}

select
    order_id,
    customer_id,
    total_price,
    order_date,
    order_status
from {{ ref('stg_orders') }}

-- Deliberately NO is_incremental() filter — every run reloads all rows,
-- since pre_hook already wiped the table clean first.
