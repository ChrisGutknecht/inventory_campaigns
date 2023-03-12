with validated_keywords as (

    select
        keyword, 
        validation_status, 
        if(validation_status = true, 100, similarity_to_next_validated) as similarity_to_next_validated
    from {{ source('ads_analytics', 'validated_keywords') }}

)

select * from validated_keywords