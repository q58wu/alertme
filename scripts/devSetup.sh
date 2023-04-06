#!/bin/bash

echo "▶ Running dev setup.."

echo "▶ Copying pre-commit hook..."
pre_commit_hook_file="$(pwd)/.git/hooks/pre-commit"
pre_commit_script="$(pwd)/scripts/pre-commit"
if [ -f "$pre_commit_hook_file" ]; then
    cp "$pre_commit_hook_file" "$pre_commit_hook_file.backup"
fi
cp "$pre_commit_script" "$pre_commit_hook_file"
chmod +x "$pre_commit_hook_file"
echo "✅ Pre-commit hook completed"

echo "▶ Copying pre-push hook..."
pre_push_hook_file="$(pwd)/.git/hooks/pre-push"
pre_push_script="$(pwd)/scripts/pre-push"
if [ -f "$pre_push_hook_file" ]; then
    cp "$pre_push_hook_file" "$pre_push_hook_file.backup"
fi
cp "$pre_push_script" "$pre_push_hook_file"
chmod +x "$pre_push_hook_file"
echo "✅ Pre-push hook completed"

echo "✅ Setup complete!"
