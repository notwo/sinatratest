CREATE TABLE IF NOT EXISTS "delayed_jobs" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "priority" integer DEFAULT 0 NOT NULL, "attempts" integer DEFAULT 0 NOT NULL, "handler" text NOT NULL, "last_error" text, "run_at" datetime(6), "locked_at" datetime(6), "failed_at" datetime(6), "locked_by" varchar, "queue" varchar, "created_at" datetime(6), "updated_at" datetime(6));
CREATE INDEX "delayed_jobs_priority" ON "delayed_jobs" ("priority", "run_at");

