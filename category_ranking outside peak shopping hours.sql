WITH 
--  figure out totals by transaction hours and their rankings by total
 category_ranking AS (
    SELECT
        ROW_NUMBER()
        OVER(
            ORDER BY SUM(t0.linenettotal) DESC
        )                                    AS transaction_hour_ranking,
        t0.transaction_hour,
        round(SUM(t0.linenettotal))          AS transaction_hour_total
    FROM
        turkishmarket t0
    GROUP BY
        t0.transaction_hour
), 
--  enhance original data with the derived transaction hour rankings
 market_data_with_hour_ranking AS (
    SELECT
        t0.*,
        t1.transaction_hour_ranking,
        t1.transaction_hour_total
    FROM
        turkishmarket     t0,
        category_ranking  t1
    WHERE
        nvl(t0.transaction_hour, -1) = nvl(t1.transaction_hour, -1)
), 
--  figure out the client subset that do not buy in the 8 top ranked transaction hours
 client_subset AS (
    SELECT DISTINCT
        clientcode
    FROM
        turkishmarket
    MINUS
    SELECT DISTINCT
        clientcode
    FROM
        market_data_with_hour_ranking
    WHERE
        transaction_hour_ranking between 1 and 8
), 
--  figure out what products such a subset of customers are buying
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
    t0.category_name1
;