BEGIN;

-- A materialized view is used instead of a table because this repository owns
-- schema only, not refresh orchestration or write paths. ETL can refresh this
-- object after normalized loads and query a stable, indexed analytics surface.
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
    (d.status NOT IN ('won', 'lost')) AS is_ongoing,
    (
        d.status = 'won'
        AND d.won_at >= date_trunc('month', CURRENT_TIMESTAMP)
        AND d.won_at < date_trunc('month', CURRENT_TIMESTAMP) + INTERVAL '1 month'
    ) AS won_current_month,
    (
        d.status = 'won'
        AND d.won_at >= CURRENT_TIMESTAMP - INTERVAL '12 months'
    ) AS won_last_12_months
FROM crm.deals AS d
JOIN crm.pipelines AS p
    ON p.id = d.pipeline_id
JOIN crm.pipeline_stages AS ps
    ON ps.id = d.stage_id
JOIN crm.users AS u
    ON u.id = d.owner_id
LEFT JOIN crm.deal_products AS dp
    ON dp.deal_id = d.id
LEFT JOIN crm.products AS pr
    ON pr.id = dp.product_id;

COMMENT ON MATERIALIZED VIEW derived.deal_metrics IS 'Read-optimized deal fact surface for grouping by pipeline, stage, owner, and product.';

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
CREATE INDEX deal_metrics_won_current_month_idx
    ON derived.deal_metrics (won_current_month);
CREATE INDEX deal_metrics_won_last_12_months_idx
    ON derived.deal_metrics (won_last_12_months);

COMMIT;
