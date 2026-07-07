#!/usr/bin/env bash
# Structural validation for evals/ fixture tree.
# Run from repo root: ./evals/scripts/validate-fixtures.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVALS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${EVALS_DIR}/.." && pwd)"

cd "${REPO_ROOT}"

MIN_THREADS=25
MIN_INJECTION=10

err() {
  echo "validate-fixtures: $*" >&2
}

require_file() {
  if [[ ! -f "$1" ]]; then
    err "missing required file: $1"
    exit 1
  fi
}

require_dir() {
  if [[ ! -d "$1" ]]; then
    err "missing required directory: $1"
    exit 1
  fi
}

for dir in \
  "${EVALS_DIR}/corpus/threads" \
  "${EVALS_DIR}/golden/triage" \
  "${EVALS_DIR}/golden/drafts" \
  "${EVALS_DIR}/rubric" \
  "${EVALS_DIR}/injection/fixtures" \
  "${EVALS_DIR}/notetaker/fixtures" \
  "${EVALS_DIR}/notetaker/golden" \
  "${EVALS_DIR}/notetaker/rubric" \
  "${EVALS_DIR}/calendar/fixtures" \
  "${EVALS_DIR}/calendar/golden" \
  "${EVALS_DIR}/calendar/rubric" \
  "${EVALS_DIR}/schedule-health/fixtures" \
  "${EVALS_DIR}/schedule-health/golden" \
  "${EVALS_DIR}/feedback/fixtures" \
  "${EVALS_DIR}/feedback/golden" \
  "${EVALS_DIR}/feedback/rubric" \
  "${EVALS_DIR}/connectors/fixtures" \
  "${EVALS_DIR}/connectors/golden" \
  "${EVALS_DIR}/connectors/rubric" \
  "${EVALS_DIR}/starter-profiles" \
  "${EVALS_DIR}/doctor/fixtures" \
  "${EVALS_DIR}/doctor/golden" \
  "${EVALS_DIR}/demo/assets" \
  "${EVALS_DIR}/scripts"; do
  require_dir "$dir"
done

require_file "${EVALS_DIR}/corpus/manifest.yaml"
require_file "${EVALS_DIR}/injection/manifest.yaml"
require_file "${EVALS_DIR}/injection/expected-behaviour.yaml"
require_file "${EVALS_DIR}/notetaker/manifest.yaml"
require_file "${EVALS_DIR}/calendar/manifest.yaml"
require_file "${EVALS_DIR}/schedule-health/manifest.yaml"
require_file "${REPO_ROOT}/config/notetaker-formats.yaml"
require_file "${REPO_ROOT}/config/calendar-block-types.yaml"
require_file "${REPO_ROOT}/config/schedule-catalog.yaml"
require_file "${REPO_ROOT}/config/schedule-health.schema.yaml"
require_file "${REPO_ROOT}/config/feedback-signals.yaml"
require_file "${REPO_ROOT}/config/connector-categories.yaml"
require_file "${REPO_ROOT}/security/README.md"
require_file "${REPO_ROOT}/docs/guide/08-admin-deploy.md"
require_file "${REPO_ROOT}/docs/guide/connector-smoke-tests.md"
require_file "${EVALS_DIR}/feedback/manifest.yaml"
require_file "${EVALS_DIR}/connectors/manifest.yaml"
require_file "${REPO_ROOT}/config/starter-profiles/manifest.yaml"
require_file "${REPO_ROOT}/examples/before-after/manifest.yaml"
require_file "${REPO_ROOT}/config/doctor-checklist.yaml"
require_file "${REPO_ROOT}/config/doctor-report.schema.yaml"
require_file "${EVALS_DIR}/doctor/manifest.yaml"

if command -v ruby >/dev/null 2>&1; then
  ruby -ryaml - "${EVALS_DIR}" "${MIN_THREADS}" "${MIN_INJECTION}" <<'RUBY'
require 'yaml'
require 'pathname'
require 'set'

evals_dir = Pathname.new(ARGV[0])
min_threads = ARGV[1].to_i
min_injection = ARGV[2].to_i
repo_root = evals_dir.parent

errors = []

PII_PATTERNS = {
  'ssn' => /\b\d{3}-\d{2}-\d{4}\b/,
  'reserved-domain' => /@[A-Za-z0-9.-]*company\.com\b/i
}.freeze

def resolve_eval_path(evals_dir, repo_root, rel)
  p = Pathname.new(rel)
  return p if p.absolute?
  return repo_root.join(rel) if rel.start_with?('docs/', 'evals/')
  evals_dir.join(rel)
end

def check_pii(evals_dir, path, errors)
  text = path.read
  PII_PATTERNS.each do |label, pattern|
    if text.match?(pattern)
      rel = path.relative_path_from(repo_root)
      errors << "blocked PII pattern '#{label}' in #{rel}"
    end
  end
rescue Errno::ENOENT => e
  errors << "cannot read #{path}: #{e.message}"
end

corpus = YAML.load_file(evals_dir.join('corpus/manifest.yaml')) || {}
threads = corpus['threads'] || []
errors << "corpus/manifest.yaml: 'threads' must be a list" unless threads.is_a?(Array)

thread_ids = Set.new
threads.each_with_index do |entry, i|
  unless entry.is_a?(Hash)
    errors << "corpus/manifest.yaml: threads[#{i}] must be a mapping"
    next
  end
  tid = entry['id']
  fpath = entry['file']
  errors << "corpus/manifest.yaml: threads[#{i}] missing 'id'" if tid.nil? || tid.empty?
  errors << "corpus/manifest.yaml: duplicate thread id '#{tid}'" if thread_ids.include?(tid)
  thread_ids.add(tid) if tid
  if fpath.nil? || fpath.empty?
    errors << "corpus/manifest.yaml: thread '#{tid}' missing 'file'"
    next
  end
  resolved = resolve_eval_path(evals_dir, repo_root, fpath)
  unless resolved.file?
    errors << "missing corpus thread file: #{resolved}"
  else
    check_pii(evals_dir, resolved, errors)
  end
