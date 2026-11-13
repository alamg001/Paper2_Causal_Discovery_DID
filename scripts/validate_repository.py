"""Portable preliminary checks for the Paper2 repository (Python >= 3.10).

This script checks local files. It is not the Palomar protected verifier.
It neither contacts a service nor creates a submission.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import re
import sys
try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib
from pathlib import Path
import yaml

ALLOWED_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}
PIPELINE_SHA = "14aa8d6b3c2f14a8540605e37144560b9a00e7e7"
URL = re.compile(r"https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+(?:\.git)?")
DECL = re.compile(r"[A-Za-z_][A-Za-z0-9_']*(?:\.[A-Za-z_][A-Za-z0-9_']*)*")
SHA = re.compile(r"[0-9a-f]{40}")
EXCLUDED = {".git", ".lake", "__pycache__", ".venv"}

class StrictLoader(yaml.SafeLoader):
    pass

def strict_mapping(loader, node, deep=False):
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if key == "<<" or key in result:
            raise ValueError("Duplicate or merged YAML key")
        result[key] = loader.construct_object(value_node, deep=deep)
    return result

StrictLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, strict_mapping)

def text(path):
    return path.read_text(encoding="utf-8")

def sha256(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()

def require(condition, message):
    if not condition:
        raise ValueError(message)

def inspect(root: Path, check_hashes: bool) -> dict:
    root = root.resolve()
    all_files = [p for p in root.rglob("*") if p.is_file()
                 and not any(part in EXCLUDED for part in p.relative_to(root).parts)]
    needed = ["lean-toolchain", "lake-manifest.json", "Challenge.lean",
              "Solution.lean", "comparator.json", "formalization.yaml", "LICENSE",
              "Audit.lean", "AuditChallenge.lean", "README.md",
              ".github/workflows/verify.yml", ".github/workflows/palomar-preflight.yml"]
    for name in needed:
        require((root / name).is_file(), "Missing file: " + name)
    lakefiles = [p for p in [root / "lakefile.toml", root / "lakefile.lean"] if p.is_file()]
    require(len(lakefiles) == 1, "Exactly one Lakefile is required")
    require(lakefiles[0].name == "lakefile.toml", "This Paper2 validator expects the declarative TOML layout")
    lake = tomllib.loads(text(lakefiles[0]))
    require(lake["name"] == "paper2", "Unexpected Lake package")
    toolchain = text(root / "lean-toolchain").strip()
    require(toolchain == "leanprover/lean4:v4.35.0", "Paper2's validated toolchain pin changed")
    manifest = json.loads(text(root / "lake-manifest.json"))
    for dependency in manifest["packages"]:
        require(dependency["type"] == "git", "This snapshot uses only pinned Git dependencies")
        require(URL.fullmatch(dependency["url"]) is not None, "Invalid GitHub dependency URL")
        require(SHA.fullmatch(dependency["rev"]) is not None, "Dependency not pinned to full SHA")
    mathlib = next(d for d in manifest["packages"] if d["name"] == "mathlib")
    require(mathlib["rev"] == "56a005855ea17e0b0958f73ec801ae140b0a1679", "Validated mathlib revision changed")
    source_info = []
    for path in all_files:
        if path.suffix != ".lean":
            continue
        require(not path.is_symlink(), "Lean source symlink: " + path.name)
        data = text(path)
        require(re.match(r"\s*module(?:\s|$)", data) is not None, "Missing module header: " + path.name)
        require(len(data.splitlines()) <= 10000, "Lean source exceeds 10000 lines: " + path.name)
        require(re.search(r"\b(sorry|admit|sorryAx|native_decide)\b|Lean\.ofReduceBool", data) is None,
                "Admission or forbidden proof shortcut in " + path.name)
        require(re.search(r"(?m)^\s*(?:(?:public|private)\s+)?axiom\b", data) is None,
                "Custom axiom in " + path.name)
        source_info.append({"file": path.relative_to(root).as_posix(),
                            "lines": len(data.splitlines()), "sha256": sha256(path)})
    require(len(source_info) == 11, "Expected the 11 validated Paper2 sources")
    challenge = root / "Challenge.lean"
    require(challenge.stat().st_size <= 100 * 1024, "Challenge exceeds 100 KiB")
    require(len(text(challenge).splitlines()) <= 1000, "Challenge exceeds 1000 lines")
    direct_imports = re.findall(r"(?m)^(?:public )?import\s+(\S+)", text(challenge))
    require(all(item.startswith("Mathlib.") for item in direct_imports),
            "Unexpected direct Challenge import; examine its transitive closure")
    config = json.loads(text(root / "comparator.json"))
    require(set(config) <= {"challenge_module", "solution_module", "theorem_names",
                            "permitted_axioms", "definition_names", "enable_nanoda"},
            "Unsupported submitted Comparator key")
    for key in ["challenge_module", "solution_module", "theorem_names", "permitted_axioms"]:
        require(key in config, "Missing Comparator key: " + key)
    require(config["challenge_module"] == "Challenge" and config["solution_module"] == "Solution",
            "Unexpected compared modules")
    selected = config["theorem_names"]
    require(selected == ["Paper2.finite_cell_CATT_bias", "Paper2.finite_orthogonal_product_bound"],
            "Selected formal claims changed")
    require(set(config["permitted_axioms"]) == ALLOWED_AXIOMS, "Unexpected permitted axioms")
    for declaration in selected:
        require(DECL.fullmatch(declaration) is not None, "Invalid declaration name")
        short = declaration.rsplit(".", 1)[1]
        signatures = []
        for module in ["Challenge", "Solution"]:
            data = text(root / (module + ".lean"))
            require("theorem " + short in data, "Missing theorem in " + module)
            signature = data.split("theorem " + short, 1)[1].split(":= by", 1)[0]
            signatures.append(re.sub(r"\s+", "", signature))
        require(signatures[0] == signatures[1], "Selected source signatures differ")
    metadata = yaml.load(text(root / "formalization.yaml"), Loader=StrictLoader)
    require(metadata.get("version") == "v0.4", "Expected formalization.yaml v0.4")
    project = metadata["project"]
    for key in ["name", "description", "authors", "responsible_maintainers", "license"]:
        require(bool(project.get(key)), "Missing project metadata: " + key)
    require(project["license"] == "MIT", "MIT must match the root license")
    license_names = re.compile(r"(?i)(LICENSE|LICENCE|COPYING|UNLICENSE|OFL)(?:\.(?:md|markdown|txt))?")
    require(len([p for p in root.iterdir() if p.is_file() and license_names.fullmatch(p.name)]) == 1,
            "Exactly one conventional root license file required")
    license_text = text(root / "LICENSE")
    require(license_text.startswith("MIT License") and "Permission is hereby granted" in license_text,
            "Root license text must be the confirmed MIT license")
    for key in ["authors", "responsible_maintainers"]:
        require(isinstance(project[key], list) and all(isinstance(v, str) and v.strip() for v in project[key]),
                "Author/maintainer names must be nonempty strings")
    require(1 <= len(metadata["classification"]["arxiv"]) <= 2, "Use one or two arXiv categories in this prepared snapshot")
    require(1 <= len(metadata["classification"]["msc2020"]) <= 8, "Missing/invalid MSC category count")
    require(bool(metadata.get("sources")), "Sources are required")
    for source in metadata["sources"]:
        require(bool(source.get("title")), "Source title missing")
        require(source["relationship"] in ["formalizes", "adapts", "independently-proves", "background", "other"],
                "Unsupported source relationship")
    require(metadata["status"]["sorry_count"] == 0 and metadata["status"]["sorry_in_definitions"] == 0,
            "Proof status metadata must agree with sources")
    require(set(metadata["status"]["axioms"]) <= ALLOWED_AXIOMS, "Metadata axioms mismatch")
    require(bool(metadata["automation"]["methods"]) and bool(metadata["review"]["status"]),
            "Missing automation/review disclosure")
    for file in ["verify.yml", "palomar-preflight.yml"]:
        data = yaml.load(text(root / ".github/workflows" / file), Loader=yaml.BaseLoader)
        require("workflow_dispatch" in data["on"], "Expected manual workflow")
        require(data["permissions"]["contents"] == "read", "CI permissions should be read-only")
    preflight = yaml.load(text(root / ".github/workflows/palomar-preflight.yml"), Loader=yaml.BaseLoader)
    job = preflight["jobs"]["palomar-preflight"]
    require(job["uses"].endswith("@" + PIPELINE_SHA), "Unexpected pipeline workflow revision")
    require(job["with"]["pipeline_commit"] == PIPELINE_SHA, "Workflow and pipeline_commit differ")
    require(job["with"]["mode"] == "full" and job["with"]["execution_profile"] == "palomar-standard-v1",
            "Preflight must use full mode and the supported caller profile")
    require(re.fullmatch(r"[a-z0-9]{12}", job["with"]["request_id"]) is not None, "Invalid request_id")
    options = json.loads(job["with"]["options"])
    require(options["comparator_config_path"] == "comparator.json", "Unexpected Comparator path")
    require(bool(options["authorization_relationship"]), "Authorization relationship missing")
    forbidden = {".olean", ".ilean", ".a", ".bc", ".dll", ".dylib", ".o", ".obj", ".so", ".trace"}
    for path in all_files:
        require(path.suffix not in forbidden, "Compiled artifact outside cache")
        require(not path.read_bytes().startswith(b"version https://git-lfs.github.com/spec/v1"), "Git LFS pointer")
        if path.suffix.lower() in {".md", ".json", ".yaml", ".yml", ".lean", ".toml", ".ps1", ".py", ".sh", ".txt", ".log"}:
            require(re.search(rb"github_pat_[A-Za-z0-9_]{20,}|ghp_[A-Za-z0-9]{30,}", path.read_bytes()) is None,
                    "Credential pattern in a repository text artifact")
    require(not (root / ".gitmodules").exists(), "Submodules are outside this prepared layout")
    total = sum(path.stat().st_size for path in all_files)
    require(total <= 500 * 1024 * 1024, "Repository exceeds 500 MiB")
    hashes = 0
    if check_hashes:
        for line in text(root / "SHA256SUMS.txt").splitlines():
            expected, relative = line.split("  ", 1)
            path = (root / relative).resolve()
            require(path.is_relative_to(root), "Unsafe manifest path")
            require(sha256(path) == expected, "SHA256 mismatch: " + relative)
            hashes += 1
    return {"status": "passed", "scope": "Local preliminary structure/metadata/source checks; not official Palomar verification",
            "files": len(all_files), "bytes": total, "Lean_sources": source_info,
            "admissions": [], "selected_finite_results": selected, "pinned_git_dependencies": len(manifest["packages"]),
            "toolchain": toolchain, "license": "MIT", "verified_file_hashes": hashes,
            "challenge_direct_imports": direct_imports,
            "official_transitive_closure_check": "pending official full preflight",
            "Palomar_full_preflight": "configured, not run", "Palomar_registration": "not submitted"}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--check-hashes", action="store_true")
    args = parser.parse_args()
    try:
        print(json.dumps(inspect(args.root, args.check_hashes), ensure_ascii=False, indent=2))
    except (ValueError, KeyError, StopIteration, OSError, yaml.YAMLError) as error:
        print(json.dumps({"status": "failed", "error": str(error)}, ensure_ascii=False), file=sys.stderr)
        raise SystemExit(1)

if __name__ == "__main__":
    main()
