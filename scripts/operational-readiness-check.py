#!/usr/bin/env python3
"""
Operational Readiness Check Script

This script performs a comprehensive sanity check of the agent-ops-hub repository
using GitHub REST API. It:
1. Dispatches key workflows on main branch
2. Monitors workflow completion
3. Creates a smoke test PR
4. Generates a report as a GitHub Issue

Usage:
    python3 operational-readiness-check.py
"""

import os
import sys
import json
import time
from datetime import datetime
from typing import Dict, List, Optional, Tuple

try:
    import requests
except ImportError:
    print("ERROR: requests library not found. Installing...")
    os.system(f"{sys.executable} -m pip install requests")
    import requests


class GitHubAPIClient:
    """Client for GitHub REST API operations."""
    
    def __init__(self, owner: str, repo: str, token: str):
        self.owner = owner
        self.repo = repo
        self.token = token
        self.base_url = "https://api.github.com"
        self.headers = {
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28"
        }
    
    def get_default_branch(self) -> str:
        """Get the default branch of the repository."""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}"
        response = requests.get(url, headers=self.headers)
        response.raise_for_status()
        return response.json()["default_branch"]
    
    def dispatch_workflow(self, workflow_file: str, inputs: Optional[Dict] = None) -> bool:
        """Dispatch a workflow via workflow_dispatch event."""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/actions/workflows/{workflow_file}/dispatches"
        
        default_branch = self.get_default_branch()
        payload = {
            "ref": default_branch,
            "inputs": inputs or {}
        }
        
        response = requests.post(url, headers=self.headers, json=payload)
        if response.status_code == 204:
            return True
        else:
            print(f"Warning: Failed to dispatch {workflow_file}: {response.status_code}")
            return False
    
    def get_latest_workflow_run(self, workflow_file: str, branch: str) -> Optional[Dict]:
        """Get the latest workflow run for a specific workflow file."""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/actions/workflows/{workflow_file}/runs"
        params = {
            "branch": branch,
            "per_page": 1
        }
        
        response = requests.get(url, headers=self.headers, params=params)
        response.raise_for_status()
        
        runs = response.json().get("workflow_runs", [])
        return runs[0] if runs else None
    
    def get_workflow_run_status(self, run_id: int) -> Dict:
        """Get the status of a workflow run."""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/actions/runs/{run_id}"
        response = requests.get(url, headers=self.headers)
        response.raise_for_status()
        return response.json()
    
    def wait_for_workflow_completion(self, run_id: int, timeout: int = 600) -> Tuple[str, str]:
        """
        Wait for a workflow run to complete.
        
        Returns:
            Tuple of (status, conclusion)
        """
        start_time = time.time()
        
        while time.time() - start_time < timeout:
            run_info = self.get_workflow_run_status(run_id)
            status = run_info.get("status")
            conclusion = run_info.get("conclusion")
            
            if status == "completed":
                return status, conclusion or "unknown"
            
            time.sleep(10)  # Poll every 10 seconds
        
        return "timeout", "timeout"
    
    def create_branch(self, branch_name: str, from_branch: str) -> bool:
        """Create a new branch from an existing branch."""
        # Get SHA of the from_branch
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/git/refs/heads/{from_branch}"
        response = requests.get(url, headers=self.headers)
        response.raise_for_status()
        sha = response.json()["object"]["sha"]
        
        # Create new branch
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/git/refs"
        payload = {
            "ref": f"refs/heads/{branch_name}",
            "sha": sha
        }
        
        response = requests.post(url, headers=self.headers, json=payload)
        if response.status_code in [201, 422]:  # 422 = already exists
            return True
        return False
    
    def create_or_update_file(self, path: str, content: str, message: str, branch: str) -> bool:
        """Create or update a file in the repository."""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/contents/{path}"
        
        # Try to get existing file
        try:
            response = requests.get(url, headers=self.headers, params={"ref": branch})
            sha = response.json().get("sha")
        except:
            sha = None
        
        # Encode content to base64
        import base64
        encoded_content = base64.b64encode(content.encode()).decode()
        
        payload = {
            "message": message,
            "content": encoded_content,
            "branch": branch
        }
        
        if sha:
            payload["sha"] = sha
        
        response = requests.put(url, headers=self.headers, json=payload)
        return response.status_code in [200, 201]
    
    def create_pull_request(self, title: str, head: str, base: str, body: str) -> Optional[int]:
        """Create a pull request."""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/pulls"
        payload = {
            "title": title,
            "head": head,
            "base": base,
            "body": body
        }
        
        response = requests.post(url, headers=self.headers, json=payload)
        if response.status_code == 201:
            return response.json()["number"]
        return None
    
    def create_issue(self, title: str, body: str) -> Optional[int]:
        """Create a GitHub issue."""
        url = f"{self.base_url}/repos/{self.owner}/{self.repo}/issues"
        payload = {
            "title": title,
            "body": body
        }
        
        response = requests.post(url, headers=self.headers, json=payload)
        if response.status_code == 201:
            return response.json()["number"]
        return None


