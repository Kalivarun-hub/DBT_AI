-- Simulates the "load" step an external ETL tool (Matillion, Fivetran, etc.)
-- would normally perform AFTER truncate_all_tables clears the tables.
-- Included only so the demo has something to show for "truncate, then load."
-- In a real pipeline this step lives outside dbt — dbt's job here is only
-- the truncate, via truncate_all_tables.

{% macro load_external_tables() %}

    {% set load_customers %}
        insert into tpch_demo.external_load.ext_customers
        select c_custkey, c_name, c_mktsegment, current_timestamp()
        from snowflake_sample_data.tpch_sf1.customer
        limit 1000
    {% endset %}

    {% set load_orders %}
        insert into tpch_demo.external_load.ext_orders
        select o_orderkey, o_custkey, o_totalprice, o_orderdate, current_timestamp()
        from snowflake_sample_data.tpch_sf1.orders
        limit 1000
    {% endset %}

    {% do run_query(load_customers) %}
    {{ log("Loaded ext_customers", info=True) }}

    {% do run_query(load_orders) %}
    {{ log("Loaded ext_orders", info=True) }}

{% endmacro %}
