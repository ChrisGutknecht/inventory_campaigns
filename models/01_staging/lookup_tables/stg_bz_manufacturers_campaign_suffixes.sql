select 
    trim(brand) as m_brand,
    CampName
from {{ source('feed_campaign_product_data', 'manufacturer_campaign_suffixes') }}
where brand is not null