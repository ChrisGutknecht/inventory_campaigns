with search_ad_url_prefixes as (

    select
        country, 
        search_url_prefix
    from {{ source('feed_campaign_product_data', 'bz_ad_url_search_prefixes') }}

)

select * from search_ad_url_prefixes