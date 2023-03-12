with campaigns_and_status as (

    select 
        {{ convert_account_id_to_hyphen(customer_id) }} as customer_id_hyphens,
        customer_id,
        campaign_id,
        campaign_name,
        campaign_status,
        brand
    from {{ source('account_structure', 'gads_campaigns_and_status') }}
    where {{ filter_feed_campaigns() }}

)

select * from campaigns_and_status