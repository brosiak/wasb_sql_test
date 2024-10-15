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
        current_date as start_date,
        ROW_NUMBER() OVER (ORDER BY supplier_id) as invoice_id
    FROM INVOICE
),
months as ( --generate all months per supplier to distribute payments
    SELECT
        supplier_id,
        invoice_id,
        LAST_DAY_OF_MONTH(date_add('month', seq, start_date)) as due_date
    FROM
        invoices
    CROSS JOIN UNNEST(sequence(0, date_diff('month', start_date, due_date))) AS n (seq)
    ORDER BY 1,2
),
payments_per_supplier as ( -- count number of payments
    SELECT
        supplier_id,
        invoice_id,
        COUNT(*) AS month_count
    FROM months m
    GROUP BY 1,2
),
invoice_costs_per_month as ( -- count monthly payment
    SELECT
        supplier_id,
        invoice_id,
        ROUND(SUM(invoice_amount) OVER (PARTITION BY supplier_id, invoice_id) / ips.month_count, 2) AS monthly_payment
    FROM invoices i
    JOIN payments_per_supplier ips using (supplier_id, invoice_id)
),
invoices_plan as ( -- plan invoices
    SELECT
        supplier_id,
        SUM(monthly_payment) as monthly_payment,
        due_date
    FROM invoice_costs_per_month c
    JOIN months m using (supplier_id, invoice_id)
    GROUP BY 1, 3
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
