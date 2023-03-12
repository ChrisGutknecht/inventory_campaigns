with keywords_and_parent_statuses as ( 

    select
        {{ convert_account_id_to_hyphen(customer_id) }} as customer_id_hyphens,
        customer_id,
        criterion_id,
        keyword,
        criterion_status,
        campaign_name,
        campaign_id,
        campaign_status,
        adgroup_name,
        adgroup_id,
        adgroup_status,
        match_type,
        is_negative,
        status_serving,
        status_approval,
        quality_score,
        quality_score_post_click
    from {{ source('account_structure', 'gads_keywords_and_parent_statuses') }}
    where
        {{ filter_feed_adgroups() }}

)

select * from keywords_and_parent_statuses