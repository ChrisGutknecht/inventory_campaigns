with current_year as (

      select 
        'year__text' as attribute,
        'Text' as data_type,
        cast(extract(year from current_date()) as string) as account_value

)

select * from current_year