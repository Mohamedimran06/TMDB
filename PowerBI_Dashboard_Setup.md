# TMDB Power BI Dashboard Setup

Power BI Desktop is required to create the final `Movie_Dashboard.pbix` file. Connect directly to the MySQL database through **Get Data**. Do not import the CSV files.

## 1. Connect Power BI to MySQL

1. Make sure the MySQL database `TBMD` is running and contains the six cleaned tables.
2. Install the **MySQL Connector/NET** matching your Power BI Desktop bitness, or configure a MySQL ODBC data source.
3. In Power BI Desktop select **Home > Get data > MySQL database**. Enter `localhost` as the server and `TBMD` as the database, then select **Import** and authenticate with your MySQL account.
4. Select only these database tables: `movies`, `genres`, `movie_genres`, `cast`, `crew`, and `movie_keywords`.
5. If using ODBC instead, select **Home > Get data > ODBC**, choose the configured MySQL DSN, and select the same six tables.
6. In Power Query, confirm `movies[release_date]` is Date, IDs are Whole number, budget/revenue are Whole number, and popularity/vote_average are Decimal number. Select **Close & Apply**.

Use **Import** for the dashboard model. This still loads from MySQL, not from the CSV files, and gives better performance for the grouped visuals.

## Data Model

Load these MySQL tables from database `TBMD`:

- `movies`
- `genres`
- `movie_genres`
- `cast`
- `crew`
- `movie_keywords`

Create these relationships:

- `movies[movie_id]` 1-to-many `movie_genres[movie_id]`
- `genres[genre_id]` 1-to-many `movie_genres[genre_id]`
- `movies[movie_id]` 1-to-many `cast[movie_id]`
- `movies[movie_id]` 1-to-many `crew[movie_id]`
- `movies[movie_id]` 1-to-many `movie_keywords[movie_id]`

## Recommended Measures

```DAX
Total Movies = DISTINCTCOUNT(movies[movie_id])
Total Genres = DISTINCTCOUNT(genres[genre_id])
Total Actors = DISTINCTCOUNT(cast[person_id])
Average Rating = AVERAGE(movies[vote_average])
Movie Count = DISTINCTCOUNT(movies[movie_id])
Average Budget = AVERAGE(movies[budget])
Average Revenue = AVERAGE(movies[revenue])
Actor Movie Count = DISTINCTCOUNT(cast[movie_id])
Director Movie Count = DISTINCTCOUNT(crew[movie_id])
Keyword Count = COUNTROWS(movie_keywords)
```

Use distinct `movie_id` counts for movie, cast, crew, and genre membership visuals. Use `Keyword Count` for keyword frequency because one movie can have many keyword rows.

## Dashboard 1: Overview & Business Insights

Create a report page named **Overview & Business Insights**. Build the following visuals from the six imported MySQL tables:

| Section | Visual | Fields and configuration |
|---|---|---|
| Overview | Four cards | `Total Movies`, `Total Genres`, `Total Actors`, `Average Rating` |
| Top Movies | Horizontal bar chart | Axis: `movies[title]`; Values: `SUM(movies[revenue])`; visual filter: Top 10 by revenue; sort descending |
| Genre Economics | Clustered column chart | Axis: `genres[genre_name]`; Values: `Average Budget`, `Average Revenue` |
| Genre Mix | Donut chart | Legend: `genres[genre_name]`; Values: `Movie Count` |
| Top Actors | Horizontal bar chart | Axis: `cast[actor_name]`; Values: `Actor Movie Count`; visual filter: Top 10 |
| Top Directors | Horizontal bar chart | Axis: `crew[person_name]`; Values: `Director Movie Count`; filter `crew[job] = Director`; visual filter: Top 10 |
| Rating Spread | Column chart | Create rating bins from `movies[vote_average]`; Axis: rating bin; Values: `Movie Count` |
| Budget vs Revenue | Scatter chart | X-axis: `movies[budget]`; Y-axis: `movies[revenue]`; Details: `movies[title]`; Size: `movies[popularity]`; filter budget and revenue greater than 0 |
| Yearly Output | Column chart | X-axis: `movies[release_date]` at Year level; Values: `Movie Count` |
| Popular Keywords | Bar chart | Axis: `movie_keywords[keyword_name]`; Values: `Keyword Count`; visual filter: Top 10 |

## Dashboard 2: SQL Insights

Create a second report page named **SQL Insights**. To show each query result as a Power BI visual, use **Home > Get data > MySQL database > Advanced options > SQL statement**, paste one query at a time from `powerbi_dashboard_queries.sql`, and load each result as a separate table. Alternatively, create MySQL views for the queries and import those views through the same MySQL connection. Do not connect this page to CSV files.

Recommended SQL result visual layout:

- Q1 Action movies after 2015: table with title and release date
- Q2 Highest-grossing movies and genres: table with title, revenue, and genres
- Q3 Average budget and revenue by genre: clustered column chart
- Q4 Top actors by movie count: bar chart
- Q5 Directors with more than 3 movies: bar chart
- Q6 Most frequently used keywords: bar chart
- Q7 Above-average budget and below-average revenue: table
- Q8 Actors in Christopher Nolan movies: table
- Q9 Highest-rated genre with at least 20 movies: card or bar chart
- Q10 Movies with the most keyword tags: bar chart

For Q1, Q2, Q7, and Q8 use Table visuals. For Q3, Q4, Q5, Q6, and Q10 use horizontal bar or clustered column charts. For Q9 use a bar chart or Card. Sort every ranking visual descending by its count, revenue, or average value.

## Data Quality Filters

Exclude zero or null budgets and revenues from financial comparisons. Exclude null or zero ratings from rating averages when appropriate. For `Top Directors`, filter `job` to `Director`; for actors and keywords, count distinct movies rather than relationship rows. The cleaning notebook stores unknown budget, revenue, and rating values as SQL `NULL` and preserves the full many-to-many keyword table with `(movie_id, keyword_id)` as its key.

## Final Checks

- Confirm the model source is MySQL/ODBC and not the `Dataset` folder.
- Confirm the six relationships appear in Model view with single-direction filtering from parent tables.
- Confirm Dashboard 1 contains the business visuals and Dashboard 2 contains Q1-Q10 result visuals.
- Save the report as `Movie_Dashboard.pbix`.

## Build Completion Checklist

1. In Power BI Desktop, connect to `localhost` / `TBMD` using **MySQL database** or the configured MySQL ODBC DSN.
2. Import the six tables and create the six relationships listed above.
3. Create the DAX measures in this document.
4. Add a report page named **Overview & Business Insights** and create the Overview, Top Movies, Genre Economics, Genre Mix, Top Actors, Top Directors, Rating Spread, Budget vs Revenue, Yearly Output, and Popular Keywords visuals.
5. Add a report page named **SQL Insights** and import the ten query results from `powerbi_dashboard_queries.sql` using native SQL or MySQL views.
6. Map Q1-Q10 to the recommended visual types above and verify each visual has a title identifying its question.
7. Save as `Movie_Dashboard.pbix`.

The `.pbix` file is created and saved by Power BI Desktop. This repository contains the cleaned MySQL source, SQL queries, and build instructions; it cannot generate the proprietary Power BI binary file without Power BI Desktop.
