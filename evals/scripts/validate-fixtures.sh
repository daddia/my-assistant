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
  "${EVALS_DIR}/demo/assets" \
  "${EVALS_DIR}/scripts"; do
  require_dir "$dir"
done

require_file "${EVALS_DIR}/corpus/manifest.yaml"
require_file "${EVALS_DIR}/injection/manifest.yaml"
require_file "${EVALS_DIR}/injection/expected-behaviour.yaml"
require_file "${EVALS_DIR}/notetaker/manifest.yaml"
require_file "${REPO_ROOT}/config/notetaker-formats.yaml"

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

if errors.any?
  errors.each { |e| warn "validate-fixtures: #{e}" }
  exit 1
end

nt_count = nt_fixtures&.length || 0
puts "validate-fixtures: OK - #{threads.length} corpus threads, #{fixtures.length} injection fixtures, #{nt_count} notetaker fixtures"
RUBY
elif python3 -c 'import yaml' 2>/dev/null; then
  err "Ruby not found; install Ruby or PyYAML for Python"
  exit 1
else
  err "require Ruby (stdlib yaml) or Python with PyYAML"
  exit 1
fi
