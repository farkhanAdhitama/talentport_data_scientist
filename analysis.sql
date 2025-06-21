-- Simple RFM Analysis for E-commerce Transactions Dataset
-- Hitung RFM untuk setiap pelanggan
WITH rfm_base AS (
    SELECT
        customer_id,
        MAX(DATE(order_date)) AS last_order_date,
        COUNT(order_id) AS frequency,
        SUM(payment_value) AS monetary
    FROM e_commerce_transactions
    GROUP BY customer_id
),

-- Tentukan tanggal paling baru
reference_date AS (
    SELECT MAX(DATE(order_date)) AS today
    FROM e_commerce_transactions
),

-- Hitung nilai recency dengan mengurangi tanggal terbaru dan terlama
rfm_scores AS (
    SELECT
        r.customer_id,
        JULIANDAY(rd.today) - JULIANDAY(r.last_order_date) AS recency,
        r.frequency,
        r.monetary
    FROM rfm_base r
    CROSS JOIN reference_date rd
),

-- Hitung kuartil untuk frequency dan monetary
quartiles AS (
    SELECT
        (SELECT frequency FROM rfm_scores ORDER BY frequency LIMIT 1 OFFSET (SELECT COUNT(*) FROM rfm_scores) * 1 / 4) AS f_q1,
        (SELECT frequency FROM rfm_scores ORDER BY frequency LIMIT 1 OFFSET (SELECT COUNT(*) FROM rfm_scores) * 2 / 4) AS f_q2,
        (SELECT frequency FROM rfm_scores ORDER BY frequency LIMIT 1 OFFSET (SELECT COUNT(*) FROM rfm_scores) * 3 / 4) AS f_q3,
        (SELECT monetary FROM rfm_scores ORDER BY monetary LIMIT 1 OFFSET (SELECT COUNT(*) FROM rfm_scores) * 1 / 4) AS m_q1,
        (SELECT monetary FROM rfm_scores ORDER BY monetary LIMIT 1 OFFSET (SELECT COUNT(*) FROM rfm_scores) * 2 / 4) AS m_q2,
        (SELECT monetary FROM rfm_scores ORDER BY monetary LIMIT 1 OFFSET (SELECT COUNT(*) FROM rfm_scores) * 3 / 4) AS m_q3
),

-- Berikan skor berdasarkan kuartil
rfm_segmented AS (
    SELECT
        r.customer_id,
        r.recency,
        r.frequency,
        r.monetary,

        -- Skor Recency
        CASE
            WHEN r.recency <= 120 THEN 4
            WHEN r.recency <= 240 THEN 3
            WHEN r.recency <= 390 THEN 2
            ELSE 1
        END AS r_score,

        -- Skor Frequency berdasarkan kuartil
        CASE
            WHEN r.frequency <= q.f_q1 THEN 1
            WHEN r.frequency <= q.f_q2 THEN 2
            WHEN r.frequency <= q.f_q3 THEN 3
            ELSE 4
        END AS f_score,

        -- Skor Monetary berdasarkan kuartil
        CASE
            WHEN r.monetary <= q.m_q1 THEN 1
            WHEN r.monetary <= q.m_q2 THEN 2
            WHEN r.monetary <= q.m_q3 THEN 3
            ELSE 4
        END AS m_score
    FROM rfm_scores r, quartiles q
)

-- Segmentasi pelanggan ke beberapa golongan
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    r_score || f_score || m_score AS rfm_class,
    
    CASE
        WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score = 4 AND f_score <= 2 THEN 'Potential Loyalist'
        WHEN r_score = 3 AND f_score = 1 THEN 'Need Attention'
        WHEN r_score = 2 THEN 'About to Sleep'
        WHEN r_score = 1 THEN 'Lost'
        ELSE 'Others'
    END AS segment

FROM rfm_segmented
ORDER BY segment DESC;
