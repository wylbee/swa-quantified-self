with source as (

    select * from {{ source('google_drive', 'tiller_accounts') }}

),

renamed as (

    select
        string_field_0 as str_account_name,
        string_field_1 as cat_account_class,
        string_field_2 as cat_account_group,
        string_field_3 as is_account_hidden,
        string_field_6 as id_account

    from source

)

select * from renamed
