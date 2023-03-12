with campaigns_with_dsa_adgroups as ( 

    select
        customer_id_hyphens,
        campaign_name,
        campaign_id,
        campaign_status,
        adgroup_name,
        if(lower(adgroup_name) like '%dsa%', true, false) as adgroup_name_contains_dsa,
        adgroup_id,
        adgroup_status,
        count(if(ad_type = 'EXPANDED_DYNAMIC_SEARCH_AD', 1, 0)) as dsa_ad_count
    from {{ ref('stg_gads_dsa_ads_and_attributes') }}
    {{ dbt_utils.group_by(n=8) }}

)

select * from campaigns_with_dsa_adgroups