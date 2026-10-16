# Shared read-only query for the bookmark and status modules. Only jj and shell
# builtins are used; revset membership computes distances without spawning jj
# once per ancestor depth.
mode=$1
case "$mode" in bookmarks | state) ;; *) exit 1 ;; esac

distance_template=10
depth=9
while [ "$depth" -ge 0 ]; do
  distance_template="if(self.contained_in(\"ancestors(@, $((depth + 1)))\"), $depth, $distance_template)"
  depth=$((depth - 1))
done

template='if(current_working_copy, "state\t" ++ if(divergent, "⇔") ++ if(!empty && !description.trim(), "∅") ++ "\n") ++ if(self.contained_in("ancestors(@, 11)"), local_bookmarks.map(|b| '
template="$template$distance_template"' ++ "\t" ++ b.name()).join("\n") ++ "\n")'
revset='(ancestors(@, 11) & bookmarks()) | @'
if [ "$mode" = state ]; then
  # Check remote refs against their tracked local targets, excluding the local
  # Git export. Include remote targets even when they are not ancestors of @.
  revset="$revset | remote_bookmarks()"
  template="$template"' ++ remote_bookmarks.filter(|b| b.remote() != "git" && b.tracked() && !b.synced()).map(|b| "unsynced\t" ++ b.name() ++ "\n").join("")'
fi
records=$(jj log --ignore-working-copy --no-graph --color=never \
  -r "$revset" -T "$template" 2>/dev/null) || exit 1

tab=$(printf '\t')
newline='
'
unsynced=$newline
if [ "$mode" = state ]; then
  while IFS="$tab" read -r distance name; do
    case "$distance" in
      state) printf '%s' "$name" ;;
      unsynced) unsynced="$unsynced$name$newline" ;;
    esac
  done <<EOF
$records
EOF
fi

# Select the nearest three bookmarks, then display those ancestors first.
# Status checks those same three bookmarks, regardless of display order.
depth=0 count=0 output= seen=$newline
while [ "$depth" -le 10 ]; do
  while IFS="$tab" read -r distance name; do
    [ "$distance" = "$depth" ] || continue
    [ -n "$name" ] || continue
    case "$seen" in *"$newline$name$newline"*) continue ;; esac
    seen="$seen$name$newline"
    count=$((count + 1))
    if [ "$mode" = state ]; then
      case "$unsynced" in
        *"$newline$name$newline"*) printf '⇡'; exit 0 ;;
      esac
      [ "$count" -lt 3 ] || exit 0
      continue
    fi
    if [ "$count" -le 3 ]; then
      label=$name
      [ "$depth" -eq 0 ] || label="$label~$depth"
      if [ -z "$output" ]; then
        output=$label
      else
        output="$label, $output"
      fi
    fi
  done <<EOF
$records
EOF
  depth=$((depth + 1))
done
if [ "$mode" = bookmarks ]; then
  [ "$count" -le 3 ] || output="$output, …+$((count - 3))"
  printf '%s' "$output"
fi
