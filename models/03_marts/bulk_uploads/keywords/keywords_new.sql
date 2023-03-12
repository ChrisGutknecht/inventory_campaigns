with adgroups_from_feed as (

    select distinct
        split(target_campaign, '_')[safe_offset(0)] as country,
        target_campaign,
        target_ad_group,
        keyword_full_text as keyword,
        case 
            when model_typ = 'exact' then 'Exact match'
            when model_typ = 'phrase' then 'Phrase match'
            when model_typ = 'bmm' then 'Phrase match'
        end as match_type,
    from {{ ref('output_filtered') }}

),

adgroups_without_keywords as (

    select
        customer_id_hyphens as customer_id,
        campaign_name,
        adgroup_name
    from {{ ref('int_adgroups_without_keywords') }}

    /* performs select distinct on the union */
    union all

    /* add keywords for new adgroups, after adgroups are created */
    select
        customer_id,
        campaign_name,
        adgroup_name
    from {{ ref('adgroups_new') }}
    
),

adgroups_from_feed_without_keywords as (

    select
        {{ get_account_id_by_country(country) }} as customer_id,
        feed.country, 
        feed.target_campaign as campaign_name,
        feed.target_ad_group as adgroup_name,
        /* removing characters that are forbidden in Ads keywords */
        {{ replace_special_characters(keyword) }} as keyword, 
        feed.match_type
    from adgroups_from_feed as feed
    left join adgroups_without_keywords as account on
        feed.target_campaign = account.campaign_name 
        and feed.target_ad_group = account.adgroup_name
    /* find those adgroups that exist but dont have keywords */
    where adgroup_name is not null
        

)

select * from adgroups_from_feed_without_keywords