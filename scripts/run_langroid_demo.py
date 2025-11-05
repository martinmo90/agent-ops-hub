#!/usr/bin/env python3
"""
Langroid demo wrapper - generates timestamped artifact file.
No external API calls required.
"""
import os
from datetime import datetime, timezone
from pathlib import Path

def main():
    # Create artifacts directory if it doesn't exist
    artifacts_dir = Path(__file__).parent.parent / "artifacts"
    artifacts_dir.mkdir(exist_ok=True)
    
    # Generate output file with timestamp
    output_file = artifacts_dir / "os-agent-demo-langroid.txt"
    timestamp = datetime.now(timezone.utc).isoformat()
    
    content = f"""Langroid Demo
Generated: {timestamp}
Status: OK - Wrapper executed successfully
"""
    
    output_file.write_text(content)
    print(f"✓ Langroid demo artifact written to: {output_file}")
    return 0

if __name__ == "__main__":
    exit(main())
