with adgroups_new_with_upload_format as (

    select distinct
        customer_id,
        'Add' as action,
        campaign_name as campaign,
        adgroup_name as ad_group,
        'Standard' as ad_group_type,
        /* label */
    from {{ ref('adgroups_new') }}
    where 
        customer_id != '_no_id'
        and campaign_name is not null

    /* union all

    select *
    from {{ ref('dsa_adgroup_upload') }}*/

)

select * from adgroups_new_with_upload_format