with adgroups_without_keywords as (

    select
        customer_id_hyphens as customer_id,
        campaign_name,
        adgroup_name, 
    from {{ ref('int_adgroups_without_keywords') }}
    
), 

adgroups_from_feed as (

    select distinct
        split(target_campaign, '_')[safe_offset(0)] as country,
        target_campaign,
        target_ad_group,
    from {{ ref('output_filtered') }}

),

adgroups_without_keywords_and_no_feed_info as (

    select
        -- extract country first, then pass into macro
        account.customer_id,
        {{ extract_country_from_campaign(campaign_name) }} as country, 
        campaign_name,
        adgroup_name,
        /* removing characters that are forbidden in Ads keywords */
        {{ extract_keyword_from_adgroup(adgroup_name) }} as keyword, 
        {{ extract_matchtype_from_adgroup(adgroup_name) }} as match_type, 
    from adgroups_without_keywords as account
    left join adgroups_from_feed as feed on
        account.campaign_name = feed.target_campaign 
        and feed.target_ad_group = account.adgroup_name
    /* find those adgroups that exist but dont have keywords, while the campaign should have stock */
    where 
        target_campaign is not null 
        and target_ad_group is null

)

select * from adgroups_without_keywords_and_no_feed_info