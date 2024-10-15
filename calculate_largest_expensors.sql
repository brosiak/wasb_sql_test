USE memory.default;

with employees as (
    SELECT
        employee_id,
        first_name,
        last_name,
        manager_id
    FROM EMPLOYEE
),
expenses as (
    SELECT
        employee_id,
        unit_price,
        quantity
    FROM EXPENSE
),
employees_with_name as (
    SELECT
        employee_id,
        concat(first_name, ' ', last_name) as employee_name,
        manager_id
    FROM employees
),
employees_with_managers_name as (
    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        em.employee_name as manager_name
    FROM employees_with_name e
    INNER JOIN employees_with_name em on e.manager_id = em.employee_id --inner join because we assume that every employee has manager
),
employees_expenses as (
    SELECT
        employee_id,
        SUM(unit_price * quantity) as total_expensed_amount
    FROM expenses
    GROUP BY 1
    HAVING SUM(unit_price * quantity) > 1000
),
final as (
    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        e.manager_name,
        total_expensed_amount
    FROM employees_with_managers_name e
    LEFT JOIN employees_expenses ee ON e.employee_id = ee.employee_id
    WHERE ee.employee_id is not null
    ORDER BY total_expensed_amount DESC
)

SELECT * FROM final;