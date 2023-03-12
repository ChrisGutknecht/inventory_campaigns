with bz_country_codes_all as (

    select *
    from {{ source('feed_campaign_product_data', 'bz_country_codes_all') }}

)

select * from bz_country_codes_all