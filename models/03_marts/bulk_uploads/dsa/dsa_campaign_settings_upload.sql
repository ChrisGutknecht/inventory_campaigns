with dsa_campaign_settings_upload as (
    
    select
        customer_id_hyphens as customer_id,
        'Add' as action,
        campaign_name as campaign,
        concat('www.bergzeit.', lower({{ extract_country_from_campaign(campaign) }})) as dsa_website
    from {{ ref('int_campaigns_without_dsa_adgroups') }}

)

select * from dsa_campaign_settings_upload