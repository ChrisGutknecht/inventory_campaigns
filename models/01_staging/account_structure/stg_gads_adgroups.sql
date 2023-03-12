with adgroups_and_status as (

    select 
        {{ convert_account_id_to_hyphen(customer_id) }} as customer_id_hyphens,
        /* get yesterday's date and one hour before midnight for recent data test */
        timestamp_sub(timestamp(current_date("Europe/Berlin")), interval 1 hour) as date,
        *
    from {{ source('account_structure', 'gads_adgroups_and_status') }}
    where
        {{ filter_feed_adgroups() }}
        and {{ filter_feed_campaigns() }}

)

select * from adgroups_and_status