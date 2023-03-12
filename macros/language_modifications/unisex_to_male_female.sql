-- unisex products (e.g. mittens) are displayed for both, male and female products
-- therefore we change unisex to male and female

{% macro unisex_to_male_female(base_country, column_name) %}

(
    if( {{base_country}} = 'de' and {{column_name}} = 'Unisex', 'Damen,Herren', 
            if ({{base_country}} = 'nl' and {{column_name}} = 'Unisex', 'Dames,Heren', {{column_name}}))
)


{% endmacro %}

