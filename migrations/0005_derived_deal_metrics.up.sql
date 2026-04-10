BEGIN;

-- A materialized view is used instead of a table because this repository owns
-- schema only, not refresh orchestration or write paths. ETL can refresh this
-- object after normalized loads and query a stable, indexed analytics surface.
-- Time-windowed dashboard cuts such as "current month" or "last 12 months"
-- should be computed at query time, not stored here as values that age.
CREATE MATERIALIZED VIEW derived.deal_metrics AS
SELECT
    d.id AS deal_id,
    d.name AS deal_name,
    d.status,
    d.pipeline_id,
    p.name AS pipeline_name,
    d.stage_id,
    ps.name AS stage_name,
    d.owner_id,
    u.name AS owner_name,
    dp.product_id,
    pr.name AS product_name,
    d.won_at,
    d.created_at,
    d.updated_at,
    d.amount AS deal_amount,
    dp.quantity AS product_quantity,
    dp.amount AS product_amount,
    (d.status = 'won') AS is_won,
    (d.status NOT IN ('won', 'lost')) AS is_ongoing
FROM crm.deals AS d
JOIN crm.pipelines AS p
    ON p.id = d.pipeline_id
JOIN crm.pipeline_stages AS ps
    ON ps.id = d.stage_id
   AND ps.pipeline_id = d.pipeline_id
LEFT JOIN crm.users AS u
    ON u.id = d.owner_id
LEFT JOIN crm.deal_products AS dp
    ON dp.deal_id = d.id
LEFT JOIN crm.products AS pr
    ON pr.id = dp.product_id;

COMMENT ON MATERIALIZED VIEW derived.deal_metrics IS 'Read-optimized deal fact surface for grouping by pipeline, stage, owner, and product. Relative time windows should be applied by downstream queries at API or dashboard time.';

-- This remains safe because crm.deal_products has a primary key on
-- (deal_id, product_id), so the view yields at most one row per pair, and at
-- most one NULL product row for deals with no associated products.
CREATE UNIQUE INDEX deal_metrics_deal_product_uniq_idx
    ON derived.deal_metrics (deal_id, product_id);
CREATE INDEX deal_metrics_status_idx
    ON derived.deal_metrics (status);
CREATE INDEX deal_metrics_won_at_idx
    ON derived.deal_metrics (won_at);
CREATE INDEX deal_metrics_pipeline_id_idx
    ON derived.deal_metrics (pipeline_id);
CREATE INDEX deal_metrics_stage_id_idx
    ON derived.deal_metrics (stage_id);
CREATE INDEX deal_metrics_owner_id_idx
    ON derived.deal_metrics (owner_id);
CREATE INDEX deal_metrics_product_id_idx
    ON derived.deal_metrics (product_id);
CREATE INDEX deal_metrics_ongoing_idx
    ON derived.deal_metrics (is_ongoing);

COMMIT;
