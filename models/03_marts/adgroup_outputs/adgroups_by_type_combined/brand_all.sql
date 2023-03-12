with brand as (

    select {{ dbt_utils.star(ref('brand')) }}
    from {{ ref('brand') }}

),

brand_countries_and_matchtypes as (

    select *  
    from brand

    /* add country codes */
    inner join {{ ref('stg_country_codes_all') }} as country_codes
    on brand.base_country = country_codes.ref_country

    /* add current matchtype adgroup differentiation by country */
    inner join {{ ref('stg_matchtypes_by_country') }} as matchtypes
    on brand.base_country = matchtypes.matchtypes_country

),

final_output_brand_all as (

    select
        country,
        matchtypes_long as model_typ,
        concat(campaign_code, target_campaign_prev) as target_campaign,
        brand_text,
        category_text,
        concat(target_ad_group_prev, matchtypes_parameter) as target_ad_group,
        keyword_full_text,
        headline_text,
        nr_models_text,
        aggregation_type_text,
        price_min_text,
        gender_text,
        stock_number,
        discount_number,
        hassaleitems_text,
        sale_item_count_number
    from brand_countries_and_matchtypes
    /* only allow exact match adgroups for brand */
    where matchtypes_long = 'exact'

)

select * from final_output_brand_all