end

golden_triage_dir = evals_dir.join('golden/triage')
Dir.glob(golden_triage_dir.join('*.yaml')).each do |gf|
  data = YAML.load_file(gf) || {}
  gid = data['id']
  if gid && !thread_ids.include?(gid)
    errors << "golden triage #{File.basename(gf)} references unknown corpus id '#{gid}'"
  end
end

injection = YAML.load_file(evals_dir.join('injection/manifest.yaml')) || {}
fixtures = injection['fixtures'] || []
errors << "injection/manifest.yaml: 'fixtures' must be a list" unless fixtures.is_a?(Array)

fixture_ids = Set.new
fixtures.each_with_index do |entry, i|
  unless entry.is_a?(Hash)
    errors << "injection/manifest.yaml: fixtures[#{i}] must be a mapping"
    next
  end
  fid = entry['id']
  fpath = entry['file']
  errors << "injection/manifest.yaml: fixtures[#{i}] missing 'id'" if fid.nil? || fid.empty?
  errors << "injection/manifest.yaml: duplicate fixture id '#{fid}'" if fixture_ids.include?(fid)
  fixture_ids.add(fid) if fid
  if fpath.nil? || fpath.empty?
    errors << "injection/manifest.yaml: fixture '#{fid}' missing 'file'"
    next
  end
  resolved = resolve_eval_path(evals_dir, repo_root, fpath)
  unless resolved.file?
    errors << "missing injection fixture file: #{resolved}"
  else
    check_pii(evals_dir, resolved, errors)
  end
end

if threads.length > 0 && threads.length < min_threads
  errors << "corpus/manifest.yaml lists #{threads.length} threads; minimum is #{min_threads}"
end
if fixtures.length > 0 && fixtures.length < min_injection
  errors << "injection/manifest.yaml lists #{fixtures.length} fixtures; minimum is #{min_injection}"
end

golden_count = Dir.glob(golden_triage_dir.join('*.yaml')).length
if threads.length > 0 && golden_count > 0 && golden_count != threads.length
  errors << "golden triage file count (#{golden_count}) does not match corpus (#{threads.length})"
end

# --- notetaker corpus (MA04) ---
NOTETAKER_FORMAT_IDS = %w[granola fireflies otter google-meet hand-typed].freeze
DRAFT_TYPES = %w[recap doc-delivery next-step].freeze
OWNER_VALUES = %w[self other unknown].freeze

formats_path = repo_root.join('config/notetaker-formats.yaml')
if formats_path.file?
  formats_doc = YAML.load_file(formats_path) || {}
  format_entries = formats_doc['formats'] || []
  format_ids = format_entries.map { |e| e['format_id'] }.compact
  if format_ids.sort != NOTETAKER_FORMAT_IDS.sort
    errors << "config/notetaker-formats.yaml must list exactly #{NOTETAKER_FORMAT_IDS.join(', ')}; got #{format_ids.join(', ')}"
  end
else
  errors << "missing config/notetaker-formats.yaml"
end

nt_fixtures = []
notetaker_manifest_path = evals_dir.join('notetaker/manifest.yaml')
if notetaker_manifest_path.file?
  notetaker = YAML.load_file(notetaker_manifest_path) || {}
  nt_fixtures = notetaker['fixtures'] || []
  errors << "notetaker/manifest.yaml: 'fixtures' must be a list" unless nt_fixtures.is_a?(Array)

  nt_ids = Set.new
  nt_fixtures.each_with_index do |entry, i|
    unless entry.is_a?(Hash)
      errors << "notetaker/manifest.yaml: fixtures[#{i}] must be a mapping"
      next
    end
    fid = entry['id']
    fpath = entry['file']
    gpath = entry['golden']
    errors << "notetaker/manifest.yaml: fixtures[#{i}] missing 'id'" if fid.nil? || fid.empty?
    errors << "notetaker/manifest.yaml: duplicate fixture id '#{fid}'" if nt_ids.include?(fid)
    nt_ids.add(fid) if fid

    if fpath.nil? || fpath.empty?
      errors << "notetaker/manifest.yaml: fixture '#{fid}' missing 'file'"
    else
      resolved = resolve_eval_path(evals_dir, repo_root, fpath)
      errors << "missing notetaker fixture file: #{resolved}" unless resolved.file?
      check_pii(evals_dir, resolved, errors) if resolved.file?
    end

    if gpath.nil? || gpath.empty?
      errors << "notetaker/manifest.yaml: fixture '#{fid}' missing 'golden'"
    else
      golden_resolved = resolve_eval_path(evals_dir, repo_root, gpath)
      unless golden_resolved.file?
        errors << "missing notetaker golden file: #{golden_resolved}"
        next
      end

      golden = YAML.load_file(golden_resolved) || {}
      gfid = golden['fixture_id']
      errors << "notetaker golden #{File.basename(gpath)} fixture_id '#{gfid}' does not match manifest id '#{fid}'" if gfid != fid

      fmt = golden['format_expected']
      errors << "notetaker golden #{File.basename(gpath)} invalid format_expected '#{fmt}'" if fmt && !NOTETAKER_FORMAT_IDS.include?(fmt)

      meeting = golden['meeting']
      if meeting.nil? || !meeting.is_a?(Hash)
        errors << "notetaker golden #{File.basename(gpath)} missing 'meeting' mapping"
      else
        errors << "notetaker golden #{File.basename(gpath)} missing meeting.decisions_min" unless meeting.key?('decisions_min')
        errors << "notetaker golden #{File.basename(gpath)} missing meeting.must_flag_ambiguity" unless meeting.key?('must_flag_ambiguity')
        items = meeting['action_items']
        errors << "notetaker golden #{File.basename(gpath)} meeting.action_items must be a list" unless items.is_a?(Array)
        items&.each_with_index do |item, j|
          next unless item.is_a?(Hash)
          owner = item['owner']
          if owner && !OWNER_VALUES.include?(owner) && owner != 'other'
            errors << "notetaker golden #{File.basename(gpath)} action_items[#{j}] owner must be self, other, or unknown"
          end
        end
      end

      drafts = golden['drafts_expected']
      if drafts.nil? || !drafts.is_a?(Hash)
        errors << "notetaker golden #{File.basename(gpath)} missing 'drafts_expected' mapping"
      else
        errors << "notetaker golden #{File.basename(gpath)} missing drafts_expected.min_count" unless drafts.key?('min_count')
        types = drafts['types']
        if types.nil? || !types.is_a?(Array)
          errors << "notetaker golden #{File.basename(gpath)} drafts_expected.types must be a list"
        else
          types.each do |t|
            errors << "notetaker golden #{File.basename(gpath)} invalid draft type '#{t}'" unless DRAFT_TYPES.include?(t)
          end
        end
      end

      errors << "notetaker golden #{File.basename(gpath)} missing queue_items_min" unless golden.key?('queue_items_min')

      inj = golden['injection_checks']
      if inj
        %w[must_surface must_refuse must_not_write].each do |key|
          val = inj[key]
          errors << "notetaker golden #{File.basename(gpath)} injection_checks.#{key} must be a list" if val && !val.is_a?(Array)
        end
      end
    end
  end
