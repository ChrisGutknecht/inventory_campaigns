with ads_and_parent_statuses as ( 

    select
        {{ convert_account_id_to_hyphen(customer_id) }} as customer_id_hyphens,
        customer_id,
        creative_id,
        ad_type,
        ad_status,
        campaign_name,
        campaign_id,
        campaign_status,
        adgroup_name,
        adgroup_id,
        adgroup_status
    from {{ source('account_structure', 'gads_ads_and_parent_statuses') }}
    where 
        ad_type = 'EXPANDED_DYNAMIC_SEARCH_AD'
        and cast(customer_id as string) in ('7844181130', '5575738585', '1845331214')
        and campaign_name not like '%zz_inactive%'

)

select * from ads_and_parent_statuses