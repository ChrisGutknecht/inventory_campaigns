with category_gender_aggregated as (

    select 
        base_country,
        product_type_level1,
        product_type_short,
        product_type_short_singular,
        concat('_Generics', '_', product_type_level1) as target_campaign_prev,
        gender_cleaned,
        count(distinct parent_id_color) as nr_models_text,
        min(sale_price_number) as price_min_text,
        round(min(sale_price_number),0) as discount_number
    from {{ ref('int_unisex_correction') }}
    where gender_cleaned not in ('Unisex', 'unisex')
    {{ dbt_utils.group_by(n=6) }}

),

category_gender_aggregated_and_filtered as (

    select 
        *,
        gender_cleaned as gender_text,
        product_type_short as category_text,
        1 as hassaleitems_text,
        1 as stock_number,
        nr_models_text as sale_item_count_number
    from category_gender_aggregated
    where 
        {{ filter_generic_categories() }}
        /* remove categories that don't make sense with gender combinations */
        and product_type_short not in ('Grödel', 'Schaufel')


), 

category_gender_aggregated_filtered_and_enriched as (

    select 
        base_country,
        target_campaign_prev,
        '' as brand_text,
        category_text,
        concat(trim(lower(product_type_short)), '_', lower(gender_text), ' | Feed_CG ') as target_ad_group_prev,
        concat(trim(lower(product_type_short_singular)) , ' ', lower(gender_text)) as keyword_full_text,
        concat(trim(product_type_short), ' ', gender_text) as headline_text,
        nr_models_text,
        'CG' as aggregation_type_text,
        price_min_text,
        gender_text,
        stock_number,
        discount_number,
        hassaleitems_text,
        sale_item_count_number
    from category_gender_aggregated_and_filtered

) 

select * from category_gender_aggregated_filtered_and_enriched