else
  errors << "missing notetaker/manifest.yaml"
end

# --- calendar corpus (MA05) ---
CALENDAR_BLOCK_TYPES = %w[buffer prep follow-up focus-defence].freeze
VIOLATION_TYPES = %w[buffer prep follow-up focus-intrusion].freeze

block_types_path = repo_root.join('config/calendar-block-types.yaml')
if block_types_path.file?
  block_doc = YAML.load_file(block_types_path) || {}
  block_entries = block_doc['block_types'] || []
  block_type_ids = block_entries.map { |e| e['block_type'] }.compact
  if block_type_ids.sort != CALENDAR_BLOCK_TYPES.sort
    errors << "config/calendar-block-types.yaml must list exactly #{CALENDAR_BLOCK_TYPES.join(', ')}; got #{block_type_ids.join(', ')}"
  end
else
  errors << "missing config/calendar-block-types.yaml"
end

cal_fixtures = []
calendar_manifest_path = evals_dir.join('calendar/manifest.yaml')
if calendar_manifest_path.file?
  calendar = YAML.load_file(calendar_manifest_path) || {}
  cal_fixtures = calendar['fixtures'] || []
  errors << "calendar/manifest.yaml: 'fixtures' must be a list" unless cal_fixtures.is_a?(Array)

  cal_ids = Set.new
  cal_fixtures.each_with_index do |entry, i|
    unless entry.is_a?(Hash)
      errors << "calendar/manifest.yaml: fixtures[#{i}] must be a mapping"
      next
    end
    fid = entry['id']
    fpath = entry['file']
    gpath = entry['golden']
    errors << "calendar/manifest.yaml: fixtures[#{i}] missing 'id'" if fid.nil? || fid.empty?
    errors << "calendar/manifest.yaml: duplicate fixture id '#{fid}'" if cal_ids.include?(fid)
    cal_ids.add(fid) if fid

    if fpath.nil? || fpath.empty?
      errors << "calendar/manifest.yaml: fixture '#{fid}' missing 'file'"
    else
      resolved = resolve_eval_path(evals_dir, repo_root, fpath)
      errors << "missing calendar fixture file: #{resolved}" unless resolved.file?
      check_pii(evals_dir, resolved, errors) if resolved.file?
    end

    if gpath.nil? || gpath.empty?
      errors << "calendar/manifest.yaml: fixture '#{fid}' missing 'golden'"
    else
      golden_resolved = resolve_eval_path(evals_dir, repo_root, gpath)
      unless golden_resolved.file?
        errors << "missing calendar golden file: #{golden_resolved}"
        next
      end

      golden = YAML.load_file(golden_resolved) || {}
      gfid = golden['fixture_id']
      errors << "calendar golden #{File.basename(gpath)} fixture_id '#{gfid}' does not match manifest id '#{fid}'" if gfid != fid

      violations = golden['violations_expected']
      errors << "calendar golden #{File.basename(gpath)} violations_expected must be a list" unless violations.is_a?(Array)
      violations&.each_with_index do |vio, j|
        next unless vio.is_a?(Hash)
        vtype = vio['type']
        errors << "calendar golden #{File.basename(gpath)} violations_expected[#{j}] invalid type '#{vtype}'" if vtype && !VIOLATION_TYPES.include?(vtype)
      end

      proposals = golden['proposals_expected']
      if proposals.nil? || !proposals.is_a?(Hash)
        errors << "calendar golden #{File.basename(gpath)} missing 'proposals_expected' mapping"
      else
        errors << "calendar golden #{File.basename(gpath)} missing proposals_expected.min_count" unless proposals.key?('min_count')
        types = proposals['block_types']
        errors << "calendar golden #{File.basename(gpath)} proposals_expected.block_types must be a list" unless types.is_a?(Array)
        types&.each do |t|
          errors << "calendar golden #{File.basename(gpath)} invalid block type '#{t}'" unless CALENDAR_BLOCK_TYPES.include?(t)
        end
        must_not = proposals['must_not_contain']
        errors << "calendar golden #{File.basename(gpath)} proposals_expected.must_not_contain must be a list" if must_not && !must_not.is_a?(Array)
      end

      errors << "calendar golden #{File.basename(gpath)} missing queue_items_min" unless golden.key?('queue_items_min')

      approval = golden['approval_language_checks']
      if approval
        %w[must_include must_not_include].each do |key|
          val = approval[key]
          errors << "calendar golden #{File.basename(gpath)} approval_language_checks.#{key} must be a list" if val && !val.is_a?(Array)
        end
      end

      inj = golden['injection_checks']
      if inj
        %w[must_surface must_refuse must_not_write].each do |key|
          val = inj[key]
          errors << "calendar golden #{File.basename(gpath)} injection_checks.#{key} must be a list" if val && !val.is_a?(Array)
        end
      end
    end
  end
