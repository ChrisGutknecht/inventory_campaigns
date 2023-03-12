with dsa_adgroup_upload as (
    
    select
        customer_id_hyphens as customer_id,
        'Add' as action,
        campaign_name as campaign,
        concat(lower(brand), ' | DSA') as ad_group,
        'Dynamic' as ad_group_type, 
    from {{ ref('int_campaigns_without_dsa_adgroups') }}
    where 
        cast(customer_id as string) != '_no_id'
        and campaign_name is not null

) 

select * from dsa_adgroup_upload