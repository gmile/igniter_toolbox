# IgniterToolbox

A collection of useful [Igniter](https://github.com/ash-project/igniter)-based Mix tasks for code generation.

## Installation

Add `igniter_toolbox` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:igniter_toolbox, "~> 0.1.0"}
  ]
end
```

## Tasks

### `mix igniter.gen.test_case`

Generates a new test case by copying the first test in a describe block.

#### Usage

```sh
mix igniter.gen.test_case PATH SEARCH DESCRIPTION
```

- `PATH` - Path to the test file (e.g., `test/my_test.exs`)
- `SEARCH` - Partial string to match against describe block names
- `DESCRIPTION` - The name for the new test

#### Behavior

1. **Single match**: Copies the first test, e.g. typically a "happy path", in the matching describe block and appends it with the new description
2. **Multiple matches**: Shows a list of matching describe blocks with line numbers
3. **No matches**: Creates a new describe block at the end of the test module

#### Examples

```bash
# Add a test to an existing describe block
mix igniter.gen.test_case test/user_test.exs "create" "returns error when email invalid" --yes
```

```sh
# If multiple describe blocks match, you'll see:
# Multiple matches in test/user_test.exs:
#   - Line 10: create/1
#   - Line 45: create_admin/1
```

```sh
# If no describe block matches, a new one is created
mix igniter.gen.test_case test/user_test.exs "new_feature" "handles edge case" --yes
```

## Releasing

1. Bump version in `mix.exs`
2. Commit the change
3. Tag it: `git tag vX.Y.Z`
4. Push the tag: `git push origin vX.Y.Z`

## License

MIT License - see [LICENSE](LICENSE) for details.
