---
name: release
description: >
  Cut a release of one of Leonid's libraries: changelog, version, annotated tag,
  push, and Maven Central or the Gradle Plugin Portal. Then delete branches
  already contained in that commit or in master.
  Use when he says "release" in a library checkout, or runs /release.
metadata:
  short-description: "Cut a library release"
---

# Release a library

Run this in the checkout where he said `release`.
A library has `CHANGELOG.md` and `podvalCentral=true` in `gradle.properties`, or it applies `com.gradle.plugin-publish`.
If neither is true, stop and say this checkout has no release path.

Leave existing tags and release commits as they are.
This procedure is the next release only.

## Before editing

Read `CHANGELOG.md`, the version property, `git status`, and the publish notes in this repo's README or
`settings.gradle`.

Stop if `## [Unreleased]` has no bullets.
Stop if the worktree is dirty.

Fetch `master` from `origin` and rebase the local commits onto it.
Follow the YubiKey rule for `git@github.com` before the fetch.

```
git fetch origin master:refs/remotes/origin/master
git rebase origin/master
```

If the fetch is not a fast-forward, or the rebase conflicts, stop.

If this repo `includeBuild`s a sibling whose checkout is ahead of the coordinate this repo declares, stop.
Release that sibling first.
`site-publisher` substitutes `../xml`.

Propose the next minor version and quote any `Breaking:` lines.
Wait for the version, and for a yes on the push and the upload, before editing.

## Cut

Set the version property.
That is `version` in `gradle.properties`, unless the build assigns `version = version_plugin`, in which case set
`version_plugin`.

Insert a blank line and `## [x.y.z] - YYYY-MM-DD` under `## [Unreleased]`.
The date is the day of the release.
Leave `## [Unreleased]` with no bullets.
The bullets that were under it belong to the new heading.

Bump every README coordinate or plugin id that this repo's readme-version check requires.
Read that check task.

Pretty-print every Markdown and AsciiDoc file this cut edits.

Run `./gradlew check`.
That runs `test`, and any readme-version check this repo attached to `check`.

Commit subject, exactly:

```
- release: x.y.z;
```

Annotated tag on that commit.
The tag name is `vx.y.z`.
The tag message is `x.y.z` and nothing else.

```
git tag -a vx.y.z -m x.y.z
```

## Publish

Follow the YubiKey rule, then push the commit and the tag.

## Branches

After that push, delete every branch whose tip is already in the pushed commit or in `master`.

A tip is contained when `git merge-base --is-ancestor <tip> <commit>` succeeds.
Check `HEAD` and `master`.
On `origin`, check the pushed `HEAD` and `origin/master` only.
A local `master` that has not been pushed does not make an `origin` branch safe.
A squash merge does not contain the old tip, so that branch stays.

Never delete the current branch, `master`, or `origin/HEAD`.

Local: `git branch -d <name>`.
When the tip is in `master` but not in `HEAD`, `-d` can refuse.
`git branch -D <name>` is then allowed for that proven ancestor only.
When the branch is checked out in another worktree, leave it and report the path.

On `origin`: `git push origin --delete <name>` for each safe name that exists there.
Follow the YubiKey rule if the mux from the push is no longer live.
Skip a missing name.

## Upload

For `podvalCentral=true`, upload with:

```
./gradlew nmcpZipAggregation
./gradlew publishAggregationToCentralPortal
```

Publishing type is `USER_MANAGED`.
The upload is not yet a Central release.
Stop and report the deployment id.
Run `./gradlew nmcpPublishDeployment -PnmcpDeploymentId=…` only after he says to release that deployment.

A repo that applies `com.gradle.plugin-publish` and has no `podvalCentral` publishes the way its README says.
Do not run the nmcp tasks there.

The changelog and the annotated tag are the release record.
List coordinates that still pin the previous version, and wait.
