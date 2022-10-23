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

{% set primary_business_key = ["Transaction_ID"] %}
{% set el_metadata = [] %}

with
    raw_data as (select * from {{ source("google_drive", "tiller_transactions") }}),


    prep as (

        select

            transaction_id,
            to_json(
                struct(
                    {{
                        dbt_utils.star(
                            from=source("google_drive", "tiller_transactions"),
                            except=[primary_business_key, el_metadata],
                        )
                    }}
                )
            ) as json_meta_attributes,
            to_json_string(
                struct(
                    {{
                        dbt_utils.star(
                            from=source("google_drive", "tiller_transactions"),
                            except=[primary_business_key, el_metadata],
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
    )

select *
from final
