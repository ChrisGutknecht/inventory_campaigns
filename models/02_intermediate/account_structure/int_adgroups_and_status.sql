with adgroups_and_statuses as (

    select
        customer_id_hyphens,
        campaign_id,
        campaign_name,
        campaign_status,
        adgroup_name,
        adgroup_id,
        adgroup_status,
        clicks, 
        impressions
    from {{ ref('stg_gads_adgroups') }}

)

select * from adgroups_and_statuses