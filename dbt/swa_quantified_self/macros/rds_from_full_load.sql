{% macro rds_from_full_load(
    primary_business_key="id",
    primary_business_key_alias=primary_business_key,
    el_metadata=null,
    source_name=null,
    source_table=null
) -%}
{{
    config(
        materialized="incremental",
        full_refresh=false,
        partition_by={
            "field": "tm_meta_processed_at",
            "data_type": "timestamp",
            "granularity": "day",
        },
    )
}}

with
    raw_data as (select * from {{ source(source_name, source_table) }}),


    prep as (

        select

            {{ primary_business_key }} as {{ primary_business_key_alias }},
            to_json(
                struct(
                    {{
                        dbt_utils.star(
                            from=source(source_name, source_table),
                            except=[el_metadata],
                        )
                    }}
                )
            ) as json_meta_attributes,
            to_json_string(
                struct(
                    {{
                        dbt_utils.star(
                            from=source(source_name, source_table),
                            except=[el_metadata],
                        )
                    }}
                )
            ) as str_meta_attributes,
            to_json(struct({{ el_metadata }})) as json_meta_el,
            current_timestamp() as tm_meta_processed_at

        from raw_data
    ),

    final as (
        select * except (str_meta_attributes), md5(str_meta_attributes) as hash_meta_row
        from prep
        where {{ primary_business_key_alias }} is not null
    )

select *
from final
{%- endmacro %}