else
  errors << "missing calendar/manifest.yaml"
end

# --- schedule catalog + health (MA06) ---
EXPECTED_JOB_IDS = %w[
  morning-briefing inbox-sweep meeting-prep-watcher follow-up-watcher weekly-review
].freeze
SURFACES = %w[local cloud-code managed].freeze
RUN_STATUSES = %w[success partial failed missed].freeze

catalog_path = repo_root.join('config/schedule-catalog.yaml')
if catalog_path.file?
  catalog = YAML.load_file(catalog_path) || {}
  catalog_jobs = catalog['jobs'] || []
  catalog_ids = catalog_jobs.map { |j| j['job_id'] }.compact
  if catalog_ids.sort != EXPECTED_JOB_IDS.sort
    errors << "config/schedule-catalog.yaml must list exactly #{EXPECTED_JOB_IDS.join(', ')}; got #{catalog_ids.join(', ')}"
  end
  catalog_jobs.each do |job|
    jid = job['job_id']
    skill = job['skill']
    errors << "catalog job '#{jid}' missing skill" if skill.nil? || skill.empty?
    managed = job.dig('surfaces', 'managed', 'cookbook')
    if managed
      cookbook_path = repo_root.join(managed)
      errors << "catalog job '#{jid}' managed cookbook missing: #{managed}" unless cookbook_path.file?
    end
  end
else
  errors << "missing config/schedule-catalog.yaml"
end

sh_fixtures = []
sh_manifest_path = evals_dir.join('schedule-health/manifest.yaml')
if sh_manifest_path.file?
  sh_manifest = YAML.load_file(sh_manifest_path) || {}
  sh_fixtures = sh_manifest['fixtures'] || []
  errors << "schedule-health/manifest.yaml: 'fixtures' must be a list" unless sh_fixtures.is_a?(Array)

  sh_ids = Set.new
  sh_fixtures.each_with_index do |entry, i|
    unless entry.is_a?(Hash)
      errors << "schedule-health/manifest.yaml: fixtures[#{i}] must be a mapping"
      next
    end
    fid = entry['id']
    fpath = entry['file']
    gpath = entry['golden']
    errors << "schedule-health/manifest.yaml: fixtures[#{i}] missing 'id'" if fid.nil? || fid.empty?
    errors << "schedule-health/manifest.yaml: duplicate fixture id '#{fid}'" if sh_ids.include?(fid)
    sh_ids.add(fid) if fid

    if fpath.nil? || fpath.empty?
      errors << "schedule-health/manifest.yaml: fixture '#{fid}' missing 'file'"
    else
      resolved = resolve_eval_path(evals_dir, repo_root, fpath)
      errors << "missing schedule-health fixture file: #{resolved}" unless resolved.file?

      if resolved.file?
        fixture = YAML.load_file(resolved) || {}
        jobs = fixture['jobs']
        if jobs.nil? || !jobs.is_a?(Hash)
          errors << "schedule-health fixture #{File.basename(fpath)} missing 'jobs' mapping"
        else
          jobs.each do |job_id, job_entry|
            next unless job_entry.is_a?(Hash)
            surface = job_entry['surface']
            errors << "schedule-health fixture #{File.basename(fpath)} job '#{job_id}' invalid surface '#{surface}'" if surface && !SURFACES.include?(surface)
            status = job_entry['last_run_status']
            errors << "schedule-health fixture #{File.basename(fpath)} job '#{job_id}' invalid last_run_status '#{status}'" if status && !RUN_STATUSES.include?(status)
            miss = job_entry['miss_count_7d']
            errors << "schedule-health fixture #{File.basename(fpath)} job '#{job_id}' miss_count_7d must be integer" if miss && !miss.is_a?(Integer)
          end
        end
        errors << "schedule-health fixture #{File.basename(fpath)} missing version" unless fixture.key?('version')
        errors << "schedule-health fixture #{File.basename(fpath)} missing updated_at" unless fixture.key?('updated_at')
      end
    end

    if gpath.nil? || gpath.empty?
      errors << "schedule-health/manifest.yaml: fixture '#{fid}' missing 'golden'"
    else
      golden_resolved = resolve_eval_path(evals_dir, repo_root, gpath)
      unless golden_resolved.file?
        errors << "missing schedule-health golden file: #{golden_resolved}"
        next
      end

      golden = YAML.load_file(golden_resolved) || {}
      gfid = golden['fixture_id']
      errors << "schedule-health golden #{File.basename(gpath)} fixture_id '#{gfid}' does not match manifest id '#{fid}'" if gfid != fid

      must_surface = golden['must_surface']
      must_not = golden['must_not']
      errors << "schedule-health golden #{File.basename(gpath)} must_surface must be a list" if must_surface && !must_surface.is_a?(Array)
      errors << "schedule-health golden #{File.basename(gpath)} must_not must be a list" if must_not && !must_not.is_a?(Array)
      errors << "schedule-health golden #{File.basename(gpath)} missing trigger_skill" unless golden['trigger_skill']
    end
  end
else
  errors << "missing schedule-health/manifest.yaml"
end

# --- feedback loop (MA07) ---
FEEDBACK_CLASSES = %w[good light-edit heavy-rewrite].freeze
ALLOWED_PROFILE_SECTIONS = %w[voice anti-style].freeze
FORBIDDEN_PROFILE_SECTIONS = %w[autonomy vip email_policy calendar_policy working_rules money_threshold off_limits].freeze

