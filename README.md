# Welcome to the Bergzeit inventory campaign project documentation! 

## High-level description: What is this repository about?

This repository takes item-level product data and performs SQL transformations to generate bulk upload formats for specific Google Ads entities such as campains, adgroups, keywords etc. This documentation describes all necessary business logic in SQL and configuration in YAML to perform the necessary transformations. All code was written by the Bergzeit Analytics and Performance team, primarily Christopher Gutknecht and Stephanie Hubert. The content includes all data lineage from source to output, the SQL code, meta data description and configured data tests implemented in the dbt framework.

For a PPC introduction, reference this SMX deck: 

https://www.slideshare.net/ChristopherGutknecht/scaling-search-campaigns-with-bulk-uploads-and-ad-customizers-smx-2023

An interactive documentation of the project can be explored here:
https://inventory-campaigns-bergzeit-demo.netlify.app/#!/overview

<img width="361" alt="dbt_bz" src="https://user-images.githubusercontent.com/6991865/225361573-008c683f-8dee-4f0e-b3d8-bdac0afab6af.png">

---

## Prerequisites: Which skills and tools do I need to implement this framework?

This repository builds on the *dbt* (data build tool) framework, the industry standard for large scale SQL transformation in modern data warehouses. 

- You need solid working *knowledge of SQL* (or a data team) to model your data transformation of product item inventory
- For an introduction to the dbt framework, see here: https://www.getdbt.com/blog/what-exactly-is-dbt/
- To learn the necessary fundamentals of dbt, see this course: https://courses.getdbt.com/courses/fundamentals
- To get startetd with *dbt cloud* (recommended for beginners), see here: https://docs.getdbt.com/docs/get-started/dbt-cloud-features

For a dbt cloud project, you will need to connect 1) a *data warehouse* (BigQuery recommended) and 2) a *version control system* (github recommended)

---

## Installation: How can I setup inventory-driven PPC campaigns?

This is a step-by-step guide to setup the inventory campaign project:

1. Have your dbt cloud account setup and connect your data warehouse. For BigQuery, see here: https://docs.getdbt.com/reference/warehouse-setups/bigquery-setup
2. Clone the github repository into your dbt cloud project: https://github.com/ChrisGutknecht/inventory_campaigns

If you've successfully cloned the github repo above, your own github repo should populate with a set of six folder and further config files. The next steps build on having the repo successfully installed:

3. Configure you ```dbt_project.yml``` file in the following way:

3.1. Basic configuration

Under ```models``` > ```01_staging```, set the ```project``` attribute to your Google cloud project and ```dataset``` to you BigQuery dataset for the following subfolders: 

- ```account_structure```. The staging tables storage destination for your account structure. In the current implementation the used source tables are not the original Google Ads Transfer source tables, but already joined marts tables built in a different project. We might add these previous transformation steps to the project at a later stage.

- ```ad_templates```. The staging tables for your ad template source.

- ```feed_data```.The staging tables  for your product feed data.

- ```lookup_tables```. The staging tables for your product feed data.

- ```seo_data```. The staging tables for your search console data.

- ```validated_keywords```. The staging tables for your keywords validated from the suggest API.

Note that ```materialized: view``` guarantees that all tables are always up-to-date. The alternative materialization ```materialized: "{{ 'view' if env_var('DBT_ENVIRON_FEED') == 'ci' else 'table' }}"``` will materialize the model as a table in the production environment but keep a view table for the continuous integration environment for easy CI/CD checks on pull requests.

3.2. Advanced configuration

- you can update the default path values under if necessary.
```
model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]
```
- there is a deactived on-run-end command for storing test results. This can be helpful if you want to generate a history of failed and successful tests. More on run hooks here: https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end
```
on-run-end:
  # - "{% if env_var('DBT_ENVIRON_FEED') == 'prod' %} {{ store_test_results(results)}} {% endif %}"
```

4. Review your ```packages.yml``` file. 

The repo currently leverages the following packages: 
- ```dbt_utils``` for syntactical abstractions and tests, 
- ```dbt_expectations``` for data quality tests and 
- ```codegen``` for more scalable documentation.

After reviewing the required packages, run the ```dbt deps``` to install the packages, which can be seen in the dbt_packages folder. The existing package list can be easily extended: https://docs.getdbt.com/docs/build/packages

5. Data source configuration

Open the ```_source_*.yml``` files for every staging folder mentioned in 3.1. and configure your source tables. 

Example for ```01_staging``` > ```account_structure```:
- ```database``` represents the Google cloud project
- ```schema``` represents the Google BigQuery dataset
- ```tables``` > ```name``` is the source table name. This can take an additional ```identifier``` parameter for a nicer table name in your source reference.

```
sources:
  - name: account_structure
    database: bergzeit
    schema: dbt_sea_analytics
    description: The status of current Google Ads entities per country

    tables:
      - name: gads_ads_and_parent_statuses
        description: the status of ads, adgroups and campaigns
````

Change the three attribute values for ```database```, ```schema```, ```tables```. 

6. Macro configuration

In the ```macros``` folder, there are three subfolders with the following purposes:
- ```account_structure_filters```. These statements contain all customized filter statements that define the synchronisation scope for the inventory campaigns.
- ```language_modifications```. This is an extensible collection for multi-language setups. 
- ```other_text_modifications```. This is a collection of various, necessary text modifications based on Google Ads' character restrictions

## How do I make sure my setup and code generates high-quality outputs? 

Go through three the layers of dbt models step by step: 

For ```01_staging```, make sure all stage models build without errors and all data tests pass. You can extend tests to your needs.

In ```02_intermediate```, there are two subfolders that need to correctly return intermediate data outputs: 
- ```account_structure``` contains all the account entities and their states, in some cases including statistics to add to the filter model.
- ```feed_transformation``` holds all transformations from extending the product input data into a usable form to aggregate by different attributes. ```int_feed_title_manu_combined.sql``` is the last model on item-level before the transformations happen.

In the ```03_marts``` folder, all the custom aggregations happen, which are then combined to one model with all combinations. All 5 currently supported combinations are condensed into the following models: 
- ```brand_all``` holds all current brands in stock as keywords / adgroups
- ```brand_cat_all``` holds all brand category combinations, e.g. Patagonia jackets.
- ```brand_gender_all``` holds all combinations like Patagonia women.
- ```brand_mod_all``` holds all brand product model combinations, like Patagonia R1.
- ```cat_all``` holds all brand-agnostic category values like down jackets, climbing shoes etc.

- ```output_all``` is the essential model holding all unioned combinations mentioned above
- ```output_enriched``` adds the data sources suggest API, search console and keyword serving status from the account

The main model flow of combinining, enriching and filtering can be seen here in this dbt graph:
<img width="458" alt="image" src="https://user-images.githubusercontent.com/6991865/225435848-4112c8f6-e787-400b-8561-148f030cf1f1.png">

## Is there a documentation website that I can explore?

The dbt cloud framework provides an *auto-generated* documentation that is exported to Netlify:
https://inventory-campaigns-bergzeit-demo.netlify.app/#!/overview

## Who are the maintainers of this project? 

- Stephanie Hubert: https://github.com/shubert-bz
- Christopher Gutknecht: https://github.com/ChrisGutknecht

--- 


If you have any further question, please reach by raising an issue on github or reach out via Linkedin: 
https://www.linkedin.com/in/chrisgutknecht/ 

Happy building and optimizing, 
Chris👋
