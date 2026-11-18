import sqlite3
conn = sqlite3.connect("volve.db")
df.to_sql("production", conn, if_exists="replace", index=False)

def q(sql):
    return pd.read_sql(sql, conn)

-- 1. Total oil produced by each well
SELECT WELL_BORE_CODE, ROUND(SUM(BORE_OIL_VOL)) AS total_oil
FROM production
GROUP BY WELL_BORE_CODE
ORDER BY total_oil DESC;

-- 2. Average water cut per year
SELECT strftime('%Y', DATEPRD) AS year, ROUND(AVG(WATER_CUT), 3) AS avg_water_cut
FROM production
GROUP BY year
ORDER BY year;

-- 3. The five best producing months
SELECT strftime('%Y-%m', DATEPRD) AS month, ROUND(SUM(BORE_OIL_VOL)) AS total_oil
FROM production
GROUP BY month
ORDER BY total_oil DESC
LIMIT 5;

-- 4. Wells with a high average water cut
SELECT WELL_BORE_CODE, ROUND(AVG(WATER_CUT), 3) AS avg_water_cut, COUNT(*) AS producing_days
FROM production
GROUP BY WELL_BORE_CODE
HAVING AVG(WATER_CUT) > 0.8
ORDER BY avg_water_cut DESC;

-- 5. 7-day moving average of oil per well (window function)
SELECT WELL_BORE_CODE, DATEPRD, BORE_OIL_VOL,
       ROUND(AVG(BORE_OIL_VOL) OVER (
           PARTITION BY WELL_BORE_CODE ORDER BY DATEPRD
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 1) AS oil_7d_avg
FROM production
ORDER BY WELL_BORE_CODE, DATEPRD
LIMIT 20;



