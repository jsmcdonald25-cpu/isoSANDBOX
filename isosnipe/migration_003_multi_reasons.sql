-- ISOsnipe Rejections — multi-reason support.
-- Admin can now tag multiple reasons per rejection (e.g. "wrong year"
-- + "facsimile signature" + "bad photos"). The primary `reason_code`
-- stays for back-compat + the breakdown stats; `reason_codes` carries
-- the full set.

ALTER TABLE public.isosnipe_rejections
  ADD COLUMN IF NOT EXISTS reason_codes TEXT[];

CREATE INDEX IF NOT EXISTS isosnipe_rejections_codes_gin
  ON public.isosnipe_rejections USING GIN (reason_codes);
