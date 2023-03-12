with brand_model_2nd_with_gender as (

    select 
        base_country,
        brand_text,
        --brand_title,
        title_level1,
        --title_level2,
        title1_singular,
        target_campaign_prev,
        gender_cleaned,
        count(distinct parent_id_color) as nr_models_text,
        min(sale_price_number) as price_min_text,
        round(min(sale_price_number),0) as discount_number,
        string_agg(distinct product_type_short, ' , ') as unique_product_type_cleaned
    from {{ ref('int_unisex_correction') }}
    where product_type_level = 2
    {{ dbt_utils.group_by(n=6) }}

),

brand_model_2nd_with_gender_filtered as (

    select *,
        gender_cleaned as gender_text,
        replace(unique_product_type_cleaned, 'Hundeausrüstung', '')  as category_text,
        1 as hassaleitems_text,
        1 as stock_number,
        nr_models_text as sale_item_count_number
    from brand_model_2nd_with_gender
    where 
        nr_models_text >= 2
        and title_level1 is not null
        and unique_product_type_cleaned is not null
        and gender_cleaned not in ('Unisex', 'unisex')

), 

brand_model_2nd_with_gender_final as (

    select 
        base_country,
        target_campaign_prev,
        brand_text,
        category_text,
        concat(lower(brand_text), '_', lower(title_level1), '_', lower(gender_text), ' | Feed_BMG ') as target_ad_group_prev,
        concat(lower(brand_text), ' ', lower(title1_singular), ' ', lower(gender_text)) as keyword_full_text,
        concat(brand_text, ' ', title_level1, ' ', gender_text) as headline_text,
        nr_models_text,
        'BMG' as aggregation_type_text,
        price_min_text,
        gender_text,
        stock_number,
        discount_number,
        hassaleitems_text,
        sale_item_count_number
    from brand_model_2nd_with_gender_filtered

)

select * from brand_model_2nd_with_gender_final