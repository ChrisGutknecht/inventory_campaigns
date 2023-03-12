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
    where campaign_status = 'PAUSED'
    
), 

campaigns_from_feed_to_be_enabled as (

    select
        customer_id_hyphens,
        country, 
        target_campaign as campaign_name
    from campaigns_from_feed as feed
    inner join campaigns_from_account as account on
        feed.target_campaign = account.campaign_name

)

select * from campaigns_from_feed_to_be_enabled