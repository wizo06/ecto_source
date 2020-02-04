defmodule EctoSource do
  @moduledoc """
  An Elixir library that replicates the SOURCE option in the FIELD macro from Ecto 2.2+
  """

  @doc """
  Returns a map where each key in `params` is the value in `db_keys`.

  ## Example

  iex> EctoSource.source(%{first_name: "lorem", last_name: "ipsum", middle_name: "dolor"}, %{first_name: :firstName, last_name: :lastName})
  %{
    firstName: "lorem",
    lastName: "ipsum",
    middle_name: "dolor"
  }
  """
  def source(params, db_keys) when is_map(params) and is_map(db_keys) do
    params
    |> Enum.map(fn {key, val} ->
      case db_key = Map.get(db_keys, key) do
        nil ->
          {key, val}
        _ ->
          {db_key, val}
      end
    end)
    |> Enum.into(%{})
  end

  @doc """
  Returns a map where the keys are the items of `list` in snake_case, and the values are the items of `list`.

  ## Example

  iex> EctoSource.create_db_keys([:camelCase1, :camelCase2, :snake_case, :PascalCase])
  %{
    camel_case1: :camelCase1,
    camel_case2: :camelCase2,
    pascal_case: :PascalCase,
    snake_case: :snake_case
  }
  """
  def create_db_keys(list) when is_list(list) do
    orig_tuple =
      list
      |> List.to_tuple

    snake_tuple =
      list
      |> Enum.map(fn x ->
        x
        |> Atom.to_string
        |> Macro.underscore
        |> String.to_atom
      end)
      |> List.to_tuple

    for index <- 0..length(list)-1, into: %{} do
      {elem(snake_tuple, index), elem(orig_tuple, index)}
    end
  end
end
