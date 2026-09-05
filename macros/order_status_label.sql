{# Turns TPCH's cryptic single-letter order status codes into readable labels.
   Demonstrates a macro used for business-logic reuse across multiple models. #}

{% macro order_status_label(column_name) %}
    case {{ column_name }}
        when 'O' then 'Open'
        when 'F' then 'Fulfilled'
        when 'P' then 'Partial'
        else 'Unknown'
    end
{% endmacro %}
