with adgroups_without_rsas as (

    select
        customer_id_hyphens,
        campaign_id, 
        campaign_name, 
        adgroup_id,
        adgroup_name,
        rsa_count
    from {{ ref('int_adgroups_and_ad_type_count') }}
    where rsa_count = 0

)

select * from adgroups_without_rsas