-- Create indices for faster joins.
CREATE INDEX IF NOT EXISTS idx_all ON deutschland.imp_Tote (jahr, altersgruppe, bundesland);

CREATE INDEX IF NOT EXISTS idx_all ON deutschland.imp_Einwohner (jahr, altersgruppe, bundesland);

-- Sum up the population age groups.
DROP VIEW IF EXISTS population;

CREATE VIEW population AS
SELECT
    jahr,
    altersgruppe,
    bundesland,
    SUM(einwohner) einwohner
FROM
    deutschland.imp_Einwohner
GROUP BY
    jahr,
    altersgruppe,
    bundesland;

-- Calculate mortality per 100k.
DROP VIEW IF EXISTS mortality;

CREATE VIEW mortality AS
SELECT
    t.*,
    concat(t.jahr, "/", ceil(cast(woche AS integer) / 13)) AS jahr_quartal,
    t.tote / (e.einwohner / 100000) AS "tote100k"
FROM
    deutschland.imp_Tote t
    JOIN deutschland.population e ON t.jahr = e.jahr
    AND t.altersgruppe = e.altersgruppe
    AND t.bundesland = e.bundesland;

-- Baseline 2020
DROP VIEW IF EXISTS baseline2020;

CREATE VIEW baseline2020 AS
SELECT
    bundesland,
    altersgruppe,
    woche,
    AVG(tote100k) * ((52 + 5 / 7) / 52) AS baseline -- Adjust for 53 weeks
FROM
    mortality a
WHERE
    a.jahr IN (2015, 2016, 2017, 2018, 2019)
GROUP BY
    altersgruppe,
    bundesland,
    woche;

-- Baseline 2021
DROP VIEW IF EXISTS baseline2021;

CREATE VIEW baseline2021 AS
SELECT
    bundesland,
    altersgruppe,
    woche,
    AVG(tote100k) AS baseline
FROM
    mortality a
WHERE
    a.jahr IN (2015, 2016, 2017, 2018, 2019)
    AND woche <= (
        -- Limit to last data week
        SELECT
            max(cast(woche AS integer))
        FROM
            mortality
        WHERE
            jahr IN (
                SELECT
                    max(cast(jahr AS integer))
                FROM
                    mortality
            )
            AND tote100k > 0
    )
GROUP BY
    altersgruppe,
    bundesland,
    woche;
