with keywords as (

    select *
    from {{ ref('stg_gads_keywords_and_attributes') }}

)

select * from keywords