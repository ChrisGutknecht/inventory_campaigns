{% macro replace_special_characters( keyword ) %}

    case
        when contains_substr(keyword, '_') then replace(keyword, '_', ' ')
        when contains_substr(keyword, '!') then replace(keyword, '!', ' ')
        when contains_substr(keyword, '!!!') then replace(keyword, '!!!', ' ')
        when contains_substr(keyword, '@') then replace(keyword, '@', ' ')
        when contains_substr(keyword, '%') then replace(keyword, '%', ' ')
        when contains_substr(keyword, ',') then replace(keyword, ',', ' ')
        when contains_substr(keyword, '*') then replace(keyword, '*', ' ')
        when contains_substr(keyword, '°') then replace(keyword, '°', ' ') 
        when contains_substr(keyword, '®') then replace(keyword, '®', ' ')
        when contains_substr(keyword, '™') then replace(keyword, '™', ' ')
        else keyword
    end

{% endmacro %}