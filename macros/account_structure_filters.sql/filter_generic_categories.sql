{% macro filter_generic_categories() %}

    nr_models_text >= 2
    and product_type_short is not null
    and length(product_type_short) > 5
    and product_type_level1 != 'Accessoires'
    and lower(trim(product_type_short)) not in (
        'jacken', 'hoodies', 'shirts', 'pullover', 'outdoor', 'kulturbeutel', 'trink-', 'einteiler', 'hochtour', 'jumpsuits',
        'basics', 'rucksäcke', 'westen', 'trink-', 't-shirts', 'tanktops', 'brillen', 'kleid', 'kleider', 'inlets',
        'tights', 'leggings', 'unterhosen', 'sandalen', 'kurze hosen', 'helme', 'kühlboxen', 'kulturtaschen', 'schutzhüllen',
        'elektronik', 'hemden', 'jeans', 'blusen', 'lampen', 'overalls', 'parkas', 'mäntel', 'messer', 'werkzeuge',
        'bikinis', 'energie', 'behälter', 'friends', 'trolleys', 'rollkoffer', 'bürsten', 'feldbetten', 'taschen'
    )
    and lower(product_type_short) not like '%zubehör%'
    and lower(product_type_short) not like '%unterhosen%'
    and lower(product_type_short) not like '%ersatzteile%'
    and lower(product_type_short) not like '%bade%'
    and lower(product_type_short) not like '%freizeit%'

{% endmacro %}