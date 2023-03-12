with current_month as (

    select * from {{ ref('rsa_current_month') }}

), 

current_season as (
    select * from {{ ref('rsa_current_season') }}

), 

current_year as (

    select * from {{ ref('rsa_current_year') }}

), 

brand_count as (

    select * from {{ ref('rsa_product_brand_count') }}
    
), 

product_style_count as (

    select * from {{ ref('rsa_product_style_count') }}
    
), 

rsa_global_customiser_attributes as (

    select * from current_month

    union all

    select * from current_season

    union all

    select * from current_year

    union all

    select * from brand_count

    union all

    select * from product_style_count


), 

rsa_global_customiser_attributes_with_customer_ids as (

    select '784-418-1130' as customer_id, * 
    from rsa_global_customiser_attributes
    
    union all 

    select '557-573-8585' as customer_id, * 
    from rsa_global_customiser_attributes

    union all

    select '184-533-1214' as customer_id, * 
    from rsa_global_customiser_attributes
    
)

select * from rsa_global_customiser_attributes_with_customer_ids