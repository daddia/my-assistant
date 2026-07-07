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

if errors.any?
  errors.each { |e| warn "validate-fixtures: #{e}" }
  exit 1
end

nt_count = nt_fixtures&.length || 0
cal_count = cal_fixtures&.length || 0
sh_count = sh_fixtures&.length || 0
puts "validate-fixtures: OK - #{threads.length} corpus threads, #{fixtures.length} injection fixtures, #{nt_count} notetaker fixtures, #{cal_count} calendar fixtures, #{sh_count} schedule-health fixtures, #{EXPECTED_JOB_IDS.length} catalog jobs"
RUBY
elif python3 -c 'import yaml' 2>/dev/null; then
  err "Ruby not found; install Ruby or PyYAML for Python"
  exit 1
else
  err "require Ruby (stdlib yaml) or Python with PyYAML"
  exit 1
fi
