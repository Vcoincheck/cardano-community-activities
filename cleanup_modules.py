#!/usr/bin/env python3
import os
import glob

# Remove old module files from root of modules directory
old_files = [
    "challenge_generator.py",
    "community_manager.py", 
    "excel_exporter.py",
    "key_generator.py",
    "message_signer.py",
    "onchain_verifier.py"
]

modules_path = "/workspaces/cardano-community-activities/python/app/modules"

for file in old_files:
    file_path = os.path.join(modules_path, file)
    if os.path.exists(file_path):
        os.remove(file_path)
        print(f"Deleted: {file_path}")
    else:
        print(f"Not found: {file_path}")

print("\nRemaining .py files in modules:")
for root, dirs, files in os.walk(modules_path):
    for file in sorted(files):
        if file.endswith('.py'):
            full_path = os.path.join(root, file)
            rel_path = os.path.relpath(full_path, modules_path)
            print(f"  {rel_path}")
