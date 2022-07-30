{% macro nest_activity_context(is_activity_complete=null) -%}
-- keep these general, ie. amt_activity_cash_flow_impact
struct({{ is_activity_complete }} as is_activity_complete) as nest_context,
{%- endmacro %}
