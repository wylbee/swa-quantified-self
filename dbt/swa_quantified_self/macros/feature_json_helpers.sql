{% macro acid_str(column_name, table_alias) -%}
json_value(
    parse_json({{ table_alias }}anonymous_customer_id), '$.{{column_name}}'
) as {{ column_name }}
{%- endmacro %}

{% macro fj_amt(column_name, table_alias) -%}
safe_cast(
    json_value({{ table_alias }}feature_json, '$.{{column_name}}') as numeric
) as {{ column_name }}
{%- endmacro %}

{% macro fj_n(column_name, table_alias) -%}
safe_cast(
    json_value({{ table_alias }}feature_json, '$.{{column_name}}') as int64
) as {{ column_name }}
{%- endmacro %}

{% macro fj_str(column_name, table_alias) -%}
safe_cast(
    json_value({{ table_alias }}feature_json, '$.{{column_name}}') as str
) as {{ column_name }}
{%- endmacro %}
