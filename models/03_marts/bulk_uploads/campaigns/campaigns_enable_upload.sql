with campaigns_enabled_with_template as (

    select
        customer_id_hyphens as customer_id,
        'Campaign' as row_type,
        'Edit' as action, 
        'Enabled' as campaign_status,
        /* campaign_id */
        campaign_name as campaign,
        /* label */
    from {{ ref('campaigns_enable') }}

)

select * from campaigns_enabled_with_template