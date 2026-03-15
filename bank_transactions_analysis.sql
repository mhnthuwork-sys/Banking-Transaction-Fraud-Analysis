-- ============================================================
-- Bank Transactions Analysis
-- ============================================================


-- Q1. How does monthly revenue fluctuate?
SELECT
    strftime('%Y-%m', transactiondate) AS month,
    COUNT(*)                           AS total_transactions,
    ROUND(SUM(transactionamoun), 2)    AS total_amount,
    ROUND(AVG(transactionamoun), 2)    AS avg_amount
FROM bank_transactions_data_2
GROUP BY strftime('%Y-%m', transactiondate)
ORDER BY month ASC;


-- Q2. Which channel (ATM / Online / Branch) has the highest total transactions?
SELECT
    channel,
    COUNT(*)                        AS total_transactions,
    ROUND(SUM(transactionamoun), 2) AS total_amount,
    ROUND(AVG(transactionamoun), 2) AS avg_amount
FROM bank_transactions_data_2
GROUP BY channel
ORDER BY total_amount DESC;


-- Q3. What is the Credit vs Debit ratio by channel?
SELECT
    channel,
    transactiontype,
    COUNT(*)                        AS total_transactions,
    ROUND(SUM(transactionamoun), 2) AS total_amount
FROM bank_transactions_data_2
GROUP BY channel, transactiontype
ORDER BY channel, transactiontype;


-- Q4. How does account balance segment affect spending behavior?
SELECT
    CASE
        WHEN accountbalance < 2000 THEN 'Low (0-2k)'
        WHEN accountbalance < 8000 THEN 'Mid (2k-8k)'
        ELSE                            'High (8k+)'
    END                             AS balance_segment,
    COUNT(*)                        AS total_transactions,
    ROUND(AVG(transactionamoun), 2) AS avg_spending,
    ROUND(SUM(transactionamoun), 2) AS total_spending
FROM bank_transactions_data_2
GROUP BY balance_segment
ORDER BY avg_spending DESC;


-- Q5. What is the spending ratio (Amount / Balance) by customer occupation?
SELECT
    customeroccupation,
    COUNT(*)                                                AS total_transactions,
    ROUND(AVG(transactionamoun / accountbalance * 100), 2) AS avg_spending_ratio_pct,
    COUNT(CASE WHEN transactionamoun / accountbalance > 0.3
               THEN 1 END)                                 AS high_ratio_count
FROM bank_transactions_data_2
WHERE accountbalance > 0
GROUP BY customeroccupation
ORDER BY avg_spending_ratio_pct DESC;


-- Q6. Which transactions show signs of fraud? (Login Attempts >= 3)
SELECT
    accountid,
    transactionid,
    transactionamoun,
    transactiondate,
    channel,
    location,
    loginattempts
FROM bank_transactions_data_2
WHERE loginattempts >= 3
ORDER BY loginattempts DESC, transactionamoun DESC;


-- Q7. Which channel and city have the highest fraud count?
SELECT
    channel,
    location,
    COUNT(*)                        AS fraud_count,
    ROUND(AVG(transactionamoun), 2) AS avg_fraud_amount
FROM bank_transactions_data_2
WHERE loginattempts >= 3
GROUP BY channel, location
ORDER BY fraud_count DESC
LIMIT 20;


-- Q8. What is the fraud risk level for each transaction?
SELECT
    accountid,
    transactionid,
    transactionamoun,
    loginattempts,
    transactionduration,
    channel,
    CASE
        WHEN loginattempts >= 3 AND transactionamoun > 700 THEN 'HIGH RISK'
        WHEN loginattempts >= 3 OR  transactionamoun > 700 THEN 'MEDIUM RISK'
        ELSE                                                     'LOW RISK'
    END AS fraud_risk_level
FROM bank_transactions_data_2
ORDER BY loginattempts DESC, transactionamoun DESC;


-- Q9. What is the total volume of transactions for each hour of the day?
SELECT
    CAST(strftime('%H', transactiondate) AS INT) AS hour_of_day,
    COUNT(*)                                     AS total_transactions,
    ROUND(SUM(transactionamoun), 2)              AS total_amount
FROM bank_transactions_data_2
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;


-- Q10. Which city has the highest fraud rate?
SELECT
    location,
    COUNT(*)                                                 AS total_transactions,
    COUNT(CASE WHEN loginattempts >= 3 THEN 1 END)          AS fraud_count,
    ROUND(
        COUNT(CASE WHEN loginattempts >= 3 THEN 1 END) * 100.0
        / COUNT(*), 2
    )                                                        AS fraud_rate_pct
FROM bank_transactions_data_2
GROUP BY location
ORDER BY fraud_rate_pct DESC
LIMIT 15;
