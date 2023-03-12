with campaigns_new_with_upload_format as (

    select
        customer_id,
        'Campaign' as row_type,
        'Add' as action,
        'Enabled' as campaign_status,
        campaign_name as campaign,
        'Search' as campaign_type,
        'Google search;Search partners' as networks,
        '100' as budget,
        'Maximize Conversion Value' as bid_strategy_type,
        bid_strategy,
        'de;en' as language,
        {{ map_country_code_to_country_name(country) }} as location
        /* label */
    from {{ ref('campaigns_new') }}
)

select * from campaigns_new_with_upload_format