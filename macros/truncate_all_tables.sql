-- Replicates the Matillion Grid Iterator "truncate all tables" pattern natively in dbt.
-- Loops over a list of table names and runs TRUNCATE TABLE for each one.
-- Use this when the tables are external/source tables that dbt does NOT manage
-- (loaded by another process) but need to be cleared before that load step runs.
--
-- If the tables ARE dbt models, prefer `dbt run --full-refresh` instead — see
-- README.md section "Which approach to use" for the decision table.

{% macro truncate_all_tables(table_list) %}

    {% if execute %}
        {{ log("Starting truncate_all_tables for " ~ table_list | length ~ " tables", info=True) }}
    {% endif %}

    {% for tbl in table_list %}

        {% set sql_stmt %}
            truncate table if exists {{ tbl }}
        {% endset %}

        {% do run_query(sql_stmt) %}
        {{ log("Truncated " ~ tbl, info=True) }}

    {% endfor %}

    {% if execute %}
        {{ log("Finished truncate_all_tables", info=True) }}
    {% endif %}

{% endmacro %}
