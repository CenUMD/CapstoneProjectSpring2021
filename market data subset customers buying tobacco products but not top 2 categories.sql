WITH 
--  figure out category totals and their rankings by total
 category_ranking AS (
    SELECT
        ROW_NUMBER()
        OVER(
            ORDER BY SUM(t0.linenettotal) DESC
        )                                    AS category_ranking,
        t0.category_name1,
        round(SUM(t0.linenettotal))          AS category_total
    FROM
        turkishmarket t0
    GROUP BY
        t0.category_name1
), 
--  enhance original data with the derived category rankings
 market_data_with_category_ranking AS (
    SELECT
        t0.*,
        t1.category_ranking,
        t1.category_total
    FROM
        turkishmarket     t0,
        category_ranking  t1
    WHERE
        nvl(t0.category_name1, 'N/A') = nvl(t1.category_name1, 'N/A')
), 
--  figure out the client subset that do not buy products in the top ranked categories
 client_subset AS (
    SELECT DISTINCT
        clientcode
    FROM
        turkishmarket
    where 
        category_name1 = 'Tobacco Products'
    MINUS
    SELECT DISTINCT
        clientcode
    FROM
        market_data_with_category_ranking
    WHERE
        category_ranking = ANY ( 1,
                                 2 )
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
    t0.*
FROM
    market_data_subset t0
;
