with keywords_new_upload as (
    
    select 
        customer_id,
        'Add' as action,
        campaign_name as campaign, 
        adgroup_name as ad_group,
        keyword,
        match_type as type,
        'feed_keywords_bulk_upload' as label
    from {{ ref('keywords_new') }}

    union all

    select 
        customer_id,
        'Add' as action,
        campaign_name as campaign, 
        adgroup_name as ad_group,
        {{ replace_special_characters(keyword) }} as keyword,
        match_type as type,
        'feed_keywords_bulk_upload' as label
    from {{ ref('keywords_missing_in_non_feed_adgroups') }}

)

select * 
from keywords_new_upload
where {{ filter_keywords_with_policy_violations(keyword) }}