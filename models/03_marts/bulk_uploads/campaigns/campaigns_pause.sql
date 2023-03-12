with campaigns_from_account as (

    select
        customer_id_hyphens, 
        campaign_name,
        campaign_status
    from {{ ref('int_campaigns_and_status') }}
    where campaign_status = 'ENABLED'

), 

campaigns_from_feed as (

    select distinct
        split(target_campaign, '_')[safe_offset(0)] as country,
        target_campaign
    from {{ ref('output_filtered') }}
    where country in ('DE','AT','CH')

), 


campaigns_not_in_feed as (

    select *
    from campaigns_from_account as account 
    left join campaigns_from_feed as feed on
        account.campaign_name = feed.target_campaign
    where target_campaign is null

)

select * from campaigns_not_in_feed