with union_data as (

    select * 
    from {{ ref('brand_cat') }}

    union all 
    
    select * 
    from {{ ref('brand_cat_gender') }}

),

cross_join_data as (

    select *  
    from union_data

    inner join {{ ref('stg_country_codes_all') }} as cc
    on union_data.base_country = cc.ref_country

    inner join {{ ref('stg_matchtypes_by_country') }} as mt
    on union_data.base_country = mt.matchtypes_country

),

final_output_cat_all as (

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
    from cross_join_data

)

select * from final_output_cat_all