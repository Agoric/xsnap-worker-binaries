#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

version="$(require_version)"
input_dir="${1:-manifests}"
output_file="${2:-manifests/$version.json}"

if [[ ! -d "$input_dir" ]]; then
  echo "Manifest input directory not found: $input_dir" >&2
  exit 1
fi

mkdir -p "$(dirname "$output_file")"
targets_csv="$(resolve_targets | paste -sd, -)"

node - "$input_dir" "$output_file" "$version" "$targets_csv" <<'NODE'
const fs = require('fs');
const path = require('path');

const [inputDir, outputFile, version, targetsCsv] = process.argv.slice(2);
const expectedTargets = targetsCsv.split(',').filter(Boolean);

const files = fs
  .readdirSync(inputDir)
  .filter(name => name.endsWith('.json'))
  .sort();

if (files.length === 0) {
  throw new Error(`No manifest JSON files found in ${inputDir}`);
}

const merged = {
  version,
  generatedAt: new Date().toISOString(),
  targets: {},
};

for (const file of files) {
  const manifestPath = path.join(inputDir, file);
  const data = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

  if (data.version !== version) {
    throw new Error(
      `Manifest ${file} has version ${data.version}; expected ${version}`,
    );
  }

  for (const [target, entry] of Object.entries(data.targets || {})) {
    if (merged.targets[target]) {
      throw new Error(`Duplicate target ${target} found in ${file}`);
    }
    merged.targets[target] = entry;
  }
}

for (const target of expectedTargets) {
  if (!merged.targets[target]) {
    throw new Error(`Missing target ${target} in merged manifest`);
  }
}

const unexpected = Object.keys(merged.targets).filter(
  target => !expectedTargets.includes(target),
);
if (unexpected.length > 0) {
  throw new Error(`Unexpected targets in merged manifest: ${unexpected.join(', ')}`);
}

fs.writeFileSync(outputFile, `${JSON.stringify(merged, null, 2)}\n`);
NODE

echo "Merged manifests into $output_file"
