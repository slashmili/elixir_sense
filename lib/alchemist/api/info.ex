defmodule Alchemist.API.Info do

  @moduledoc false

  import IEx.Helpers, warn: false

  alias Alchemist.Helpers.ModuleInfo
  alias Alchemist.Helpers.Complete

  def request(args) do
    args
    |> normalize
    |> process
  end

  def process(:modules) do
    modules = ModuleInfo.all_applications_modules
    |> Enum.uniq
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(&ModuleInfo.moduledoc?/1)

    functions = Complete.run('')

    modules ++ functions
    |> Enum.uniq
    |> Enum.map(&IO.puts/1)

    IO.puts "END-OF-INFO"
  end

  def process(:mixtasks) do
    # append things like hex or phoenix archives to the load_path
    Mix.Local.append_archives

    :code.get_path
    |> Mix.Task.load_tasks
    |> Enum.map(&Mix.Task.task_name/1)
    |> Enum.sort
    |> Enum.map(&IO.puts/1)

    IO.puts "END-OF-INFO"
  end

  def process({:info, arg}) do
    try do
      Code.eval_string("i(#{arg})", [], __ENV__)
    rescue
      _e -> nil
    end

    IO.puts "END-OF-INFO"
  end

  def process({:types, arg}) do
    try do
      Code.eval_string("t(#{arg})", [], __ENV__)
    rescue
      _e -> nil
    end

    IO.puts "END-OF-INFO"
  end

  def process(nil) do
    IO.puts "END-OF-INFO"
  end

  def normalize(request) do
    try do
      arguments = Code.eval_string(request)
      case arguments do
        {{_, type }, _}     -> type
        {{_, type, arg}, _} ->
          IO.puts System.version
          if Version.match?(System.version, ">=1.2.0-rc.0") do
            {type, arg}
          else
            nil
          end
      end
    rescue
      _e -> nil
    end
  end
end