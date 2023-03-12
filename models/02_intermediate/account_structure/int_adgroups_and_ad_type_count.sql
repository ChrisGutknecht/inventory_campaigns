with adgroups as (

    select
        customer_id_hyphens,
        campaign_id,
        campaign_name,
        adgroup_id,
        adgroup_name
    from {{ ref('stg_gads_adgroups') }}

),


adgroup_ids_and_ad_types as (

    select
        adgroup_id,
        countif(ad_type = 'RESPONSIVE_SEARCH_AD') as rsa_count,
        countif(ad_type != 'RESPONSIVE_SEARCH_AD') as nonrsa_count
    from {{ ref('stg_gads_ads_and_attributes') }}
    group by 1
    
), 

adgroup_and_ad_types as (

    select
        customer_id_hyphens,
        campaign_id,
        campaign_name,
        adgroup_id,
        adgroup_name,
        coalesce(rsa_count,0) as rsa_count,
        coalesce(nonrsa_count,0) as nonrsa_count
    from adgroups
    left join adgroup_ids_and_ad_types using (adgroup_id)

)

select * from adgroup_and_ad_types