-- What is the most account type have followers?
SELECT account_type, SUM(follower_count) AS Number_of_followers FROM posts_insights
GROUP BY account_type;

-- Q2 What is the Average Engagements of impressions with posts for each content category? 
WITH ranked AS (
    SELECT
        content_category,
        er_by_impressions,
        ROW_NUMBER() OVER (
            PARTITION BY content_category
            ORDER BY er_by_impressions
        ) AS rn,
        COUNT(*) OVER (
            PARTITION BY content_category
        ) AS cnt
    FROM posts_insights
),

median_table AS (
    SELECT
        content_category,
        AVG(er_by_impressions) AS median_er_by_impressions
    FROM ranked
    WHERE rn IN (
        FLOOR((cnt + 1)/2),
        FLOOR((cnt + 2)/2)
    )
    GROUP BY content_category
)
SELECT content_category, ROUND(AVG(median_er_by_impressions),2) AS Average_er_performance
FROM median_table GROUP BY content_category ORDER BY Average_er_performance DESC;

-- Q3 What is the best media type performed at impressions?
WITH ranked AS (
    SELECT
        media_type,
        impressions,
        ROW_NUMBER() OVER (
            PARTITION BY media_type
            ORDER BY impressions
        ) AS rn,
        COUNT(*) OVER (
            PARTITION BY media_type
        ) AS cnt
    FROM posts_insights
),

median_table AS (
    SELECT
        media_type,
        AVG(impressions) AS median_impressions
    FROM ranked
    WHERE rn IN (
        FLOOR((cnt + 1)/2),
        FLOOR((cnt + 2)/2)
    )
    GROUP BY media_type
)

SELECT
    p.media_type,
    COUNT(*) AS Number_of_posts,
    ROUND(AVG(p.impressions),2) AS Averag_impressions,
    ROUND(m.median_impressions,2) AS median_impressions,
    ROUND(AVG(p.er_by_impressions),2) AS avg_er_by_impressions
FROM posts_insights p
JOIN median_table m
    ON p.media_type = m.media_type
GROUP BY
    p.media_type,
    m.median_impressions
ORDER BY median_impressions DESC;

-- Q4 How many call to action done based on each content category?
SELECT content_category, SUM(call_to_action) AS Total_CTA FROM posts_insights GROUP BY content_category ORDER BY Total_CTA DESC;

-- Q5 How many followers each content and media type gained?
SELECT content_category, media_type,  SUM(followers_gained) AS New_followers FROM posts_insights GROUP BY content_category, media_type ORDER BY New_followers DESC; 

-- Q6 what is the reach of posts based on the traffic source ?
SELECT traffic_source , SUM(reach) AS posts_reach_performance FROM posts_insights GROUP BY traffic_source ORDER BY posts_reach_performance DESC;

-- Q7 What is the best day of the week to post based on engagments performance?
WITH ranked AS (
    SELECT
        day_of_week,
        er_by_reach,
        ROW_NUMBER() OVER (
            PARTITION BY day_of_week
            ORDER BY er_by_reach
        ) AS rn,
        COUNT(*) OVER (
            PARTITION BY day_of_week
        ) AS cnt
    FROM posts_insights
),

median_table AS (
    SELECT
        day_of_week,
        AVG(er_by_reach) AS median_er
    FROM ranked
    WHERE rn IN (
        FLOOR((cnt + 1)/2),
        FLOOR((cnt + 2)/2)
    )
    GROUP BY day_of_week
)

SELECT
    p.day_of_week,
    COUNT(*) AS num_posts,
    ROUND(AVG(p.er_by_reach),2) AS avg_er,
    ROUND(m.median_er,2) AS median_er
FROM posts_insights p
JOIN median_table m
    ON p.day_of_week = m.day_of_week
GROUP BY
    p.day_of_week,
    m.median_er
ORDER BY median_er DESC;

  