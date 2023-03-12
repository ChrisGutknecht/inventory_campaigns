with campaigns_from_feed as (

    select distinct
        split(target_campaign, '_')[safe_offset(0)] as country,
        target_campaign
    from {{ ref('output_filtered') }}

),

campaigns_from_account as (

    select
        customer_id_hyphens,
        campaign_name,
        campaign_status
    from {{ ref('int_campaigns_and_status') }}
    
), 

campaigns_new_from_feed as (

    select
        {{ get_account_id_by_country(country) }} as customer_id,
        feed.country, 
        feed.target_campaign as campaign_name,
        concat(upper(feed.country), '_2_Bucket_Manufacturer') as bid_strategy
    from campaigns_from_feed as feed
    left join campaigns_from_account as account on
        feed.target_campaign = account.campaign_name
    where
        /* campaign name not found in account, thus new */
        account.campaign_name is null

)

select * 
from campaigns_new_from_feed
where customer_id != '_no_id'