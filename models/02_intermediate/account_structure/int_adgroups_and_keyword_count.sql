with adgroups as (

    select
        customer_id_hyphens,
        campaign_id,
        campaign_name,
        adgroup_id,
        adgroup_name,
        adgroup_status
    from {{ ref('stg_gads_adgroups') }}

),


adgroup_ids_and_keyword_count as (

    select
        adgroup_id,
        count(criterion_id) as keyword_count,
    from {{ ref('stg_gads_keywords_and_attributes') }}
    group by 1
    
),

adgroups_with_keyword_count as (

    select
        customer_id_hyphens,
        adgroup_id,
        campaign_id,
        campaign_name,
        adgroup_name,
        adgroup_status,
        coalesce(keyword_count, 0) as keyword_count 
    from adgroups
    left join adgroup_ids_and_keyword_count using (adgroup_id)

)

select * from adgroups_with_keyword_count