select *
from {{ source('feed_campaign_product_data', 'bz_model_types') }}