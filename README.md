Add this to your .<shell>rc:

```
cclaude() {
  local provided_path="${1:?Usage: cclaude <path>}"
  local resolved_path="${provided_path:A}"
  local basename="${resolved_path:t}"

  [[ -d "$resolved_path" ]] || { echo "cclaude: not a directory: $resolved_path" >&2; return 1; }

  local -a mount_args
  case "$OSTYPE" in
    darwin*)
      local host_uid="$(id -u)"
      local host_gid="$(id -g)"
      mount_args=(
        -v"${resolved_path}:/workspaces/${basename}:idmap=uids=${host_uid}-1000-1;gids=${host_gid}-1000-1"
        -v"${CCLAUDE_HOME_DIR}:/home/claude:idmap=uids=${host_uid}-1000-1;gids=${host_gid}-1000-1"
      )
      ;;
    linux*)
      mount_args=(
        -v"${resolved_path}:/workspaces/${basename}:z"
        -v"${CCLAUDE_HOME_DIR}:/home/claude:z"
        --userns=keep-id:uid=1000,gid=1000
      )
      ;;
    *)
      echo "cclaude: unsupported OS: $OSTYPE" >&2
      return 1
      ;;
  esac

  local -a env_args
  local env_file="${CCLAUDE_ENV_VARS_DIR}/${basename}.env"
  if [[ -n "$CCLAUDE_ENV_VARS_DIR" && -f "$env_file" ]]; then
    env_args=(--env-file "$env_file")
  fi

  podman run --rm -it \
    "${mount_args[@]}" \
    "${env_args[@]}" \
    --workdir "/workspaces/${basename}" \
    localhost/cclaude:latest
}
```

and set `CCLAUDE_HOME_DIR` env variable to absolute path `out/claude` directory
that appeared after `make rebuild`. I suggest moving it outside of the repo so
it is possible to rebuild `cclaude` image and homedir without losing data
in claude's home directory

Optionally set `CCLAUDE_ENV_VARS_DIR` to a directory with per-project env files.
If `$CCLAUDE_ENV_VARS_DIR/<project_name>.env` exists (where `<project_name>` is
the basename of the directory passed to `cclaude`), it is passed to the
container via `podman run --env-file`.
