with adgroups_from_feed as (

    select distinct
        split(target_campaign, '_')[safe_offset(0)] as country,
        target_campaign,
        target_ad_group
    from {{ ref('output_filtered') }}

),

adgroups_from_account as (

    select
        customer_id_hyphens,
        campaign_name,
        adgroup_name,
        adgroup_status
    from {{ ref('int_adgroups_and_status') }}
    
), 

adgroups_new_from_feed as (

    select
        {{ get_account_id_by_country(country) }} as customer_id,
        country, 
        feed.target_campaign as campaign_name,
        feed.target_ad_group as adgroup_name
    from adgroups_from_feed as feed
    left join adgroups_from_account as account on
        feed.target_campaign = account.campaign_name 
        and feed.target_ad_group = account.adgroup_name
    where account.adgroup_name is null

)

select * from adgroups_new_from_feed