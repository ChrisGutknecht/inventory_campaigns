with adgroups_with_status_changes as (

    select *
    from {{ ref('adgroups_enable_upload') }}

    union all

    select *
    from {{ ref('adgroups_pause_upload') }}

)

select * from adgroups_with_status_changes