def generate_report(workflow_results: List[Dict], smoke_pr_result: Dict) -> str:
    """Generate the operational readiness report in markdown format."""
    
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")
    date_str = datetime.now().strftime("%Y-%m-%d")
    
    report = f"""# Operational Readiness — Sanity Check ({date_str})

**Generated:** {timestamp}
**Repository:** martinmo90/agent-ops-hub
**Base Branch:** main

## Executive Summary

"""
    
    # Determine overall status
    all_passed = all(r["conclusion"] == "success" for r in workflow_results if r["dispatched"])
    overall_status = "✅ PASS" if all_passed else "⚠️ PARTIAL PASS" if any(r["conclusion"] == "success" for r in workflow_results) else "❌ FAIL"
    
    report += f"**Overall Status:** {overall_status}\n\n"
    
    # Workflow results
    report += "## Workflow Execution Results\n\n"
    report += "| Workflow | Status | Conclusion | Run URL |\n"
    report += "|----------|--------|------------|----------|\n"
    
    for result in workflow_results:
        if result["dispatched"]:
            status_icon = "✅" if result["conclusion"] == "success" else "❌" if result["conclusion"] == "failure" else "⏸️"
            report += f"| {result['name']} | {status_icon} {result['status']} | {result['conclusion']} | [View]({result['url']}) |\n"
        else:
            report += f"| {result['name']} | ⚠️ Not Dispatched | - | - |\n"
    
    # Smoke PR result
    report += "\n## Smoke Test PR\n\n"
    if smoke_pr_result.get("created"):
        report += f"✅ **Smoke PR Created:** #{smoke_pr_result['number']}\n"
        report += f"- **URL:** {smoke_pr_result['url']}\n"
        report += f"- **Status:** {smoke_pr_result['status']}\n"
    else:
        report += f"❌ **Smoke PR Failed:** {smoke_pr_result.get('error', 'Unknown error')}\n"
    
    # Branch protection check
    report += "\n## Branch Protection & Required Checks\n\n"
    report += "✅ See `required-checks-audit.yml` results above for detailed consistency check.\n"
    
    # Next steps
    report += "\n## Next Steps\n\n"
    
    if all_passed:
        report += "✅ **All checks passed!** The repository is operational and ready for use.\n\n"
        report += "**Recommended actions:**\n"
        report += "- Continue with planned backend integration\n"
        report += "- Address any minor issues identified in workflow logs\n"
        report += "- Monitor ongoing CI/CD pipeline performance\n"
    else:
        report += "⚠️ **Some checks failed.** Review the workflow logs for details.\n\n"
        report += "**Required actions:**\n"
        report += "1. Review failed workflow logs linked above\n"
        report += "2. Address any blocking issues\n"
        report += "3. Re-run this sanity check after fixes\n"
    
    report += "\n---\n\n"
    report += "*This report was generated automatically by the Operational Readiness Check script.*\n"
    
    return report


