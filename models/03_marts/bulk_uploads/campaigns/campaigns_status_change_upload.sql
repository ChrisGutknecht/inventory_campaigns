with campaign_with_status_changes as (

    select * 
    from {{ ref('campaigns_enable_upload') }}

    union all

    select * 
    from {{ ref('campaigns_pause_upload') }}

)

select * from campaign_with_status_changes