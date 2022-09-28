with source as (

    select * from {{ source('google_drive', 'tiller_balance_histories') }}

),

renamed as (

    select
        date as dt_balance_updated,
        account_id as id_account,
        balance_id as id_balance,
        institution as str_account_institution,
        balance as amt_balance,
        type as cat_account_type,
        class as cat_account_class,
        account_status as is_account_active

    from source

)

select * from renamed
