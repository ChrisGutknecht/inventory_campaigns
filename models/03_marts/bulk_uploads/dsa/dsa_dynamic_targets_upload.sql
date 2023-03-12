with dsa_dynamic_targets_upload as (
    
    select
        customer_id_hyphens as customer_id,
        'Add' as action,
        campaign_name as campaign,
        concat(lower(brand), ' | DSA') as ad_group,
        'Dynamic' as ad_group_type,
        'URL' as dynamic_ad_target_condition_1,
        lower(brand) as dynamic_ad_target_value_1, 
        'PAGE_TITLE' as dynamic_ad_target_condition_2,
        lower(brand) as dynamic_ad_target_value_2
    from {{ ref('int_campaigns_without_dsa_adgroups') }}

) 

select * from dsa_dynamic_targets_upload