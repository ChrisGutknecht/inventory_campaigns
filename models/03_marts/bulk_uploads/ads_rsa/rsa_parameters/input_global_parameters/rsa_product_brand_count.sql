with brand_count as (

    select 
        'brand_min_count__int' as attribute,
        'Number' as data_type,
        cast(count(distinct brand_text) as string) as account_value,
    from {{ ref('output_filtered') }}

)

select * from brand_count