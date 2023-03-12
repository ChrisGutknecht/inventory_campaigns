with rsa_ads_new as (

    select distinct
        'Add' as action,
        'Enabled' as ad_status,
        'Responsive search ad' as ad_type,
        'feed_rsas_bulk_upload' as label,
        *

        /* 'Headline 1 position' (to n), not specified yet */	
        /* 'Description 1 position' (to n), not specified yet */

    from {{ ref('rsa_new') }}

)

select * from rsa_ads_new