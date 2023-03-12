with ads_and_parent_statuses as ( 

    select
        {{ convert_account_id_to_hyphen(customer_id) }} as customer_id_hyphens,
        creative_id,
        ad_type,
        ad_status,
        campaign_name,
        campaign_id,
        campaign_status,
        adgroup_name,
        adgroup_id,
        adgroup_status
    from {{ source('account_structure',  'gads_ads_and_parent_statuses') }}
    where  
        {{ filter_feed_adgroups() }}
        and {{ filter_feed_campaigns() }}


)

select * from ads_and_parent_statuses