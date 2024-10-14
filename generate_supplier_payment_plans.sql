USE memory.default;

with suppliers as (
    SELECT
        supplier_id,
        name
    FROM SUPPLIER
),
invoices as (
    SELECT
        supplier_id,
        invoice_amount,
        due_date,
        current_date as start_date
    FROM INVOICE
),
months as ( --generate all months per supplier to distribute payments
    SELECT DISTINCT
        supplier_id,
        LAST_DAY_OF_MONTH(date_add('month', seq, start_date)) as due_date
    FROM
        invoices
    CROSS JOIN UNNEST(sequence(0, date_diff('month', start_date, due_date))) AS n (seq)
    ORDER BY 1,2
),
payments_per_supplier as ( -- count number of payments
    SELECT
        supplier_id,
        COUNT(*) AS month_count
    FROM months m
    GROUP BY 1
),
count_invoices as ( -- count monthly payment
    SELECT DISTINCT
        supplier_id,
        ROUND(SUM(invoice_amount) OVER (PARTITION BY supplier_id) / ips.month_count, 2) AS monthly_payment
    FROM invoices i
    JOIN payments_per_supplier ips using (supplier_id)
),
invoices_plan as ( -- plan invoices
    SELECT
        supplier_id,
        monthly_payment,
        due_date
    FROM count_invoices c
    JOIN months m using (supplier_id)
),
final as (
    SELECT
        supplier_id,
        name as supplier_name,
        monthly_payment,
        due_date,
        SUM(monthly_payment) OVER (PARTITION BY supplier_id ORDER BY due_date DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - monthly_payment AS total_invoice_amount
    FROM invoices_plan
    JOIN suppliers using(supplier_id)
)



SELECT * FROM final ORDER BY supplier_id, due_date;