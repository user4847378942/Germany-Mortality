SELECT
    *,
    (tote100k / baseline) -1 AS excess
FROM
    (
        SELECT
            a.jahr,
            a.bundesland,
            a.jahr_quartal,
            sum(a.tote100k) AS tote100k,
            sum(b.baseline) AS baseline
        FROM
            mortality a
            JOIN baseline2020 b ON a.altersgruppe = b.altersgruppe
            AND a.bundesland = b.bundesland
            AND a.woche = b.woche
        WHERE
            a.jahr = 2020
        GROUP BY
            a.jahr,
            a.bundesland,
            a.jahr_quartal
        UNION
        ALL -- 2021
        SELECT
            a.jahr,
            a.bundesland,
            a.jahr_quartal,
            sum(a.tote100k) AS tote100k,
            sum(b.baseline) AS baseline
        FROM
            mortality a
            JOIN baseline2021 b ON a.altersgruppe = b.altersgruppe
            AND a.bundesland = b.bundesland
            AND a.woche = b.woche
        WHERE
            a.jahr = 2021
        GROUP BY
            a.jahr,
            a.bundesland,
            a.jahr_quartal
    ) a;