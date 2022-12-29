{% macro generate_final_event_cte(
    prev_cte_name, surrogate_key_columns, responsible_subject_column
) -%}

final as (

    select
        {{ dbt_utils.surrogate_key(surrogate_key_columns) }} as key_event,
        tm_event,
        cat_event,

        row_number() over (
            partition by {{ responsible_subject_column }} order by tm_event
        ) as n_event,

        lead(tm_event) over (
            partition by {{ responsible_subject_column }} order by tm_event
        ) as tm_event_next,

        str_source_url,
        id_source,
        json_event_features,
        cast(tm_event as date) as key_calendar,

        * except (tm_event, cat_event, str_source_url, id_source, json_event_features)

    from {{ prev_cte_name }}

)

select *
from final
order by tm_event
{%- endmacro %}
