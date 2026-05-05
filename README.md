Add this to your .<shell>rc:

```
hypoclaude() {
  local provided_path="${1:?Usage: hypoclaude <path>}"
  local resolved_path="${provided_path:A}"
  local basename="${resolved_path:t}"

  [[ -d "$resolved_path" ]] || { echo "hypoclaude: not a directory: $resolved_path" >&2; return 1; }

  local -a mount_args
  case "$OSTYPE" in
    darwin*)
      local host_uid="$(id -u)"
      local host_gid="$(id -g)"
      mount_args=(
        -v"${resolved_path}:/workspaces/${basename}:idmap=uids=${host_uid}-1000-1;gids=${host_gid}-1000-1"
        -v"${HYPOCLAUDE_HOME_DIR}:/home/claude:idmap=uids=${host_uid}-1000-1;gids=${host_gid}-1000-1"
      )
      ;;
    linux*)
      mount_args=(
        -v"${resolved_path}:/workspaces/${basename}:z"
        -v"${HYPOCLAUDE_HOME_DIR}:/home/claude:z"
        --userns=keep-id:uid=1000,gid=1000
      )
      ;;
    *)
      echo "hypoclaude: unsupported OS: $OSTYPE" >&2
      return 1
      ;;
  esac

  podman run --rm -it \
    "${mount_args[@]}" \
    --workdir "/workspaces/${basename}" \
    localhost/hypoclaude:latest
}
```

and set `HYPOCLAUDE_HOME_DIR` env variable to absolute path `out/claude` directory
that appeared after `make rebuild`. I suggest moving it outside of the repo so
it is possible to rebuild `hypoclaude` image and homedir without losing data
in claude's home directory
