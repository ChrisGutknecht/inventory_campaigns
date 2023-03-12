with campaigns_paused_with_template as (

    select
        customer_id_hyphens as customer_id,
        'Campaign' as row_type,
        'Edit' as action, 
        'Paused' as campaign_status,
        /* campaign_id */
        campaign_name as campaign,
        /* label */
    from {{ ref('campaigns_pause') }}

)

select * from campaigns_paused_with_template