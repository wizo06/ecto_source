# ecto_source
An Elixir library that replicates the SOURCE option in the FIELD macro from Ecto 2.2+

## The problem

Using [Absinthe](https://github.com/absinthe-graphql/absinthe), [Ecto](https://github.com/elixir-ecto/ecto) and [mongodb_ecto](https://github.com/ankhers/mongodb_ecto) together.

If you use Absinthe as your GraphQL adapter,
all arguments coming from queries and mutations will be in snake_case.

If your `Ecto.Schema` has fields that are **not** in snake_case,
`Ecto.Changeset.cast/3` will discard all fields that don't match with `Ecto.Schema`.

A possible solution is to install Ecto 2.2 or above, and use the `:source` option in the `field/3` macro. You can then define all your `Ecto.Schema` fields in snake_case so they match with arguments coming from Absinthe queries and mutations. Then, you can pass in `:source` as a third argument to `field/3` and define the actual key that will be inserted to the database.

Example:

If your database has a `User` collection with fields `firstName` and `lastName` (camelCase), you can define your `Ecto.Schema` like so:
```elixir
defmodule User do
  use Ecto.Schema
  import Ecto.Changeset
  alias User

  schema "users" do
    field :first_name, :string, source: :firstName
    field :last_name, :string, source: :lastName
  end

  def changeset(user = %User{}, params) do
    user
    |> cast(params, [:first_name, :last_name])
  end
end
```

As of August 18th 2018, [mongodb_ecto](https://github.com/ankhers/mongodb_ecto) only supports [Ecto](https://github.com/elixir-ecto/ecto) 2.1, which **does not** have the `:source` option in the `field/3` macro.

## The solution

This bootleg library that I put together to replicate the functionality of the `:source` option.

## Usage
```elixir
defmodule User do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoSource # import the module
  alias User

  schema "users" do
    field :firstName, :string # define your Ecto.Schema fields in the casing that you want to be inserted to the database
    field :lastName, :string
  end

  # declare a variable as a Map, where the keys are in snake_case, and the values match with Ecto.Schema
  @db_keys %{
    first_name: :firstName,
    last_name: :lastName
  }

  def changeset(user = %User{}, params) do
    params = source(params, @db_keys) # call the source/2 function and pass in the `params` and the Map declared above

    user
    |> cast(params, [:firstName, :lastName])
  end
end
```
**Note**: if you want a field to be inserted as snake_case to the database, you don't need to include it in `@db_keys`. The same principle applies if you were to use the `:source` option in Ecto 2.2+.

**How to tell if a key needs to be included in @db_keys?**  
Open up an `iex` session and run `Macro.underscore/1`.  
Example:
```sh-session
$ iex
iex(1)> Macro.underscore("firstName")
"first_name"
iex(2)> Macro.underscore("first_name")
"first_name"
iex(3)> Macro.underscore("FirstName")
"first_name"
```
If you don't want to manually declare `@db_keys`, you can call `create_db_keys/1`. It takes in a List of Atom and returns the `@db_keys` Map for you.
```elixir
defmodule User do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoSource
  alias User

  schema "users" do
    field :firstName, :string
    field :lastName, :string
  end

  @fields ~w(firstName lastName)a

  def changeset(user = %User{}, params) do
    params = source(params, create_db_keys(@fields))

    user
    |> cast(params, [:firstName, :lastName])
  end
end
```
## Installation
```elixir
def deps do
  [{:ecto_source, github: "d4rkwizo/ecto-source"}]
end
```
Run:
```sh-session
$ mix deps.get
```
