with current_season as (

      select 
        'season_de__text' as attribute,
        'Text' as data_type,
        case
            when cast(format_date('%m', current_date()) as INT64) > 12 and cast(format_date('%m', current_date()) as INT64) < 3 then 'Winter'
            when cast(format_date('%m', current_date()) as INT64) > 2 and cast(format_date('%m', current_date()) as INT64) < 5 then 'Frühling'
            when cast(format_date('%m', current_date()) as INT64) > 4 and cast(format_date('%m', current_date()) as INT64) < 9 then 'Sommer'
            else 'Herbst'
        end as account_value

)

select * from current_season