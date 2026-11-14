{% macro snapshot_get_time() %}
    CURRENT_DATETIME('UTC')
{% endmacro %}