with pullover_cat_split as (

    select *
    from {{ ref('int_product_type_append') }}
    cross join unnest (split(split_product_type, ' ') ) as product_type_short
    where 
      split_product_type like '%Pullover%'
      or split_product_type like '%Freizeitjacken%'
      or split_product_type like '%Hooks%'

),

and_split as (

  select *
  from {{ ref('int_product_type_append') }}
  cross join unnest ( split(split_product_type, '& ') ) as product_type_short
  where split_product_type like '%&%'

),

rest as (

    select 
        *,
        split_product_type as product_type_short
    from {{ ref('int_product_type_append') }}
    where  
        split_product_type not like '%Pullover%'
        and split_product_type not like '%Freizeitjacken%'
        and split_product_type not like '%Hooks%'
        and split_product_type not like '%&%' 

),

joined_intermediate_model as (

  select * from rest
  union all
  select * from pullover_cat_split
  union all
  select * from and_split

)

select distinct * except(split_product_type)
from joined_intermediate_model
where split_product_type is not null