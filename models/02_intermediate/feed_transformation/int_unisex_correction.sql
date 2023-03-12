with all_data as (

    select * 
    from {{ ref('int_feed_title_manu_combined') }}

),

no_unisex as (
    
    select 
        *,
        {{ unisex_to_male_female('base_country', 'gender_cleaned') }} as gender_nounisex
    from all_data

),

split_data as (

    select 
        * except (gender_cleaned),
        split(gender_nounisex,',') as split_gender_nounisex
    from no_unisex
    
), 

cross_joined_data as (

    select * except (gender_nounisex) 
    from split_data
    cross join unnest(split_gender_nounisex) as gender_cleaned
    where {{ exclude_equipment('product_type_level1') }}

)

select * from cross_joined_data