with generics_accepted_category_values_de as (

    select distinct category_text
    from {{ source('feed_campaign_product_data', 'bz_generics_category_exclusion') }}
    /* exclude category values that where classified as too generic */
    where too_generic is null

)

select * from generics_accepted_category_values_de