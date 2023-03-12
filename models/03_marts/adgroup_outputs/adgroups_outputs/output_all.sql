with output_all as (

    select * from {{ ref('brand_all') }}

    union all

    select * from {{ ref('brand_cat_all') }}

    union all
    
    select * from {{ ref('brand_gender_all') }}

    union all

    select * from {{ ref('brand_mod_all') }}

    union all
    
    select * from {{ ref('cat_all') }} 

)


select
    {{ dbt_utils.surrogate_key(['country', 'target_campaign', 'target_ad_group']) }} as sk_id,
    *
from output_all