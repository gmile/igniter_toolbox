defmodule Mix.Tasks.Igniter.Gen.TestCase do
  @moduledoc """
  Generates a new test case by copying the first test in a describe block.

  ## Usage

      mix igniter.gen.test_case PATH SEARCH DESCRIPTION

  - If one describe matches SEARCH: copies first test with new DESCRIPTION
  - If multiple match: shows list of line numbers
  - If none match: creates new describe block

  ## Example

      mix igniter.gen.test_case test/my_test.exs create "returns error when invalid"
  """

  use Igniter.Mix.Task

  alias Sourceror.Zipper
  alias Igniter.Code.{Common, Function, Module}

  def info(_argv, _source) do
    %Igniter.Mix.Task.Info{
      example: "mix igniter.gen.test_case test/my_test.exs create \"returns error\"",
      positional: [:path, :search, :description]
    }
  end

  def igniter(igniter) do
    %{path: path, search: search, description: desc} = igniter.args.positional

    Igniter.update_elixir_file(igniter, path, fn zipper ->
      case find_matching_describes(zipper, search) do
        [] ->
          add_describe_block(zipper, search, desc)

        [{_name, line}] ->
          add_test_to_describe_at(zipper, line, desc)

        matches ->
          {:error, format_matches(path, matches)}
      end
    end)
  end

  defp find_matching_describes(zipper, search) do
    zipper
    |> Common.find_all(&Function.function_call?(&1, :describe, 2))
    |> Enum.flat_map(fn z ->
      with {:describe, meta, [{:__block__, _, [name]} | _]} <- z.node,
           true <- String.contains?(name, search) do
        [{name, meta[:line]}]
      else
        _ -> []
      end
    end)
  end

  defp add_describe_block(zipper, name, desc) do
    code = """
    describe "#{name}" do
      test "#{desc}" do
        assert true
      end
    end
    """

    with {:ok, mod} <- Module.move_to_defmodule(zipper),
         {:ok, body} <- Common.move_to_do_block(mod) do
      {:ok, body |> Common.add_code(code, placement: :after) |> Zipper.topmost()}
    end
  end

  defp add_test_to_describe_at(zipper, line, desc) do
    describe =
      zipper
      |> Common.find_all(&Function.function_call?(&1, :describe, 2))
      |> Enum.find(fn z ->
        {:describe, meta, _} = z.node
        meta[:line] == line
      end)

    {:describe, desc_meta, _} = describe.node
    desc_start = desc_meta[:line]
    desc_end = desc_meta[:end][:line]

    with {:ok, body} <- Common.move_to_do_block(describe) do
      tests =
        body
        |> Common.find_all(&Function.function_call?(&1, :test, 2))
        |> Enum.filter(fn z ->
          {_, meta, _} = z.node
          meta[:line] >= desc_start and meta[:line] <= desc_end
        end)

      case tests do
        [] ->
          {:error, "No tests in describe block"}

        [first | _] ->
          {call, meta, [{n, nm, _}, rest]} = first.node
          new_test = {call, meta, [{n, nm, [desc]}, rest]}
          {:ok, tests |> List.last() |> Common.add_code(new_test, placement: :after) |> Zipper.topmost()}
      end
    end
  end

  defp format_matches(path, matches) do
    lines = Enum.map_join(matches, "\n", fn {name, line} -> "  - Line #{line}: #{name}" end)
    "Multiple matches in #{path}:\n#{lines}"
  end
end
