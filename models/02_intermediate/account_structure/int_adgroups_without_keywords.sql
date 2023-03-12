with adgroups_without_keywords as (

    select
        customer_id_hyphens,
        campaign_id, 
        campaign_name, 
        adgroup_id, 
        adgroup_name,
        keyword_count,
        adgroup_status
    from {{ ref('int_adgroups_and_keyword_count') }}
    where 
        keyword_count = 0
        and adgroup_status = 'ENABLED'

)

select * from adgroups_without_keywords