with 

source as (

    select * from {{ source('neo_bank', 'devices') }}

),

renamed as (

    select
        string_field_0 AS device_type,
        string_field_1 AS user_id

    from source

)

select * from renamed