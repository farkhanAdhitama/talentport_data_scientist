-- Ambil data transaksi per pelanggan
WITH rfm_base AS (
    SELECT
        customer_id,
        MAX(DATE(order_date)) AS last_order_date,
        COUNT(order_id) AS frequency,
        SUM(payment_value) AS monetary
    FROM
        e_commerce_transactions
    GROUP BY
        customer_id
),

-- Tetapkan tanggal referensi untuk menghitung Recency
reference_date AS (
    SELECT MAX(DATE(order_date)) AS today
    FROM e_commerce_transactions
),

-- Hitung nilai RFM numerik
rfm_scores AS (
    SELECT
        r.customer_id,
        JULIANDAY(rd.today) - JULIANDAY(r.last_order_date) AS recency,
        r.frequency,
        r.monetary
    FROM
        rfm_base r
    CROSS JOIN reference_date rd
),

-- Skoring masing-masing nilai R, F, M
rfm_segmented AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,

        -- Skor Recency (semakin kecil semakin baik)
        CASE
            WHEN recency <= 30 THEN 3
            WHEN recency <= 90 THEN 2
            ELSE 1
        END AS r_score,

        -- Skor Frequency (semakin besar semakin baik)
        CASE
            WHEN frequency >= 4 THEN 3
            WHEN frequency >= 2 THEN 2
            ELSE 1
        END AS f_score,

        -- Skor Monetary (semakin besar semakin baik)
        CASE
            WHEN monetary >= 300 THEN 3
            WHEN monetary >= 100 THEN 2
            ELSE 1
        END AS m_score
    FROM rfm_scores
)

-- Gabungkan skor jadi RFM code & buat segmentasi
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
        WHEN r_score = 3 AND f_score = 3 THEN 'Champions'
        WHEN r_score = 2 AND f_score = 3 THEN 'Loyal Customers'
        WHEN r_score = 1 AND f_score = 3 THEN 'Potential Loyalist'
        WHEN r_score = 3 AND f_score = 1 THEN 'Recent One-Timer'
        WHEN r_score = 2 AND f_score = 2 THEN 'Need Attention'
        WHEN r_score = 1 AND f_score = 1 THEN 'Lost'
        ELSE 'Others'
    END AS segment
FROM rfm_segmented
ORDER BY rfm_class DESC;
