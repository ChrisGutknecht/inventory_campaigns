with brand_model_1st as (

    select 
        base_country,
        brand_text,
        brand_title,
        title_level1,
        title1_singular,
        target_campaign_prev,
        count(distinct parent_id_color) as nr_models_text,
        min(sale_price_number) as price_min_text,
        round(min(sale_price_number),0) as discount_number,
        string_agg(distinct gender_cleaned, ', ') as gender_text,
        string_agg(distinct product_type_short, ' , ') as unique_product_type_cleaned
    from {{ ref('int_feed_title_manu_combined') }}
    where 
        (product_type like '%Schuhe%' or product_type like '%Ausrüstung%')
        and length(title1_singular) > 3
    {{ dbt_utils.group_by(n=6) }}

),

brand_model_1st_filtered as (

    select
        *,
        replace(split(SPLIT(unique_product_type_cleaned,',')[SAFE_OFFSET(0)], '&')[SAFE_OFFSET(0)], 'Hundeausrüstung', '')  as category_text,
        1 as hassaleitems_text,
        1 as stock_number,
        nr_models_text as sale_item_count_number
    from brand_model_1st
    where 
        nr_models_text >= 2
        and title_level1 is not null
        and unique_product_type_cleaned is not null

),

brand_mod_1st_final as (

    select 
        base_country,
        target_campaign_prev,
        brand_text ,
        category_text,
        concat(lower(brand_text), '_', lower(title_level1), ' | Feed_BM ') as target_ad_group_prev,
        concat(lower(brand_text), ' ', lower(title1_singular)) as keyword_full_text,
        concat(brand_text, ' ', title_level1) as headline_text,
        nr_models_text,
        'BM' as aggregation_type_text,
        price_min_text,
        gender_text,
        stock_number,
        discount_number,
        hassaleitems_text,
        sale_item_count_number
    from brand_model_1st_filtered

)

select * from brand_mod_1st_final