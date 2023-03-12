with campaigns_and_statuses as (

    select
        customer_id_hyphens,
        customer_id,
        campaign_id,
        campaign_name,
        campaign_status,
        brand
    from {{ ref('stg_gads_campaigns') }}

)

select * from campaigns_and_statuses