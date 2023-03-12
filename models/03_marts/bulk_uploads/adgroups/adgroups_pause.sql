with adgroups_from_account as (

    select
        customer_id_hyphens,
        campaign_id,
        campaign_name,
        adgroup_id,
        adgroup_name,
        adgroup_status,
        clicks, 
        impressions
    from {{ ref('int_adgroups_and_status') }}
    where adgroup_status = 'ENABLED'

), 

adgroups_from_feed as (

    select distinct
        split(target_campaign, '_')[safe_offset(0)] as country,
        target_campaign,
        target_ad_group
    from {{ ref('output_filtered') }}

), 


adgroups_not_in_feed as (

    select *
    from adgroups_from_account as account 
    left join adgroups_from_feed as feed on
        account.campaign_name = feed.target_campaign
        and account.adgroup_name = feed.target_ad_group
    where
        /* 1. Condition: pause adgrous not found in feed */
        target_ad_group is null

        /* 2. Condition: don't pause if adgroup is type BC with min traffic */
        and not (
            adgroup_name like '%Feed_BC%'
            and clicks > 0
        )

        /* 3. Condition: don't pause if adgroup is out of feedcampaign scope with min traffic */
        and not (
            adgroup_name not like '%Feed_BM%' 
            or adgroup_name not like '%Feed_BC%'
            and clicks > 0
        )

)

select * from adgroups_not_in_feed