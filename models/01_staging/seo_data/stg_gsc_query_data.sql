with gsc_query_data_grouped as (

    select
        lower(query) as query, 
        sum(impressions) as impressions, 
        sum(clicks) as clicks
    from {{ source('google_search_console', 'gsc_data') }}
    where
        date > current_date()-365
        and site in ('https://www.bergzeit.de/', 'https://www.bergzeit.at/', 'https://www.bergzeit.ch/')
    group by 1

)

select * from gsc_query_data_grouped