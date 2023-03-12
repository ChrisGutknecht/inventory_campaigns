with sitelinks as (

    select * 
    from {{ ref('top_20_by_brand_output') }}

)

select * from sitelinks