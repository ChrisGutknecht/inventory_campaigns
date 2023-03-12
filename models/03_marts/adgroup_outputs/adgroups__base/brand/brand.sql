with brand_aggregated as (

    select 
        base_country,
        brand_text,
        target_campaign_prev,
        count(distinct parent_id_color) as nr_models_text,
        min(sale_price_number) as price_min_text,
        round(min(sale_price_number),0) as discount_number
        from {{ ref('int_unisex_correction') }}
        group by 1,2,3

),

brand_aggregated_and_filtered as (

    select *,
        '' as gender_text,
        1 as hassaleitems_text,
        1 as stock_number,
        nr_models_text as sale_item_count_number
    from brand_aggregated
    where nr_models_text >= 2

),

brand_rows_with_ad_entities as (

    select 
        base_country,
        target_campaign_prev,
        brand_text,
        '' as category_text,
        concat(lower(brand_text), ' | Feed_B ') as target_ad_group_prev,
        lower(brand_text) as keyword_full_text,
        brand_text as headline_text,
        nr_models_text,
        'B' as aggregation_type_text,
        price_min_text,
        gender_text,
        stock_number,
        discount_number,
        hassaleitems_text,
        sale_item_count_number
    from brand_aggregated_and_filtered

)

select * from brand_rows_with_ad_entities