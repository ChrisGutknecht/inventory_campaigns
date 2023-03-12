with rsa_templates_by_language as (

    select 
        language,	
        ad_number,
        headline_1,
        headline_2,
        headline_3,
        headline_4,
        headline_5,
        headline_6,
        headline_7,
        headline_8,
        headline_9,
        headline_10,
        headline_11,
        headline_12,
        headline_13,
        headline_14,
        headline_15,
        /* removed to columns from template */
        headline_16 as description_1,
        headline_17 as description_2,
        description_1 as description_3,
        description_2 as description_4
    from {{ source('feed_campaign_product_data', 'bz_feed_rsa_templates') }}

)

select * from rsa_templates_by_language