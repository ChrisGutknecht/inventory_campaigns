# Welcome to the Bergzeit inventory campaign project documentation! 

## High-level description: What is this repository about?

This repository takes item-level product data and performs SQL transformations to generate bulk uploads formats for specific Google Ads entities such as campains, adgroups, keywords etc. This documentation describes all necessary business logic in SQL and configuration in YAML to perform the necessary transformations. All code was written by the Bergzeit Analytics and Performance team, primarily Christopher Gutknecht and Stephanie Hubert. The content includes all data lineage from source to output, the SQL code, column descrition


For a PPC introduction, reference this SMX deck: 
https://www.slideshare.net/ChristopherGutknecht/scaling-search-campaigns-with-bulk-uploads-and-ad-customizers-smx-2023

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

1. Have your dbt cloud account setup and connect your datawarehouse. For BigQuery, see here: https://docs.getdbt.com/reference/warehouse-setups/bigquery-setup
2. Clone the github repository into your dbt cloud project: https://github.com/ChrisGutknecht/inventory_campaigns

3. Configure you ```dbt_project.yml``` file in the following way:

*Basic configuration* 

Under ```models``` > ```01_staging```, set the ```project``` attribute to your Google cloud project and ```dataset``` to you BigQuery dataset for the following subfolders: 

*```account_structure```. The staging tables storage destination for your account structure.

*```ad_templates```. The staging tables for your ad template source.

*```feed_data```.The staging tables  for your product feed data.

*```lookup_tables```. The staging tables for your product feed data.

*```seo_data```. The staging tables for your search console data.

*```validated_keywords```. The staging tables for your keywords validated from the suggest API.

Note that ```materialized: view``` guarantees that all tables always up-to-date. The alternative materialization ```materialized: "{{ 'view' if env_var('DBT_ENVIRON_FEED') == 'ci' else 'table' }}"``` will materialize the table in the production environment but keep a view table for the continuous integration environment.

Advanced configuration:
- you can update the default path values under if necessary.
- there is a deactived on-run-end command for storing test results. This can be helpful if you want to generate a history of failed and successful tests.

4. Review your ```packages.yml``` file. 

The repo currently leverages 
- ```dbt_utils``` for syntactical abstractions and tests, 
- ```dbt_expectations``` for data quality tests and 
- ```codegen``` for more scalable documentation.

After reviewing the required packages, run the ```dbt deps``` to install the packages, which can be seen in the dbt_packages folder.

5. Data source configuration

Open the source yaml files for every staging folder mentioned in 3.1. and configure your source tables. 

Example for ```01_staging``` > ``````account_structure```:
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


Optional configuration

## Where can I find the REPORT OVERVIEW? (Wo gehts zur Reportübersicht?)

Scroll down to exposures and open the *dashboards* folder. There you will find all documented dashboards in Data Studio and PowerBI.

---

## How is this documentation generated?

The dbt cloud framework provides an *auto-generated* documentation, based on daily jobs. 
The changes to sql, yaml or markdown files are processed through Gitlab versioning, see reference links below.

## Who are the maintainers of this documentation? 

- Stephanie Hubert
- Helena Steurer 
- Christopher Gutknecht

---

## In which JIRA project is the work being done?

The analytics team uses the ['WEBA' or Data Services](https://bergzeit.atlassian.net/jira/software/c/projects/WEBA/boards/81) project and ticket-based branches to make changes to the repository and documentation.
The ['MEAS' or Measurement](https://bergzeit.atlassian.net/jira/software/c/projects/MEAS/boards/4) also contains some tasks.

Every new developed model should have minimum tests and documentation

--- 

## dbt documentation OVERVIEW: https://inventory-campaigns-bergzeit-demo.netlify.app/#!/overview

If you have any further question, please reach by raising an issue or reach out via Linkedin: https://www.linkedin.com/in/chrisgutknecht/ 

Christopher

👋
