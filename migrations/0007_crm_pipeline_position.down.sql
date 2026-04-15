DROP INDEX IF EXISTS idx_pipelines_position;

ALTER TABLE crm.pipelines DROP COLUMN IF EXISTS position;
