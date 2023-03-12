with adgroups_enabled_with_template as (

    select distinct
        customer_id,
        'Ad group' as row_type,
        'Edit' as action,
        'Enabled' as adgroup_status,
        campaign_name as campaign,
        adgroup_name as ad_group
    from {{ ref('adgroups_enable') }}
)

select * from adgroups_enabled_with_template    