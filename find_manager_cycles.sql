WITH RECURSIVE approval_cycles (employee_id, manager_id, cycle_path, depth, starting_employee) AS (
    SELECT
        employee_id,
        manager_id,
        ARRAY[manager_id] AS cycle_path,
        1 as depth, -- to track depth and retrieve full cycle
        employee_id as starting_employee -- to track ID of employee from the start
    FROM EMPLOYEE e
    UNION ALL
    SELECT
        e.employee_id employee_id,
        e.manager_id manager_id,
        ac.cycle_path || e.manager_id,
        ac.depth + 1 as depth,
        starting_employee
    FROM approval_cycles ac
    INNER JOIN EMPLOYEE e
         ON ac.manager_id = e.employee_id
    WHERE
        NOT contains(ac.cycle_path, e.manager_id) --stop loop once we see manager_id second time
)

SELECT
    starting_employee,
    MAX(cycle_path)
FROM approval_cycles
WHERE contains(cycle_path, starting_employee) -- we need to filter out, only these employees that can approve each others expenses
GROUP BY 1
ORDER BY
    starting_employee;

