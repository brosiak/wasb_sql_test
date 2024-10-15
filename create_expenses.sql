USE memory.default;

DROP TABLE IF EXISTS EXPENSE;

CREATE TABLE IF NOT EXISTS EXPENSE(
    employee_id TINYINT,
    unit_price DECIMAL(8, 2),
    quantity TINYINT
);


INSERT INTO EXPENSE (employee_id, unit_price, quantity)

with temp_expense as (
    SELECT
        employee_name,
        unit_price,
        quantity
    FROM (
        VALUES
            ('Alex Jacobson', 'Drinks, lots of drinks', 6.50, 14),
            ('Alex Jacobson', 'More Drinks', 11.00, 20),
            ('Alex Jacobson', 'So Many Drinks!', 22.00, 18),
            ('Alex Jacobson', 'I bought everyone in the bar a drink!', 13.00, 75),
            ('Andrea Ghibaudi', 'Flights from Mexico back to New York', 300, 1),
            ('Darren Poynton', 'Ubers to get us all home', 40.00, 9),
            ('Umberto Torrielli', 'I had too much fun and needed something to eat', 17.50, 4)
    ) as tmp(employee_name, description, unit_price, quantity)
),
expenses as (
    SELECT
        employee_name,
        unit_price,
        quantity
    FROM temp_expense
),
employees as (
    SELECT
        employee_id,
        first_name,
        last_name
    FROM EMPLOYEE
),
expenses_with_ids as (
    SELECT
        emp.employee_id,
        ex.unit_price,
        ex.quantity
    FROM expenses ex
    JOIN employees emp on CONCAT(emp.first_name, ' ', emp.last_name) = ex.employee_name
)


SELECT
    employee_id,
    unit_price,
    quantity
FROM expenses_with_ids;
