with feed_keywords as (

    select distinct keyword_full_text as keyword
    from {{ ref('output_all') }}
    where country in ('DE', 'AT', 'CH')

), 

validated_keywords as (

    select
        keyword, 
        validation_status
    from {{ ref('stg_validated_keywords') }}

), 

keywords_to_be_validated as (

    select distinct
        keyword,
        validation_status
    from feed_keywords
    left join validated_keywords using (keyword)
    where validation_status is null

)

select * from keywords_to_be_validated