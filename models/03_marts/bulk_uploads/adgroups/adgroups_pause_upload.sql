with adgroups_pause_with_upload_format as (

    select distinct
        customer_id_hyphens as customer_id,
        'Ad group' as row_type,
        'Edit' as action,
        'Paused' as adgroup_status,
        campaign_name as campaign,
        adgroup_name as ad_group
    from {{ ref('adgroups_pause') }}
)

select * from adgroups_pause_with_upload_format