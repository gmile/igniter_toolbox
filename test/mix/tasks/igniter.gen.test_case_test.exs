defmodule Mix.Tasks.Igniter.Gen.TestCaseTest do
  use ExUnit.Case
  import Igniter.Test

  describe "single matching describe block" do
    test "copies first test with new description" do
      test_project()
      |> Igniter.create_new_file("test/example_test.exs", """
      defmodule ExampleTest do
        use ExUnit.Case

        describe "my feature" do
          test "existing test" do
            assert 1 + 1 == 2
          end
        end
      end
      """)
      |> apply_igniter!()
      |> Igniter.compose_task("igniter.gen.test_case", [
        "test/example_test.exs",
        "feature",
        "new test case"
      ])
      |> assert_has_patch("test/example_test.exs", """
       + |    test "new test case" do
      """)
    end

    test "appends after last test when multiple tests exist" do
      test_project()
      |> Igniter.create_new_file("test/example_test.exs", """
      defmodule ExampleTest do
        use ExUnit.Case

        describe "create" do
          test "first" do
            assert true
          end

          test "second" do
            assert false
          end
        end
      end
      """)
      |> apply_igniter!()
      |> Igniter.compose_task("igniter.gen.test_case", [
        "test/example_test.exs",
        "create",
        "third test"
      ])
      |> assert_has_patch("test/example_test.exs", """
       + |    test "third test" do
      """)
    end
  end

  describe "multiple matching describe blocks" do
    test "returns error with list of matches" do
      igniter =
        test_project()
        |> Igniter.create_new_file("test/example_test.exs", """
        defmodule ExampleTest do
          use ExUnit.Case

          describe "create user" do
            test "works" do
              assert true
            end
          end

          describe "create admin" do
            test "works" do
              assert true
            end
          end
        end
        """)
        |> apply_igniter!()
        |> Igniter.compose_task("igniter.gen.test_case", [
          "test/example_test.exs",
          "create",
          "new test"
        ])

      source = Rewrite.source!(igniter.rewrite, "test/example_test.exs")

      assert Enum.any?(source.issues, fn {_, msg} ->
               String.contains?(msg, "Multiple matches")
             end)
    end
  end

  describe "no matching describe block" do
    test "creates new describe block at end of module" do
      test_project()
      |> Igniter.create_new_file("test/example_test.exs", """
      defmodule ExampleTest do
        use ExUnit.Case

        describe "existing" do
          test "works" do
            assert true
          end
        end
      end
      """)
      |> apply_igniter!()
      |> Igniter.compose_task("igniter.gen.test_case", [
        "test/example_test.exs",
        "new_feature",
        "my new test"
      ])
      |> assert_has_patch("test/example_test.exs", """
       + |  describe "new_feature" do
      """)
    end
  end
end
