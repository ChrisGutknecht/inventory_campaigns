 with level2 as (
     
      select 
        base_country,
        id,
        title,
        description,
        link,
        brand,
        color,
        condition,
        gender,
        material,
        price,
        sale_price,
        product_type,
        brand_text,
        price_number,
        sale_price_number,
        gender_cleaned,
        product_type_level1,
        split_product_type_level2 as split_product_type,
        2 as product_type_level,
        parent_id_color
    from {{ ref('stg_bz_feed_data_all') }}

),

level3 as (
     
    select 
        base_country,
        id,
        title,
        description,
        link,
        brand,
        color,
        condition,
        gender,
        material,
        price,
        sale_price,
        product_type,
        brand_text,
        price_number,
        sale_price_number,
        gender_cleaned,
        product_type_level1,
        split_product_type_level3 as split_product_type,
        3 as product_type_level,
        parent_id_color
    from {{ ref('stg_bz_feed_data_all') }}

 ),

 level4 as (
     
    select 
        base_country,
        id,
        title,
        description,
        link,
        brand,
        color,
        condition,
        gender,
        material,
        price,
        sale_price,
        product_type,
        brand_text,
        price_number,
        sale_price_number,
        gender_cleaned,
        product_type_level1,
        split_product_type_level4 as split_product_type,
        4 as product_type_level,
        parent_id_color
    from {{ ref('stg_bz_feed_data_all') }}

 )

 select * from level2
 union all
 select * from level3
 union all
 select * from level4