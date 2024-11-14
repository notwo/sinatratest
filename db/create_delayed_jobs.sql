create table delayed_jobs(
  priority integer default 0 NOT NULL,
  attempts integer default 0 NOT NULL,
  handler text NOT NULL,
  last_error text,
  run_at date,
  locked_at date,
  failed_at date,
  locked_by text,
  queue text,
  created_at,
  updated_at
);

create index delayed_jobs_priority on delayed_jobs(priority, run_at);

