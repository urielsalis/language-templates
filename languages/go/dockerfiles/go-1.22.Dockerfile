# syntax=docker/dockerfile:1.7-labs
FROM golang:1.22-alpine

WORKDIR /app

# .git & README.md are unique per-repository. We ignore them on first copy to prevent cache misses
COPY --exclude=.git --exclude=README.md . /app

# Starting from Go 1.20, the go standard library is no loger compiled.
# Setting GODEBUG to "installgoroot=all" restores the old behavior
RUN GODEBUG="installgoroot=all" go install std

RUN ash -c "set -exo pipefail; go mod graph | awk '{if (\$1 !~ \"@\") {print \$2}}' | xargs -r go get"

# Ensures the container is re-built if go.mod or go.sum changes
ENV CODECRAFTERS_DEPENDENCY_FILE_PATHS="go.mod,go.sum"

# Once the heavy steps are done, we can copy all files back
COPY . /app