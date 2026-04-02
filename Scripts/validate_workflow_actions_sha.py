#!/usr/bin/env python3
"""
Validate that all GitHub Actions in workflows use real SHA1 commit hashes.

This script:
1. Scans all workflow files (.yml, .yaml) in .github/workflows/
2. Extracts action references with SHA values
3. Validates each SHA against GitHub API to ensure it's correct
4. Reports any mismatches or invalid SHAs

Usage:
    python3 validate_workflow_actions_sha.py
"""

import os
import re
import subprocess
import sys
import json
from pathlib import Path


def validate_sha(action: str, sha: str, expected_version: str) -> tuple:
    """
    Validate that a SHA is real and points to the expected version tag.
    
    Args:
        action: GitHub action in format 'owner/repo'
        sha: Commit SHA to validate
        expected_version: Version tag that should point to this SHA
    
    Returns:
        Tuple of (is_valid, actual_sha, commit_message)
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
        
        if 'object' not in tag_data:
            return False, None, f"Tag not found: {tag_data.get('message', 'Unknown error')}"
        
        object_sha = tag_data['object']['sha']
        object_type = tag_data['object']['type']
        
        actual_sha = object_sha
        
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
                actual_sha = tag_obj_data['object']['sha']
        
        # Get commit message
        commit_url = f"https://api.github.com/repos/{owner}/{repo}/commits/{actual_sha}"
        commit_result = subprocess.run(
            ['curl', '-s', commit_url, '-H', 'Accept: application/vnd.github.v3+json'],
            capture_output=True,
            text=True,
            timeout=10
        )
        commit_data = json.loads(commit_result.stdout)
        commit_message = commit_data.get('commit', {}).get('message', '').split('\n')[0][:60]
        
        is_valid = actual_sha == sha
        return is_valid, actual_sha, commit_message
        
    except Exception as e:
        return False, None, str(e)


def main():
    """Main entry point."""
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    workflows_dir = repo_root / '.github' / 'workflows'
    
    if not workflows_dir.exists():
        print(f"Error: Workflows directory not found at {workflows_dir}")
        sys.exit(1)
    
    print("=" * 100)
    print("VALIDATING GITHUB ACTION SHA1 HASHES")
    print("=" * 100)
    
    actions_checked = set()
    valid_count = 0
    invalid_count = 0
    
    for filepath in sorted(workflows_dir.glob('*.{yml,yaml}')):
        with open(filepath, 'r') as f:
            content = f.read()
        
        # Find all uses statements with SHAs
        pattern = r'uses:\s+([a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+)@([a-f0-9]{40})\s*#\s*(.+?)$'
        matches = re.finditer(pattern, content, re.MULTILINE)
        
        for match in matches:
            action = match.group(1)
            sha = match.group(2)
            version = match.group(3).strip()
            
            key = f"{action}@{version}"
            if key not in actions_checked:
                actions_checked.add(key)
                
                is_valid, actual_sha, commit_message = validate_sha(action, sha, version)
                
                status = "✓ VALID" if is_valid else "✗ INVALID"
                print(f"\n{status} | {action}@{version}")
                print(f"  SHA: {sha}")
                if not is_valid:
                    print(f"  Expected: {actual_sha}")
                    invalid_count += 1
                else:
                    valid_count += 1
                print(f"  Commit: {commit_message}")
    
    print("\n" + "=" * 100)
    print(f"Results: {valid_count} valid, {invalid_count} invalid")
    print("=" * 100)
    
    if invalid_count > 0:
        print("\n⚠ Some actions have invalid SHAs. Run update_workflow_actions_sha.py to fix them.")
        sys.exit(1)
    else:
        print("\n✓ All actions are using valid SHA1 commit hashes!")
        sys.exit(0)


if __name__ == '__main__':
    main()
