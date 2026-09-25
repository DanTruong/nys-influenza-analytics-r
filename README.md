# NYS Influenza Analytics — R/Shiny

An R and Shiny application for analyzing and visualizing historical influenza activity across New York State.

This project originated as part of a graduate Biomedical & Health Informatics project completed in 2019. It uses county-level influenza surveillance data from the New York State Department of Health to explore historical influenza activity, geographic patterns, and time-series forecasts.

This repository preserves the original R-based implementation and is currently maintained primarily for compatibility and bug fixes. A separate modern implementation uses Python, PostgreSQL, and Power BI to revisit the project with a contemporary data analytics stack.

## Features

The application provides interactive tools for exploring influenza activity across New York State, including:

- County-level influenza case analysis
- Historical weekly influenza trends
- Geographic visualization of influenza activity across New York State
- Influenza forecasting using time-series models
- Interactive visualizations built with Shiny
- Comparison of influenza activity across counties and reporting periods

## Technology

The project is built primarily with:

- **R** — data preparation, statistical analysis, and forecasting
- **Shiny** — interactive web application
- **Holt-Winters** — seasonal time-series forecasting
- **ARIMA** — time-series forecasting
- **New York State influenza surveillance data** — source dataset

## Project Background

The original project was developed in 2019 as part of graduate work in Biomedical & Health Informatics.

The analysis was designed to combine epidemiological data visualization with time-series forecasting to examine influenza patterns at the county level across New York State.

The original implementation includes data transformation, county-level time-series generation, forecasting, geographic visualization, and an interactive Shiny interface.

## Forecasting

The application uses two approaches for forecasting county-level influenza activity:

### Holt-Winters

Holt-Winters exponential smoothing is used with additive seasonality to model the annual influenza cycle.

The historical implementation uses a 52-week seasonal period and generates forecasts from the training time series.

### ARIMA

ARIMA models are generated from historical county-level influenza time series to provide an additional forecasting approach.

These models represent the methodology used in the original graduate project and are retained in this repository as part of the historical implementation.

## Data

Influenza surveillance data originates from the New York State Department of Health.

The dataset contains weekly influenza observations by county and includes information such as:

- Reporting date
- Influenza season
- County
- Region
- Disease classification
- Case count
- Geographic information

The application transforms these observations into county-level weekly time series used for visualization and forecasting.

## Repository Status

This repository is currently in **maintenance mode**.

The goal is to preserve the original R/Shiny implementation while addressing compatibility issues and bugs where necessary. Major changes to the original analytical methodology are not currently planned.

The project is also being retained as a historical counterpart to a newer implementation built using:

- Python
- PostgreSQL
- Docker
- Power BI

The modern implementation separates data ingestion, relational storage, time-series preparation, forecasting, and business intelligence reporting into a more contemporary analytics workflow.

## Historical Context

Because this project originated in 2019, portions of the code reflect the R programming practices, package ecosystem, and project requirements used at the time.

The repository is intentionally preserved as an example of the original implementation rather than being completely rewritten to follow the architecture of the newer version.

Where maintenance changes are made, the intent is to preserve the behavior and methodology of the original analysis whenever practical.

## Related Project

A modern reimplementation of this analysis is maintained separately as **NYS Influenza Analytics**, using Python for data ingestion and analysis, PostgreSQL for relational storage, Docker for reproducible infrastructure, and Power BI for reporting and visualization.

Together, the two repositories show the evolution of the project from its original R/Shiny implementation to a modern data analytics architecture.

## Current Known Issues

- The New York State geographic map visualization is currently undergoing maintenance due to a rendering issue.

## License

This repository contains code developed for an academic project. Source data remains subject to the terms and policies of its original provider.