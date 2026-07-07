#!/usr/bin/env bash
# Structural validation for docs/evals/ fixture tree.
# Run from repo root: ./docs/evals/scripts/validate-fixtures.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVALS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${EVALS_DIR}/../.." && pwd)"

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
  "${EVALS_DIR}/demo/assets" \
  "${EVALS_DIR}/scripts"; do
  require_dir "$dir"
done

require_file "${EVALS_DIR}/corpus/manifest.yaml"
require_file "${EVALS_DIR}/injection/manifest.yaml"
require_file "${EVALS_DIR}/injection/expected-behaviour.yaml"

if command -v ruby >/dev/null 2>&1; then
  ruby -ryaml - "${EVALS_DIR}" "${MIN_THREADS}" "${MIN_INJECTION}" <<'RUBY'
require 'yaml'
require 'pathname'
require 'set'

evals_dir = Pathname.new(ARGV[0])
min_threads = ARGV[1].to_i
min_injection = ARGV[2].to_i
repo_root = evals_dir.parent.parent

errors = []

PII_PATTERNS = {
  'ssn' => /\b\d{3}-\d{2}-\d{4}\b/,
  'reserved-domain' => /@[A-Za-z0-9.-]*company\.com\b/i
}.freeze

def resolve_eval_path(evals_dir, repo_root, rel)
  p = Pathname.new(rel)
  return p if p.absolute?
  return repo_root.join(rel) if rel.start_with?('docs/')
  evals_dir.join(rel)
end

def check_pii(evals_dir, path, errors)
  text = path.read
  PII_PATTERNS.each do |label, pattern|
    if text.match?(pattern)
      rel = path.relative_path_from(evals_dir.parent.parent)
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

if errors.any?
  errors.each { |e| warn "validate-fixtures: #{e}" }
  exit 1
end

puts "validate-fixtures: OK - #{threads.length} corpus threads, #{fixtures.length} injection fixtures"
RUBY
elif python3 -c 'import yaml' 2>/dev/null; then
  err "Ruby not found; install Ruby or PyYAML for Python"
  exit 1
else
  err "require Ruby (stdlib yaml) or Python with PyYAML"
  exit 1
fi