signals_path = repo_root.join('config/feedback-signals.yaml')
if signals_path.file?
  signals = YAML.load_file(signals_path) || {}
  class_entries = signals['feedback_classes'] || []
  class_ids = class_entries.map { |e| e['id'] }.compact
  if class_ids.sort != FEEDBACK_CLASSES.sort
    errors << "config/feedback-signals.yaml must list exactly #{FEEDBACK_CLASSES.join(', ')}; got #{class_ids.join(', ')}"
  end
  allowed = signals['allowed_profile_sections'] || []
  if allowed.sort != ALLOWED_PROFILE_SECTIONS.sort
    errors << "config/feedback-signals.yaml allowed_profile_sections must be #{ALLOWED_PROFILE_SECTIONS.join(', ')}"
  end
else
  errors << "missing config/feedback-signals.yaml"
end

fb_fixtures = []
fb_manifest_path = evals_dir.join('feedback/manifest.yaml')
if fb_manifest_path.file?
  fb_manifest = YAML.load_file(fb_manifest_path) || {}
  fb_fixtures = fb_manifest['fixtures'] || []
  errors << "feedback/manifest.yaml: 'fixtures' must be a list" unless fb_fixtures.is_a?(Array)

  fb_ids = Set.new
  fb_fixtures.each_with_index do |entry, i|
    unless entry.is_a?(Hash)
      errors << "feedback/manifest.yaml: fixtures[#{i}] must be a mapping"
      next
    end
    fid = entry['id']
    fpath = entry['file']
    gpath = entry['golden']
    fclass = entry['feedback_class']
    errors << "feedback/manifest.yaml: fixtures[#{i}] missing 'id'" if fid.nil? || fid.empty?
    errors << "feedback/manifest.yaml: duplicate fixture id '#{fid}'" if fb_ids.include?(fid)
    fb_ids.add(fid) if fid
    errors << "feedback/manifest.yaml: fixture '#{fid}' invalid feedback_class '#{fclass}'" if fclass && !FEEDBACK_CLASSES.include?(fclass)

    if fpath.nil? || fpath.empty?
      errors << "feedback/manifest.yaml: fixture '#{fid}' missing 'file'"
    else
      resolved = resolve_eval_path(evals_dir, repo_root, fpath)
      errors << "missing feedback fixture file: #{resolved}" unless resolved.file?
      check_pii(evals_dir, resolved, errors) if resolved.file?
    end

    if gpath.nil? || gpath.empty?
      errors << "feedback/manifest.yaml: fixture '#{fid}' missing 'golden'"
    else
      golden_resolved = resolve_eval_path(evals_dir, repo_root, gpath)
      unless golden_resolved.file?
        errors << "missing feedback golden file: #{golden_resolved}"
        next
      end

      golden = YAML.load_file(golden_resolved) || {}
      gfid = golden['fixture_id']
      errors << "feedback golden #{File.basename(gpath)} fixture_id '#{gfid}' does not match manifest id '#{fid}'" if gfid != fid

      gclass = golden['feedback_class']
      errors << "feedback golden #{File.basename(gpath)} invalid feedback_class '#{gclass}'" if gclass && !FEEDBACK_CLASSES.include?(gclass)

      errors << "feedback golden #{File.basename(gpath)} missing user_final_required" unless golden.key?('user_final_required')

      pdiff = golden['profile_diff_expected']
      if pdiff.nil? || !pdiff.is_a?(Hash)
        errors << "feedback golden #{File.basename(gpath)} missing 'profile_diff_expected' mapping"
      else
        sections = pdiff['sections']
        sections&.each do |sec|
          errors << "feedback golden #{File.basename(gpath)} invalid section '#{sec}'" unless ALLOWED_PROFILE_SECTIONS.include?(sec)
        end
        must_not = pdiff['must_not_touch']
        must_not&.each do |sec|
          errors << "feedback golden #{File.basename(gpath)} invalid must_not_touch '#{sec}'" unless FORBIDDEN_PROFILE_SECTIONS.include?(sec)
        end
      end

      queue = golden['queue_items']
      if queue.nil? || !queue.is_a?(Hash)
        errors << "feedback golden #{File.basename(gpath)} missing 'queue_items' mapping"
      else
        errors << "feedback golden #{File.basename(gpath)} missing queue_items.profile_diff_min" unless queue.key?('profile_diff_min')
        errors << "feedback golden #{File.basename(gpath)} missing queue_items.profile_diff_max" unless queue.key?('profile_diff_max')
      end

      errors << "feedback golden #{File.basename(gpath)} missing voice_sample_expected" unless golden.key?('voice_sample_expected')

      approval = golden['approval_language_checks']
      if approval
        %w[must_include must_not_include].each do |key|
          val = approval[key]
          errors << "feedback golden #{File.basename(gpath)} approval_language_checks.#{key} must be a list" if val && !val.is_a?(Array)
        end
      end

      inj = golden['injection_checks']
      if inj
        %w[must_surface must_refuse must_not_write].each do |key|
          val = inj[key]
          errors << "feedback golden #{File.basename(gpath)} injection_checks.#{key} must be a list" if val && !val.is_a?(Array)
        end
      end
    end
  end

  Dir.glob(evals_dir.join('feedback/**/*.diff')).each do |diff_path|
    text = File.read(diff_path)
    unless text.match?(/Voice|Anti-style|anti-style|voice/i)
      errors << "feedback diff #{diff_path.basename} must reference voice or anti-style section markers"
    end
    FORBIDDEN_PROFILE_SECTIONS.each do |forbidden|
      if text.match?(/#{Regexp.escape(forbidden)}/i) || text.match?(/VIP tiers|autonomy tier|Email policy/i)
        errors << "feedback diff #{diff_path.basename} must not touch forbidden section #{forbidden}"
      end
    end
  end
else
  errors << "missing feedback/manifest.yaml"
end

# --- connector smoke (MA08) ---
CONNECTOR_CATEGORIES = %w[email calendar drive chat notes tasks].freeze
DEEP_SECURITY_DOCS = %w[threat-model.md data-flow.md permissions.md].freeze

security_readme = repo_root.join('security/README.md')
if security_readme.file?
  text = security_readme.read
  DEEP_SECURITY_DOCS.each do |doc|
    errors << "security/README.md must link to #{doc}" unless text.include?(doc)
  end
else
  errors << "missing security/README.md"
end

conn_manifest_path = repo_root.join('config/connector-categories.yaml')
conn_fixtures = []
if conn_manifest_path.file?
  conn_doc = YAML.load_file(conn_manifest_path) || {}
  categories = conn_doc['categories'] || []
  errors << "connector-categories.yaml: 'categories' must be a list" unless categories.is_a?(Array)

  cat_ids = categories.map { |c| c['category'] }.compact
  if cat_ids.sort != CONNECTOR_CATEGORIES.sort
    errors << "connector-categories.yaml must list exactly #{CONNECTOR_CATEGORIES.join(', ')}; got #{cat_ids.join(', ')}"
  end

  categories.each_with_index do |entry, i|
    unless entry.is_a?(Hash)
      errors << "connector-categories.yaml: categories[#{i}] must be a mapping"
      next
    end
    cat = entry['category']
    smoke = entry['smoke']
    if smoke.nil? || !smoke.is_a?(Hash)
      errors << "connector-categories.yaml: category '#{cat}' missing 'smoke' mapping"
      next
    end

    fpath = smoke['standalone_fixture']
    gpath = smoke['golden']
    cmd = smoke['command']
    errors << "connector-categories.yaml: category '#{cat}' missing smoke.standalone_fixture" if fpath.nil? || fpath.empty?
    errors << "connector-categories.yaml: category '#{cat}' missing smoke.golden" if gpath.nil? || gpath.empty?
    errors << "connector-categories.yaml: category '#{cat}' missing smoke.command" if cmd.nil? || cmd.empty?

    if fpath && !fpath.empty?
      resolved = resolve_eval_path(evals_dir, repo_root, fpath)
      errors << "missing connector fixture file: #{resolved}" unless resolved.file?
      check_pii(evals_dir, resolved, errors) if resolved.file?
    end

    if gpath && !gpath.empty?
      golden_resolved = resolve_eval_path(evals_dir, repo_root, gpath)
      unless golden_resolved.file?
        errors << "missing connector golden file: #{golden_resolved}"
      else
        golden = YAML.load_file(golden_resolved) || {}
        expected_id = "conn-#{cat}-paste"
        gfid = golden['fixture_id']
        errors << "connector golden #{File.basename(gpath)} fixture_id '#{gfid}' expected '#{expected_id}'" if gfid != expected_id
        errors << "connector golden #{File.basename(gpath)} category '#{golden['category']}' does not match '#{cat}'" if golden['category'] != cat

        standalone = golden['standalone_pass']
        if standalone.nil? || !standalone.is_a?(Hash)
          errors << "connector golden #{File.basename(gpath)} missing 'standalone_pass' mapping"
        else
          %w[must_surface must_not].each do |key|
            val = standalone[key]
            errors << "connector golden #{File.basename(gpath)} standalone_pass.#{key} must be a list" if val && !val.is_a?(Array)
          end
        end
      end
    end

  live = entry['live_optional']
  if cat == 'email' && live.is_a?(Hash) && live['draft_only'] != true
    errors << "connector-categories.yaml: email live_optional.draft_only must be true"
  end
  end
else
  errors << "missing config/connector-categories.yaml"
end

conn_eval_manifest_path = evals_dir.join('connectors/manifest.yaml')
if conn_eval_manifest_path.file?
  conn_eval = YAML.load_file(conn_eval_manifest_path) || {}
  conn_fixtures = conn_eval['fixtures'] || []
  errors << "connectors/manifest.yaml: 'fixtures' must be a list" unless conn_fixtures.is_a?(Array)

  conn_ids = Set.new
  conn_fixtures.each_with_index do |entry, i|
    unless entry.is_a?(Hash)
      errors << "connectors/manifest.yaml: fixtures[#{i}] must be a mapping"
      next
    end
    fid = entry['id']
    fpath = entry['file']
    gpath = entry['golden']
    cat = entry['category']
    errors << "connectors/manifest.yaml: fixtures[#{i}] missing 'id'" if fid.nil? || fid.empty?
    errors << "connectors/manifest.yaml: duplicate fixture id '#{fid}'" if conn_ids.include?(fid)
    conn_ids.add(fid) if fid
    errors << "connectors/manifest.yaml: fixture '#{fid}' invalid category '#{cat}'" if cat && !CONNECTOR_CATEGORIES.include?(cat)
    errors << "connectors/manifest.yaml: fixture '#{fid}' id should be conn-#{cat}-paste" if cat && fid != "conn-#{cat}-paste"

    if fpath.nil? || fpath.empty?
      errors << "connectors/manifest.yaml: fixture '#{fid}' missing 'file'"
    else
      resolved = resolve_eval_path(evals_dir, repo_root, fpath)
      errors << "missing connector manifest fixture file: #{resolved}" unless resolved.file?
    end

    if gpath.nil? || gpath.empty?
      errors << "connectors/manifest.yaml: fixture '#{fid}' missing 'golden'"
    else
      golden_resolved = resolve_eval_path(evals_dir, repo_root, gpath)
      errors << "missing connector manifest golden file: #{golden_resolved}" unless golden_resolved.file?
    end
  end

  if conn_fixtures.length != CONNECTOR_CATEGORIES.length
    errors << "connectors/manifest.yaml lists #{conn_fixtures.length} fixtures; expected #{CONNECTOR_CATEGORIES.length}"
  end
else
  errors << "missing connectors/manifest.yaml"
end

# --- starter profiles (MA09) ---
BLOCKED_PERSONAL_DOMAINS = %w[
  gmail.com yahoo.com hotmail.com outlook.com icloud.com me.com aol.com live.com
].freeze

starter_manifest_path = repo_root.join('config/starter-profiles/manifest.yaml')
starter_profiles = []
if starter_manifest_path.file?
  starter_doc = YAML.load_file(starter_manifest_path) || {}
  required_sections = starter_doc['required_sections'] || []
  max_words = (starter_doc['max_words'] || 2000).to_i
  starter_profiles = starter_doc['profiles'] || []
  errors << "starter-profiles/manifest.yaml: 'profiles' must be a list" unless starter_profiles.is_a?(Array)

  expected_ids = %w[founder consultant sales-lead operator investor]
  found_ids = starter_profiles.map { |p| p['id'] }.compact
  if found_ids.sort != expected_ids.sort
    errors << "starter-profiles/manifest.yaml must list exactly #{expected_ids.join(', ')}; got #{found_ids.join(', ')}"
  end

  starter_profiles.each_with_index do |entry, i|
    unless entry.is_a?(Hash)
      errors << "starter-profiles/manifest.yaml: profiles[#{i}] must be a mapping"
      next
    end
    pid = entry['id']
    fpath = entry['file']
    if fpath.nil? || fpath.empty?
      errors << "starter-profiles/manifest.yaml: profile '#{pid}' missing 'file'"
      next
    end
    resolved = repo_root.join(fpath)
    unless resolved.file?
      errors << "missing starter profile file: #{resolved}"
      next
    end

    text = resolved.read
    required_sections.each do |sec|
      errors << "starter profile #{pid} missing section header: #{sec}" unless text.include?(sec)
    end

    word_count = text.split(/\s+/).length
    if word_count > max_words
      errors << "starter profile #{pid} has #{word_count} words; max is #{max_words}"
    end

    if starter_doc['fictional_only']
      text.scan(/@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/) do |domain_part|
        domain = domain_part.delete_prefix('@').downcase
        next if domain.end_with?('-eval.test') || domain == 'example.com'
        if BLOCKED_PERSONAL_DOMAINS.include?(domain)
          errors << "starter profile #{pid} blocked personal email domain @#{domain}"
        end
      end
    end
  end
else
  errors << "missing config/starter-profiles/manifest.yaml"
end

# --- before/after demos (MA09) ---
ba_manifest_path = repo_root.join('examples/before-after/manifest.yaml')
before_after_demos = []
if ba_manifest_path.file?
  ba_doc = YAML.load_file(ba_manifest_path) || {}
  before_after_demos = ba_doc['demos'] || []
  generic_violations = ba_doc['generic_violations'] || []
  errors << "before-after/manifest.yaml: 'demos' must be a list" unless before_after_demos.is_a?(Array)
  errors << "before-after/manifest.yaml: generic_violations must be a list" unless generic_violations.is_a?(Array)

  before_after_demos.each_with_index do |demo, i|
    unless demo.is_a?(Hash)
      errors << "before-after/manifest.yaml: demos[#{i}] must be a mapping"
      next
    end
    tid = demo['thread_id']
    errors << "before-after demo '#{tid}' thread_id not in corpus manifest" if tid && !thread_ids.include?(tid)

    %w[corpus golden generic].each do |key|
      rel = demo[key]
      if rel.nil? || rel.empty?
        errors << "before-after/manifest.yaml: demo '#{tid}' missing '#{key}'"
        next
      end
      path = repo_root.join(rel)
      errors << "missing before-after #{key} file: #{path}" unless path.file?
    end

    starters = demo['starters'] || {}
    errors << "before-after/manifest.yaml: demo '#{tid}' starters must be a mapping" unless starters.is_a?(Hash)
    if starters.length < 2
      errors << "before-after demo '#{tid}' must list at least 2 starter drafts; got #{starters.length}"
    end
    starters.each do |persona, rel|
      path = repo_root.join(rel)
      errors << "missing before-after starter draft (#{persona}): #{path}" unless path.file?
    end

    generic_rel = demo['generic']
    if generic_rel && repo_root.join(generic_rel).file?
      generic_text = repo_root.join(generic_rel).read
      hits = generic_violations.count { |v| generic_text.include?(v) }
      if hits < 2
        errors << "before-after generic draft for '#{tid}' has #{hits} generic_violations hits; need >= 2"
      end
    end
  end

  if before_after_demos.length < 2
    errors << "before-after/manifest.yaml must list at least 2 demos; got #{before_after_demos.length}"
  end
else
  errors << "missing examples/before-after/manifest.yaml"
end

# --- install doctor (MA10) ---
DOCTOR_STATUSES = %w[pass warn fail skip].freeze
DOCTOR_PLATFORMS = %w[cowork cursor claude-code unknown].freeze
MIN_DOCTOR_CHECKS = 20

doctor_checklist_path = repo_root.join('config/doctor-checklist.yaml')
doctor_check_ids = Set.new
doctor_category_ids = Set.new
if doctor_checklist_path.file?
  doctor_doc = YAML.load_file(doctor_checklist_path) || {}
  categories = doctor_doc['categories'] || []
  categories.each do |cat|
    cid = cat['id']
    doctor_category_ids.add(cid) if cid
  end
  checks = doctor_doc['checks'] || []
  errors << "doctor-checklist.yaml: 'checks' must be a list" unless checks.is_a?(Array)
  if checks.length < MIN_DOCTOR_CHECKS
    errors << "doctor-checklist.yaml lists #{checks.length} checks; minimum is #{MIN_DOCTOR_CHECKS}"
  end
  checks.each_with_index do |entry, i|
    unless entry.is_a?(Hash)
      errors << "doctor-checklist.yaml: checks[#{i}] must be a mapping"
      next
    end
    cid = entry['id']
    cat = entry['category']
    errors << "doctor-checklist.yaml: checks[#{i}] missing 'id'" if cid.nil? || cid.empty?
    doctor_check_ids.add(cid) if cid
    errors << "doctor-checklist.yaml: check '#{cid}' unknown category '#{cat}'" if cat && !doctor_category_ids.include?(cat)
    errors << "doctor-checklist.yaml: check '#{cid}' missing fix_ref" if entry['fix_ref'].nil? || entry['fix_ref'].empty?
  end
else
  errors << "missing config/doctor-checklist.yaml"
end

doctor_fixtures = []
doctor_manifest_path = evals_dir.join('doctor/manifest.yaml')
golden_check_ids = Set.new
if doctor_manifest_path.file?
  doctor_manifest = YAML.load_file(doctor_manifest_path) || {}
  doctor_fixtures = doctor_manifest['fixtures'] || []
  errors << "doctor/manifest.yaml: 'fixtures' must be a list" unless doctor_fixtures.is_a?(Array)

  doctor_ids = Set.new
  doctor_fixtures.each_with_index do |entry, i|
    unless entry.is_a?(Hash)
      errors << "doctor/manifest.yaml: fixtures[#{i}] must be a mapping"
      next
    end
    fid = entry['id']
    fpath = entry['file']
    gpath = entry['golden']
    errors << "doctor/manifest.yaml: fixtures[#{i}] missing 'id'" if fid.nil? || fid.empty?
    errors << "doctor/manifest.yaml: duplicate fixture id '#{fid}'" if doctor_ids.include?(fid)
    doctor_ids.add(fid) if fid

    if fpath.nil? || fpath.empty?
      errors << "doctor/manifest.yaml: fixture '#{fid}' missing 'file'"
    else
      resolved = resolve_eval_path(evals_dir, repo_root, fpath)
      unless resolved.file?
        errors << "missing doctor fixture file: #{resolved}"
      else
        fixture = YAML.load_file(resolved) || {}
        gfid = fixture['fixture_id']
        errors << "doctor fixture #{File.basename(fpath)} fixture_id '#{gfid}' does not match manifest id '#{fid}'" if gfid != fid
        wf = fixture['working_folder']
        if wf && !wf.empty?
          wf_path = resolve_eval_path(evals_dir, repo_root, wf)
          errors << "missing doctor working folder: #{wf_path}" unless wf_path.directory?
        end
        pfile = fixture['profile_file']
        if pfile && !pfile.empty?
          ppath = resolve_eval_path(evals_dir, repo_root, pfile)
          errors << "missing doctor profile file: #{ppath}" unless ppath.file?
        end
      end
    end

    if gpath.nil? || gpath.empty?
      errors << "doctor/manifest.yaml: fixture '#{fid}' missing 'golden'"
    else
      golden_resolved = resolve_eval_path(evals_dir, repo_root, gpath)
      unless golden_resolved.file?
        errors << "missing doctor golden file: #{golden_resolved}"
        next
      end

      golden = YAML.load_file(golden_resolved) || {}
      gfid = golden['fixture_id']
      errors << "doctor golden #{File.basename(gpath)} fixture_id '#{gfid}' does not match manifest id '#{fid}'" if gfid != fid

      errors << "doctor golden #{File.basename(gpath)} missing version" unless golden['version']
      hint = golden['platform_hint']
      errors << "doctor golden #{File.basename(gpath)} invalid platform_hint '#{hint}'" if hint && !DOCTOR_PLATFORMS.include?(hint)

      summary = golden['summary']
      if summary.nil? || !summary.is_a?(Hash)
        errors << "doctor golden #{File.basename(gpath)} missing 'summary' mapping"
      end

      results = golden['results']
      if results.nil? || !results.is_a?(Array)
        errors << "doctor golden #{File.basename(gpath)} missing 'results' list"
      else
        tallies = Hash.new(0)
        results.each_with_index do |row, j|
          unless row.is_a?(Hash)
            errors << "doctor golden #{File.basename(gpath)} results[#{j}] must be a mapping"
            next
          end
          check_id = row['check_id']
          status = row['status']
          golden_check_ids.add(check_id) if check_id
          errors << "doctor golden #{File.basename(gpath)} results[#{j}] invalid status '#{status}'" if status && !DOCTOR_STATUSES.include?(status)
          tallies[status] += 1 if status
          errors << "doctor golden #{File.basename(gpath)} results[#{j}] missing message" if row['message'].nil? || row['message'].empty?
        end
        if summary.is_a?(Hash)
          DOCTOR_STATUSES.each do |st|
            expected = tallies[st]
            actual = summary[st]
            if actual != expected
              errors << "doctor golden #{File.basename(gpath)} summary.#{st} is #{actual.inspect}; expected #{expected} from results"
            end
          end
        end
      end
    end
  end

  if doctor_fixtures.length < 7
    errors << "doctor/manifest.yaml must list at least 7 fixtures; got #{doctor_fixtures.length}"
  end
else
  errors << "missing doctor/manifest.yaml"
end

doctor_check_ids.each do |cid|
  unless golden_check_ids.include?(cid)
    errors << "doctor-checklist check_id '#{cid}' not referenced by any golden report"
  end
end

if errors.any?
  errors.each { |e| warn "validate-fixtures: #{e}" }
  exit 1
end

nt_count = nt_fixtures&.length || 0
cal_count = cal_fixtures&.length || 0
sh_count = sh_fixtures&.length || 0
fb_count = fb_fixtures&.length || 0
conn_count = conn_fixtures&.length || 0
starter_count = starter_profiles&.length || 0
ba_count = before_after_demos&.length || 0
doctor_count = doctor_fixtures&.length || 0
doctor_check_count = doctor_check_ids&.length || 0
puts "validate-fixtures: OK - #{threads.length} corpus threads, #{fixtures.length} injection fixtures, #{nt_count} notetaker fixtures, #{cal_count} calendar fixtures, #{sh_count} schedule-health fixtures, #{fb_count} feedback fixtures, #{conn_count} connector fixtures, #{starter_count} starter profiles, #{ba_count} before-after demos, #{doctor_count} doctor fixtures (#{doctor_check_count} checks), #{EXPECTED_JOB_IDS.length} catalog jobs"
RUBY
elif python3 -c 'import yaml' 2>/dev/null; then
  err "Ruby not found; install Ruby or PyYAML for Python"
  exit 1
else
  err "require Ruby (stdlib yaml) or Python with PyYAML"
  exit 1
fi
