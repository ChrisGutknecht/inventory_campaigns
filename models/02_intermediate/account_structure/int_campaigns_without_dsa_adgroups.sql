with campaigns as (

    select
        customer_id_hyphens,
        customer_id,
        campaign_id,
        campaign_name,
        campaign_status
    from {{ ref('int_campaigns_and_status') }}

), 

campaigns_and_brand_names as (

    select distinct
        target_campaign as campaign_name,
        brand_text as brand
    from {{ ref('output_all') }}

),

campaigns_with_dsa_adgroups as (

    select 
        campaign_id,
        sum(dsa_ad_count) as dsa_ad_count
    from {{ ref('int_campaigns_with_dsa_adgroups') }}
    group by 1

), 

campaigns_without_dsa_adgroups as (

    select
        customer_id_hyphens,
        customer_id,
        campaign_id,
        campaign_name,
        brand
    from campaigns
    left join campaigns_with_dsa_adgroups using (campaign_id)
    left join campaigns_and_brand_names using (campaign_name)
    where 
        dsa_ad_count is null
        and campaign_status = 'ENABLED'

)

select * from campaigns_without_dsa_adgroups