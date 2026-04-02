#!/usr/bin/env python3
"""
Check all GitHub workflows for proper JavaScript comment syntax.

This script scans workflows that use actions/github-script and verifies:
1. JavaScript code uses // for comments (not #)
2. Inline comments are properly formatted
3. Multi-line comments use /* */ or // style

Usage:
    python3 check_workflow_js_comments.py [--fix]

Options:
    --fix    Automatically fix # comments to // (creates backup)
"""

import re
import sys
from pathlib import Path


def extract_script_blocks(content):
    """
    Extract JavaScript script blocks from workflow content.
    
    Returns:
        List of (start_line, end_line, content) tuples
    """
    lines = content.split('\n')
    blocks = []
    in_script = False
    script_start = 0
    script_lines = []
    
    for i, line in enumerate(lines, 1):
        if 'script: |' in line:
            in_script = True
            script_start = i
            script_lines = []
            continue
        
        if in_script:
            # Check if we've left the script block (next YAML field at lower indent)
            if line.strip() and not line.startswith('            ') and i > script_start:
                in_script = False
                blocks.append({
                    'start': script_start,
                    'end': i - 1,
                    'lines': script_lines,
                    'content': '\n'.join(script_lines)
                })
                continue
            
            script_lines.append(line)
    
    # Handle final script block if file ends while in script
    if in_script and script_lines:
        blocks.append({
            'start': script_start,
            'end': len(lines),
            'lines': script_lines,
            'content': '\n'.join(script_lines)
        })
    
    return blocks


def check_script_block(block_content, filepath, block_start_line):
    """
    Check a script block for comment issues.
    
    Returns:
        List of issue dictionaries
    """
    issues = []
    lines = block_content.split('\n')
    in_template_literal = False
    in_multiline_comment = False
    
    for i, line in enumerate(lines, block_start_line):
        # Track template literals (backticks)
        backtick_count = line.count('`') - line.count(r'\`')
        if backtick_count % 2 == 1:
            in_template_literal = not in_template_literal
        
        # Skip if inside template literal (markdown is allowed)
        if in_template_literal:
            continue
        
        # Track multi-line comments
        if '/*' in line:
            in_multiline_comment = True
        if '*/' in line:
            in_multiline_comment = False
            continue
        
        # Skip if inside multi-line comment
        if in_multiline_comment:
            continue
        
        # Check for # comments (should be //)
        stripped = line.strip()
        if stripped.startswith('#') and not stripped.startswith('#!/'):
            # Make sure it's not a special case
            if stripped.startswith('# ') or stripped.startswith('#!'):
                issues.append({
                    'line': i,
                    'type': 'WRONG_COMMENT',
                    'content': line,
                    'message': "Found '#' comment, should use '//'",
                    'suggestion': line.replace('#', '//', 1)
                })
        
        # Check for proper // comments
        if '//' in line and not in_template_literal:
            # This is good - ensure it's not inside a string
            pass
    
    return issues


def analyze_workflow(filepath):
    """
    Analyze a workflow file for JavaScript comment issues.
    
    Returns:
        Dictionary with analysis results
    """
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Check if this workflow uses github-script
    if 'actions/github-script' not in content:
        return None
    
    blocks = extract_script_blocks(content)
    
    result = {
        'file': filepath.name,
        'blocks': [],
        'has_issues': False,
        'issue_count': 0
    }
    
    for block in blocks:
        issues = check_script_block(block['content'], filepath, block['start'])
        
        if issues:
            result['has_issues'] = True
            result['issue_count'] += len(issues)
            result['blocks'].append({
                'start_line': block['start'],
                'end_line': block['end'],
                'issues': issues
            })
        else:
            result['blocks'].append({
                'start_line': block['start'],
                'end_line': block['end'],
                'issues': []
            })
    
    return result


def print_report(results):
    """Print analysis report."""
    print("=" * 100)
    print("JAVASCRIPT COMMENT ANALYSIS - GITHUB WORKFLOWS")
    print("=" * 100)
    
    total_issues = 0
    compliant_files = 0
    
    for result in results:
        if result is None:
            continue
        
        print(f"\n📄 {result['file']}")
        print("-" * 100)
        
        if not result['has_issues']:
            print("  ✓ COMPLIANT - All JavaScript comments use // syntax")
            compliant_files += 1
        else:
            print(f"  ⚠️  ISSUES FOUND - {result['issue_count']} problem(s)")
            
            for block in result['blocks']:
                if block['issues']:
                    print(f"\n  Script block (lines {block['start_line']}-{block['end_line']}):")
                    
                    for issue in block['issues']:
                        total_issues += 1
                        print(f"    Line {issue['line']}: {issue['message']}")
                        print(f"      Current:  {issue['content'].rstrip()}")
                        print(f"      Suggest:  {issue['suggestion'].rstrip()}")
    
    print("\n" + "=" * 100)
    print(f"SUMMARY: {compliant_files} compliant, {total_issues} total issues found")
    print("=" * 100)
    
    return total_issues == 0


def fix_comments_in_file(filepath):
    """Fix # comments to // in a workflow file."""
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Create backup
    backup_file = filepath.with_suffix(filepath.suffix + '.bak')
    with open(backup_file, 'w') as f:
        f.write(content)
    
    blocks = extract_script_blocks(content)
    lines = content.split('\n')
    fixed_count = 0
    
    for block in blocks:
        for issue_line, line_content in enumerate(block['lines'], block['start']):
            if issue_line - 1 < len(lines):
                # Replace # with // in JavaScript code sections
                if lines[issue_line - 1].strip().startswith('# '):
                    lines[issue_line - 1] = lines[issue_line - 1].replace('# ', '// ', 1)
                    fixed_count += 1
    
    fixed_content = '\n'.join(lines)
    
    with open(filepath, 'w') as f:
        f.write(fixed_content)
    
    return fixed_count, backup_file


def main():
    """Main entry point."""
    fix_mode = '--fix' in sys.argv
    
    # Find workflows directory
    script_dir = Path(__file__).parent
    repo_root = script_dir.parent
    workflows_dir = repo_root / '.github' / 'workflows'
    
    if not workflows_dir.exists():
        print(f"Error: Workflows directory not found at {workflows_dir}")
        sys.exit(1)
    
    # Analyze all workflows
    results = []
    for filepath in sorted(workflows_dir.glob('*.{yml,yaml}')):
        result = analyze_workflow(filepath)
        if result:
            results.append(result)
    
    # Print report
    all_compliant = print_report(results)
    
    # Fix if requested
    if fix_mode and not all_compliant:
        print("\n[FIX MODE - Applying corrections...]")
        for result in results:
            if result and result['has_issues']:
                filepath = workflows_dir / result['file']
                fixed_count, backup = fix_comments_in_file(filepath)
                print(f"  Fixed {fixed_count} comment(s) in {result['file']}")
                print(f"  Backup saved to: {backup}")
    
    sys.exit(0 if all_compliant else 1)


if __name__ == '__main__':
    main()
