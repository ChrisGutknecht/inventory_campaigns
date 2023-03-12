with parent_style_count as (
    
    select
        'full_product_min_count__int' as attribute,
        'Number' as data_type,
        cast(round(count(distinct parent_id_color)/1000,0)*1000 as string) as account_value
    from {{ ref('stg_bz_feed_data_all') }}

)

select * from parent_style_count