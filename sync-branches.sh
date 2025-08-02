#!/bin/bash

# sync-branches.sh - 同步master分支到main分支

echo "Starting branch synchronization..."

# 确保在master分支
if [ "$(git rev-parse --abbrev-ref HEAD)" != "master" ]; then
    echo "Error: Please run this script from master branch"
    exit 1
fi

# 获取最新更改
git pull origin master

# 切换到main分支
git checkout main

# 合并master分支
git merge master

# 推送到远程main分支
git push origin main

# 切换回master分支
git checkout master

echo "Branch synchronization completed successfully!"
echo "Master branch has been synced to main branch."