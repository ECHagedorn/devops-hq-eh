#!/bin/bash

curl -X POST   -H "Content-Type: application/json"  -d '{
  "ref": "refs/heads/remediation-1",
  "before": "a241cd85fba956b5ebbbe9695da9e2a31acca508",
  "after": "1e846f537277496991d755d4ea63e6d90e30702a",
  "head_commit": {
    "id": "1e846f537277496991d755d4ea63e6d90e30702a",
    "tree_id": "de579ae71e4ddc0b0c6c5748163c1489c4fca20b",
    "distinct": true,
    "message": "Task 4 - testing multi-service",
    "timestamp": "2025-06-14T10:12:54-04:00",
    "url": "https://github.com/ECHagedorn/devops-hq-eh/commit/1e846f537277496991d755d4ea63e6d90e30702a",
    "author": {
      "name": "Emmanuel Hagedorn",
      "email": "hagedorn.emmanuel.us@gmail.com",
      "username": "ECHagedorn"
    },
    "committer": {
      "name": "Emmanuel Hagedorn",
      "email": "hagedorn.emmanuel.us@gmail.com",
      "username": "ECHagedorn"
    },
    "added": [

    ],
    "removed": [

    ],
    "modified": [
      "manifests/helm/hquarter/README.md"
    ]
  }
}'  http://192.168.2.11:31621
