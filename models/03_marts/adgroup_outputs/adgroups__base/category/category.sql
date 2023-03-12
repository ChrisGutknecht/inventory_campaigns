with category_aggregated as (

    select 
        base_country,
        product_type_level1,
        product_type_short,
        product_type_short_singular,
        concat('_Generics', '_', product_type_level1) as target_campaign_prev,
        count(distinct parent_id_color) as nr_models_text,
        min(sale_price_number) as price_min_text,
        round(min(sale_price_number),0) as discount_number,
        string_agg(distinct gender_cleaned, ', ') as gender_text
        --string_agg(distinct title_cleaned, ' , ') as unique_product_type_cleaned
    from {{ ref('int_feed_title_manu_combined') }}
    where gender_cleaned not in ('Unisex', 'unisex')
    {{ dbt_utils.group_by(n=5) }}

),

category_aggregated_and_filtered as (

    select 
        *,
        product_type_short as category_text,
        1 as hassaleitems_text,
        1 as stock_number,
        nr_models_text as sale_item_count_number
    from category_aggregated
    where {{ filter_generic_categories() }}

),

category_aggregated_filtered_and_enriched as (

    select 
        base_country,
        target_campaign_prev,
        '' as brand_text,
        category_text,
        concat(trim(lower(product_type_short)), ' | Feed_C ') as target_ad_group_prev,
        concat(trim(lower(product_type_short_singular))) as keyword_full_text,
        concat(trim(product_type_short)) as headline_text,
        nr_models_text,
        'C' as aggregation_type_text,
        price_min_text,
        gender_text,
        stock_number,
        discount_number,
        hassaleitems_text,
        sale_item_count_number
    from category_aggregated_and_filtered

)

select * from category_aggregated_filtered_and_enriched