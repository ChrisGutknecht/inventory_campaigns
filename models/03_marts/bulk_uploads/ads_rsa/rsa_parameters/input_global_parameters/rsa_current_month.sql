with current_month_english as (

    select 
        'month_long__text' as attribute,
        'Text' as data_type,
        cast(format_date('%B', current_date()) as string) as month_english

),

current_month_german as (

    select
        attribute,
        data_type,
        {{ change_month_name_to_german('month_english') }} as account_value
    from current_month_english

)

select * from current_month_german