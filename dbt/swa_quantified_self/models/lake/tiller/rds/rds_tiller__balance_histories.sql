{{
    rds_from_full_load(
        primary_business_key="ifnull(balance_id,date||time||account_id)",
        primary_business_key_alias="balance_id",
        el_metadata=null,
        source_name="google_drive",
        source_table="tiller_balance_histories",
    )
}}
