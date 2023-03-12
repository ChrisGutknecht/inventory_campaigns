with bz_feed_data_de_agg as (

    select 
        base_country,
        brand_text,
        target_campaign_prev,
        gender_cleaned,
        count(distinct parent_id_color) as nr_models_text,
        min(sale_price_number) as price_min_text,
        round(min(sale_price_number),0) as discount_number
        from {{ ref('int_unisex_correction') }}
        group by 1,2,3,4

),

rep as (

    select *,
        gender_cleaned as gender_text,
        1 as hassaleitems_text,
        1 as stock_number,
        nr_models_text as sale_item_count_number
    from bz_feed_data_de_agg
    where 
        nr_models_text >= 2
        and gender_cleaned not in ('Unisex', 'unisex')

)

select 
    base_country,
    target_campaign_prev,
    brand_text,
    '' as category_text,
    concat(lower(brand_text), '_', lower(gender_text), ' | Feed_BG ') as target_ad_group_prev,
    concat(lower(brand_text), ' ', lower(gender_text)) as keyword_full_text,
    concat(brand_text, ' ', gender_text) as headline_text,
    nr_models_text ,
    'BG' as aggregation_type_text,
    price_min_text,
    gender_text,
    stock_number,
    discount_number,
    hassaleitems_text,
    sale_item_count_number
from rep