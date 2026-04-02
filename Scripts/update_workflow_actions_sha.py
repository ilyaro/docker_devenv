#!/usr/bin/env python3
"""
Update GitHub Actions in workflows to use real SHA1 commit hashes instead of version tags.

This script:
1. Scans all workflow files (.yml, .yaml) in .github/workflows/
2. Extracts action references (uses: owner/repo@version)
3. Fetches the real commit SHA for each version tag from GitHub API
4. Replaces version tags with real SHAs while preserving the version as a comment
5. Validates that SHAs are correct by checking against GitHub API

Usage:
    python3 update_workflow_actions_sha.py [--validate]

Options:
    --validate    Only validate existing SHAs without making changes
"""

import os
import re
import subprocess
import sys
import json
from pathlib import Path


def get_real_sha(action: str, version: str) -> str:
    """
    Fetch the real commit SHA for a GitHub action version.
    
    Args:
        action: GitHub action in format 'owner/repo'
        version: Version tag (e.g., 'v6', 'v3.0.1')
    
    Returns:
        Commit SHA (40 hex chars) or original version if already a SHA
    """
    # Skip if already a SHA (40 hex characters)
    if re.match(r'^[0-9a-f]{40}$', version):
        return version
    
    owner, repo = action.split('/')
    url = f"https://api.github.com/repos/{owner}/{repo}/commits/{version}"
    
    try:
        result = subprocess.run(
            ['curl', '-s', url, '-H', 'Accept: application/vnd.github.v3+json'],
            capture_output=True,
            text=True,
            timeout=10
        )
        data = json.loads(result.stdout)
        
        if 'sha' in data:
            sha = data['sha']
            print(f"✓ {action}@{version} -> {sha}", file=sys.stderr)
            return sha
        else:
            print(f"✗ Failed to fetch {action}@{version}: {data.get('message', 'Unknown error')}", file=sys.stderr)
            return version
    except Exception as e:
        print(f"✗ Error fetching {action}@{version}: {e}", file=sys.stderr)
        return version


def validate_sha(action: str, sha: str, expected_version: str) -> bool:
    """
    Validate that a SHA actually exists and points to the expected version tag.
    
    Args:
        action: GitHub action in format 'owner/repo'
        sha: Commit SHA to validate
        expected_version: Version tag that should point to this SHA
    
    Returns:
        True if SHA is valid and matches the tag, False otherwise
    """
    owner, repo = action.split('/')
    
    # Check if tag points to this SHA
    tag_url = f"https://api.github.com/repos/{owner}/{repo}/git/refs/tags/{expected_version}"
    
    try:
        result = subprocess.run(
            ['curl', '-s', tag_url, '-H', 'Accept: application/vnd.github.v3+json'],
            capture_output=True,
            text=True,
            timeout=10
        )
        tag_data = json.loads(result.stdout)
        
        if 'object' in tag_data:
            object_sha = tag_data['object']['sha']
            object_type = tag_data['object']['type']
            
            # If it's an annotated tag, get the commit SHA
            if object_type == 'tag':
                tag_obj_url = f"https://api.github.com/repos/{owner}/{repo}/git/tags/{object_sha}"
                tag_obj_result = subprocess.run(
                    ['curl', '-s', tag_obj_url, '-H', 'Accept: application/vnd.github.v3+json'],
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                tag_obj_data = json.loads(tag_obj_result.stdout)
                if 'object' in tag_obj_data:
                    commit_sha = tag_obj_data['object']['sha']
                    return commit_sha == sha
            else:
                return object_sha == sha
        
        return False
    except Exception as e:
        print(f"✗ Validation error for {action}@{expected_version}: {e}", file=sys.stderr)
        return False


def update_workflow(filepath: str, validate_only: bool = False) -> bool:
    """
    Update a workflow file to use real SHA1 hashes for all actions.
    
    Args:
        filepath: Path to workflow YAML file
        validate_only: If True, only validate without making changes
    
    Returns:
        True if file was updated, False if no changes
    """
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Find all uses statements: uses: owner/repo@version [# comment]
    # Matches versions like: v1, v1.2.3, 0.34.0, commit-sha (40 hex chars)
    pattern = r'uses:\s+([a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+)@([a-zA-Z0-9._-]+)(.*?)$'
    
    def replace_func(match):
        action = match.group(1)
        version = match.group(2)
        rest = match.group(3)
        
        real_sha = get_real_sha(action, version)
        
        if version != real_sha:
            # Preserve comment if exists, otherwise create one
            if not rest or '#' not in rest:
                rest = f' # {version}'
            
            line = f'uses: {action}@{real_sha}{rest}'
            
            if not validate_only:
                return line
            else:
                # Just validate
                is_valid = validate_sha(action, real_sha, version)
                if is_valid:
                    print(f"✓ VALID | {action}@{version}", file=sys.stderr)
                else:
                    print(f"✗ INVALID | {action}@{version}", file=sys.stderr)
                return match.group(0)
        
        return match.group(0)
    
    content = re.sub(pattern, replace_func, content, flags=re.MULTILINE)
    
    if content != original_content and not validate_only:
        with open(filepath, 'w') as f:
            f.write(content)
        return True
    
    return False


def main():
    """Main entry point."""
    validate_only = '--validate' in sys.argv
    
    # Find workflows directory relative to script location
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    workflows_dir = repo_root / '.github' / 'workflows'
    
    if not workflows_dir.exists():
        print(f"Error: Workflows directory not found at {workflows_dir}")
        sys.exit(1)
    
    print("=" * 80)
    print("UPDATE GITHUB ACTION SHAs")
    print("=" * 80)
    
    if validate_only:
        print("\n[VALIDATE MODE - No changes will be made]\n")
    else:
        print("\n[UPDATE MODE - Files will be modified]\n")
    
    updated_count = 0
    problematic_actions = []
    
    for filename in sorted(workflows_dir.glob('*')) :
        if filename.suffix not in ['.yml', '.yaml']:
            continue
        print(f"\nProcessing: {filename.name}")
        
        if update_workflow(str(filename), validate_only=validate_only):
            print(f"✓ Updated: {filename.name}")
            updated_count += 1
        else:
            status = "No changes" if validate_only else "Already up to date"
            print(f"- {status}: {filename.name}")
        
        # Check for non-SHA actions
        with open(filename, 'r') as f:
            content = f.read()
        
        pattern = r'uses:\s+([a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+)@([a-zA-Z0-9._-]+)(.*?)$'
        for match in re.finditer(pattern, content, flags=re.MULTILINE):
            version = match.group(2)
            is_sha = re.match(r'^[0-9a-f]{40}$', version)
            
            if not is_sha:
                action = match.group(1)
                problematic_actions.append((filename.name, action, version))
    
    print("\n" + "=" * 80)
    if problematic_actions:
        print("\n⚠ ACTIONS NOT USING SHA1 HASHES:")
        for workflow, action, version in problematic_actions:
            print(f"  {workflow}: {action}@{version}")
        print()
    
    if validate_only:
        print("Validation complete!")
    else:
        print(f"Updated {updated_count} workflow file(s)")
    print("=" * 80)


if __name__ == '__main__':
    main()
