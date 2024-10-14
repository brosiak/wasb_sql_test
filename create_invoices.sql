use memory.default;

DROP TABLE IF EXISTS SUPPLIER;

CREATE TABLE IF NOT EXISTS SUPPLIER (
    supplier_id TINYINT,
    name VARCHAR
);

INSERT INTO SUPPLIER(supplier_id, name)

WITH supplier_names as (
    SELECT
        name
    FROM (
        VALUES
            ('Party Animals'),
            ('Catering Plus'),
            ('Dave''s Discos'),
            ('Entertainment tonight'),
            ('Ice Ice Baby')
    ) AS s (name)
),
supplier_with_id as (
    SELECT
        ROW_NUMBER() OVER (ORDER BY name) as supplier_id,
        name
    FROM supplier_names
)

SELECT
    supplier_id,
    name
FROM supplier_with_id;



DROP TABLE IF EXISTS INVOICE;

CREATE TABLE IF NOT EXISTS INVOICE (
    supplier_id TINYINT,
    invoice_amount DECIMAL(8, 2),
    due_date DATE
);

INSERT INTO INVOICE (supplier_id, invoice_amount, due_date)

with supplier as (
    SELECT
        supplier_id,
        name
    FROM SUPPLIER
),
invoice as (
    SELECT
        company_name,
        invoice_amount,
        due_months
    FROM ( VALUES
            ('Party Animals', 6000, 3),
            ('Catering Plus', 2000, 2),
            ('Catering Plus', 1500, 3),
            ('Dave''s Discos', 500, 1),
            ('Entertainment tonight', 6000, 3),
            ('Ice Ice Baby', 4000, 6)
    ) as tmp(company_name, invoice_amount, due_months)
),
invoice_with_supplier_id as (
    SELECT
        s.supplier_id,
        i.invoice_amount,
        i.due_months
    FROM invoice i
    JOIN supplier s ON s.name=i.company_name
),
invoice_with_date as (
    SELECT
        supplier_id,
        invoice_amount,
        LAST_DAY_OF_MONTH(DATE_ADD('MONTH', due_months, CURRENT_DATE)) as due_date
    FROM invoice_with_supplier_id
)

SELECT supplier_id, invoice_amount, due_date FROM invoice_with_date;

