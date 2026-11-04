# swift-environment

Use this package when your code reads or sets process environment variables, wants a test or task to see different values without changing the real environment, or loads a dotenv file. Start from `Environment.read`, `Environment.write` and `Environment.withOverlay(_:perform:)`, and from `Environment.Snapshot` and `Environment.Dotenv` for values held apart from the process. `Environment Core` has the snapshot and dotenv types without any process access. If you want environment values as an injected dependency, use swift-environment-dependencies.

## Laws

- Every read and write through this package takes one process-wide lock, so its callers never race on the environment. Code that calls the system functions directly is not covered.
- `Environment.read.all()` decodes names and values lossily: bytes that aren't valid UTF-8 become U+FFFD instead of trapping.
- `Environment.withOverlay(_:perform:)` changes what `Environment.task` reads in that scope and in its child tasks. `Environment.read` and other tasks still see the real environment. An overlay can add or replace values but can't unset one, and an inner overlay replaces the outer one rather than adding to it.
- `Environment.Snapshot.current()` copies the real environment. `Environment.Snapshot.effective()` copies it with the current overlay applied.
- `Environment.write` overwrites an existing value. `Environment.Write.set(_:to:overwrite:)` with `overwrite` false leaves an existing value in place.
- `Environment.Snapshot.bool(_:)` reads `1`, `true`, `yes` and `on` as true and `0`, `false`, `no` and `off` as false, ignoring case. Anything else is nil. `Environment.Snapshot.int(_:)` takes digits only, without surrounding spaces. `Environment.Snapshot.url(_:)` returns the text as it is, unchecked.
- Merging into a snapshot sets each key with a value and removes each key whose value is nil.
- `Environment.Dotenv.init(parsing:)` skips blank lines and lines starting with `#`, accepts an `export ` prefix, and normalizes CRLF line endings. A key starts with a letter or underscore and continues with letters, digits, underscores, dots and hyphens. Spaces around the key and around an unquoted value are trimmed.
- An unquoted value runs to the end of the line, `#` included. A double-quoted value understands `\n`, `\r`, `\t`, `\\` and `\"` and refuses any other escape. A single-quoted value is taken literally. Both quoted forms may span lines, and after the closing quote only a comment may follow.
- Variables in values are not expanded. When a key appears twice, the later value wins.
- A parse error carries the line on which the record starts, except an invalid escape, which carries the line of the escape.
