select 
    *
from {{ source('feed_campaign_product_data', 'bz_matchtypes_by_country') }}