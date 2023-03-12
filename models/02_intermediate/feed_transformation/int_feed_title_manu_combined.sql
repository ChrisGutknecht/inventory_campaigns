select 
    * except (t_id, m_brand),
    lower(concat(brand_text, '_', title_level2)) as brand_title,
    lower(concat(brand_text, '_', trim(product_type_short))) as brand_cat,
    if(regexp_contains(campname, '__A|__B'), concat(CampName, ' (Top)'), concat(CampName, ' (Other)')) as target_campaign_prev,
    trim({{ text_to_singular('product_type_level1') }}) as product_type_level1_singular,
    trim({{ text_to_singular('product_type_short') }}) as product_type_short_singular,
    {{ text_to_singular('title_level1') }} as title1_singular,
    {{ text_to_singular('title_level2') }} as title2_singular
from {{ ref('int_product_type_corrections') }} as feed

left join {{ ref('stg_bz_title_data_all') }} as title
    on feed.id = title.t_id

left join {{ ref('stg_bz_manufacturers_campaign_suffixes') }} as man
    on feed.brand = man.m_brand