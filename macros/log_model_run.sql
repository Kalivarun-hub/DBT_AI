-- Reusable hook logic as a macro, instead of repeating raw SQL strings in
-- every model's config(). Call it like: post_hook="{{ log_model_run('completed') }}"

{% macro log_model_run(event) %}
    insert into tpch_demo.raw.audit_log (model_name, event, event_at)
    select '{{ this.name }}', '{{ event }}', current_timestamp()
{% endmacro %}
