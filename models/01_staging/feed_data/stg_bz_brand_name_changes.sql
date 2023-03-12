with brand_name_changes as (

    select *
    from {{ source('product_inventory_data', 'product_brand_name_changes') }}

)

select * from brand_name_changes