{% macro convert_account_id_to_hyphen(customer_id) %}

concat(left(cast(customer_id as string), 3), '-', substr(cast(customer_id as string), 4, 3), '-', right(cast(customer_id as string), 4))

{% endmacro %}