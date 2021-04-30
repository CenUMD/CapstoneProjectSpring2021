WITH 
--  figure out the client subset who buy Pet Supplies
 client_subset AS (
    SELECT DISTINCT
        clientcode
    FROM
        turkishmarket
    where
        category_name1 = 'Pet Supplies'
), 
--  figure out the subset of data for what products such a subset of customers are buying
 market_data_subset AS (
    SELECT
        t0.*
    FROM
        turkishmarket  t0,
        client_subset  t1
    WHERE
        t0.clientcode = t1.clientcode
)
--  figure out category totals and their rankings by total for such a subset of customers
SELECT
    ROW_NUMBER()
    OVER(
        ORDER BY SUM(t0.linenettotal) DESC
    )                                    AS category_ranking,
    t0.category_name1,
    round(SUM(t0.linenettotal))          AS category_total
FROM
    market_data_subset t0
GROUP BY
    t0.category_name1;