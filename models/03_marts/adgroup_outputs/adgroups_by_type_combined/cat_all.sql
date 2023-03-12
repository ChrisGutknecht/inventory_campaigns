with category_combinations as (

    select * 
    from {{ ref('category') }}

    union all 
    
    select * 
    from {{ ref('category_gender') }}

),


categories_and_countries_and_matchtypes as (

    select *  
    from category_combinations

    inner join {{ ref('stg_country_codes_all') }} as cc
    on category_combinations.base_country = cc.ref_country

    inner join {{ ref('stg_matchtypes_by_country') }} as mt
    on category_combinations.base_country = mt.matchtypes_country

),

existing_generic_adgroups as (

    select distinct
        campaign_name,
        adgroup_name,
        campaign_status,
        adgroup_status
    from {{ ref('int_keywords') }}
    where 
        campaign_name like '%_3_%'
        and campaign_name not like '%zz_%'
        and campaign_status = 'ENABLED'
        and adgroup_status = 'ENABLED'

),

final_output_cat_all as (

    select
        country,
        matchtypes_long as model_typ,
        /* Generics campaigns have a _3_ prefix */
        replace(concat(campaign_code, target_campaign_prev), '_2_', '_3_') as target_campaign,
        '' as brand_text,
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
    from categories_and_countries_and_matchtypes as categories
    left join existing_generic_adgroups as existing on 
        concat(target_ad_group_prev, matchtypes_parameter) = existing.adgroup_name
    where 
        /* only allow exact matchtypes for generic combinations */
        matchtypes_long = 'exact'
        /* match account data for existing adgroups and remove these */ 
        and adgroup_name is not null

)

select * from final_output_cat_all