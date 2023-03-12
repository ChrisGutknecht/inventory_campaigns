with brand_cat_aggregated as (

    select 
        base_country,
        brand_text,
        brand_cat,
        product_type_level1,
        product_type_short,
        product_type_short_singular,
        target_campaign_prev,
        count(distinct parent_id_color) as nr_models_text,
        min(sale_price_number) as price_min_text,
        round(min(sale_price_number),0) as discount_number,
        string_agg(distinct gender_cleaned, ', ') as gender_text,
        --string_agg(distinct title_cleaned, ' , ') as unique_product_type_cleaned
    from {{ ref('int_feed_title_manu_combined') }}
    {{ dbt_utils.group_by(n=7) }}

),

brand_cat_aggregated_and_filtered as (

    select 
        *,
        product_type_short as category_text,
        1 as hassaleitems_text,
        1 as stock_number,
        nr_models_text as sale_item_count_number
    from brand_cat_aggregated
    where 
        nr_models_text >= 2 and
        product_type_short is not null

)

select 
    base_country,
    target_campaign_prev,
    brand_text,
    category_text,
    concat(lower(brand_text), '_', trim(lower(product_type_short)), ' | Feed_BC ') as target_ad_group_prev,
    concat(lower(brand_text), ' ', trim(lower(product_type_short_singular))) as keyword_full_text,
    concat(brand_text, ' ', trim(product_type_short)) as headline_text,
    nr_models_text,
    'BC' as aggregation_type_text,
    price_min_text,
    gender_text,
    stock_number,
    discount_number,
    hassaleitems_text,
    sale_item_count_number
from brand_cat_aggregated_and_filtered