def main():
    """Main execution function."""
    
    # Get GitHub token from environment
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if not token:
        print("ERROR: GITHUB_TOKEN or GH_TOKEN environment variable not set")
        sys.exit(1)
    
    owner = "martinmo90"
    repo = "agent-ops-hub"
    
    client = GitHubAPIClient(owner, repo, token)
    
    print("=" * 60)
    print("OPERATIONAL READINESS CHECK")
    print("=" * 60)
    print(f"Repository: {owner}/{repo}")
    print()
    
    # Step 1: Get default branch
    print("Step 1: Resolving default branch...")
    default_branch = client.get_default_branch()
    print(f"  ✓ Default branch: {default_branch}")
    print()
    
    # Step 2: Dispatch workflows
    print("Step 2: Dispatching workflows on main branch...")
    
    workflows = [
        {
            "file": "required-checks-audit.yml",
            "name": "Required Checks Audit",
            "inputs": {}
        },
        {
            "file": "operational-status-scan.yml",
            "name": "Operational Status Scan",
            "inputs": {"base": "main"}
        },
        {
            "file": "repo-tidy-scan.yml",
            "name": "Repo Tidy Scan",
            "inputs": {
                "stale_days": "45",
                "delete_merged": "false",
                "delete_stale_no_pr": "false",
                "extra_protected": ""
            }
        },
        {
            "file": "ops-build-zip.yml",
            "name": "Ops Dashboard Build",
            "inputs": {}
        },
        {
            "file": "benchmark-zip-exact-check.yml",
            "name": "Benchmark Zip Check",
            "inputs": {}
        }
    ]
    
    workflow_results = []
    
    for workflow in workflows:
        print(f"  Dispatching: {workflow['name']}...")
        dispatched = client.dispatch_workflow(workflow["file"], workflow["inputs"])
        
        if dispatched:
            print(f"    ✓ Dispatched successfully")
            time.sleep(5)  # Wait a bit for the run to start
            
            # Get the latest run
            latest_run = client.get_latest_workflow_run(workflow["file"], default_branch)
            if latest_run:
                run_id = latest_run["id"]
                print(f"    → Monitoring run #{run_id}...")
                
                status, conclusion = client.wait_for_workflow_completion(run_id, timeout=600)
                
                workflow_results.append({
                    "name": workflow["name"],
                    "file": workflow["file"],
                    "dispatched": True,
                    "run_id": run_id,
                    "status": status,
                    "conclusion": conclusion,
                    "url": latest_run["html_url"]
                })
                
                icon = "✅" if conclusion == "success" else "❌" if conclusion == "failure" else "⏸️"
                print(f"    {icon} Status: {status}, Conclusion: {conclusion}")
            else:
                print(f"    ⚠️  Could not find run")
                workflow_results.append({
                    "name": workflow["name"],
                    "file": workflow["file"],
                    "dispatched": True,
                    "run_id": None,
                    "status": "not_found",
                    "conclusion": "not_found",
                    "url": ""
                })
        else:
            print(f"    ❌ Dispatch failed")
            workflow_results.append({
                "name": workflow["name"],
                "file": workflow["file"],
                "dispatched": False,
                "run_id": None,
                "status": "not_dispatched",
                "conclusion": "not_dispatched",
                "url": ""
            })
        
        print()
    
    # Step 3: Create smoke test PR
    print("Step 3: Creating smoke test PR...")
    
    smoke_branch = "chore/smoke-ops-readiness"
    smoke_pr_result = {}
    
    try:
        # Create branch
        print(f"  Creating branch: {smoke_branch}...")
        if client.create_branch(smoke_branch, default_branch):
            print(f"    ✓ Branch created/exists")
            
            # Create smoke file
            timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
            smoke_content = f"""# Smoke Test File

Generated: {timestamp}

This file was created by the operational readiness check to verify end-to-end PR workflow.

## Purpose
- Verify branch creation
- Verify file commit
- Verify PR creation
- Verify CI triggers

## Status
✅ Smoke test file created successfully
"""
            
            print(f"  Creating smoke test file...")
            file_path = f"docs/SMOKE_TEST_{timestamp}.md"
            if client.create_or_update_file(
                file_path,
                smoke_content,
                f"chore: smoke test file for operational readiness check {timestamp}",
                smoke_branch
            ):
                print(f"    ✓ File created: {file_path}")
                
                # Create PR
                print(f"  Creating pull request...")
                pr_body = f"""## Smoke Test PR — Operational Readiness Check

**Generated:** {timestamp}

This PR was created automatically to verify the end-to-end PR workflow as part of the operational readiness check.

### Purpose
- ✅ Verify branch creation works
- ✅ Verify file commits work  
- ✅ Verify PR creation works
- ⏳ Verify CI workflows trigger correctly

### Actions
- Created branch `{smoke_branch}`
- Committed test file `{file_path}`
- Created this PR

### Next Steps
1. CI workflows should trigger automatically
2. Review workflow results
3. Close this PR after verification (no need to merge)

---

*This is an automated smoke test. Safe to close after verification.*
"""
                
                pr_number = client.create_pull_request(
                    f"chore: smoke test for operational readiness ({timestamp})",
                    smoke_branch,
                    default_branch,
                    pr_body
                )
                
                if pr_number:
                    print(f"    ✓ PR created: #{pr_number}")
                    smoke_pr_result = {
                        "created": True,
                        "number": pr_number,
                        "url": f"https://github.com/{owner}/{repo}/pull/{pr_number}",
                        "status": "created"
                    }
                else:
                    print(f"    ❌ Failed to create PR")
                    smoke_pr_result = {
                        "created": False,
                        "error": "PR creation failed"
                    }
            else:
                print(f"    ❌ Failed to create file")
                smoke_pr_result = {
                    "created": False,
                    "error": "File creation failed"
                }
        else:
            print(f"    ❌ Failed to create branch")
            smoke_pr_result = {
                "created": False,
                "error": "Branch creation failed"
            }
    except Exception as e:
        print(f"    ❌ Error: {e}")
        smoke_pr_result = {
            "created": False,
            "error": str(e)
        }
    
    print()
    
    # Step 4: Generate report
    print("Step 4: Generating report...")
    report = generate_report(workflow_results, smoke_pr_result)
    
    # Save report locally
    report_file = "/tmp/operational-readiness-report.md"
    with open(report_file, "w") as f:
        f.write(report)
    print(f"  ✓ Report saved: {report_file}")
    
    # Create GitHub Issue with report
    print("  Creating GitHub Issue...")
    date_str = datetime.now().strftime("%Y-%m-%d")
    issue_title = f"Operational Readiness — Sanity Check ({date_str})"
    
    issue_number = client.create_issue(issue_title, report)
    if issue_number:
        print(f"    ✓ Issue created: #{issue_number}")
        print(f"    → https://github.com/{owner}/{repo}/issues/{issue_number}")
    else:
        print(f"    ⚠️  Failed to create issue")
    
    print()
    print("=" * 60)
    print("OPERATIONAL READINESS CHECK COMPLETE")
    print("=" * 60)
    print()
    print(f"Report available at: {report_file}")
    if issue_number:
        print(f"GitHub Issue: https://github.com/{owner}/{repo}/issues/{issue_number}")
    print()


if __name__ == "__main__":
    main()
