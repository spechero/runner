defmodule Runner.Worker do
  use GenServer

  alias Runner.Client

  def init(_args) do
    say("starting")
    {:ok, {}}
  end

  def handle_cast({:file_change}, state) do
    run_tests() |> handle_test_results()

    {:noreply, state}
  end

  defp run_tests do
    say("Running tests")
    failing_tests()
  end

  defp handle_test_results(tests_failed) when tests_failed == 0 do
    say("all tests passed")
    ensure_local_repo_exists()
    commit_and_push()
  end

  defp handle_test_results(_tests_failed) do
    say("some tests failed")
    if owner(), do: commit_and_push()
  end

  defp ensure_local_repo_exists do
    unless local_repo_exists() do
      say("creating local repo")
      say("git init .")
      request_remote_repo_create()
    end
  end

  defp local_repo_exists do
    say("local repo doesn't exist")
    false
  end

  defp request_remote_repo_create do
    say("requesting client to create remote repo")
    Client.create_remote_repo()
  end

  def remote_repo_created do
    #   git remote add
    #   git push
  end

  defp commit_and_push do
    ensure_local_repo_exists()
    say("git add .")
    say("git commit -m \"Update\"")
    say("git push")
  end

  defp owner() do
    Integer.parse("1") == {1, ""}
  end

  defp failing_tests do
    with {output, _} <- System.cmd("cat", ["test/fixtures/test_output.txt"]),
         [_, failures] <- Regex.run(~r/\d+ doctest, \d+ test, (\d+) failures/, output) do
      Integer.parse(failures)
    else
      _ -> 1
    end
  end

  defp say(str) do
    IO.puts("worker: #{str}")
  end
end
