defmodule Tirexs.Mapping do
  @moduledoc false

  use Tirexs.DSL.Logic


  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(Tirexs.Index.Settings), only: :macros
      import unquote(__MODULE__), only: :macros
    end
  end

  @doc false
  defmacro mappings([do: block]) do
    mappings =  [properties: extract(block)]
    quote do
      var!(index) = var!(index) ++ [mapping: unquote(mappings)]
    end
  end


  import Tirexs.ElasticSearch

  @doc false
  def transpose(block) do
    case block do
      {:indexes, _, [params]} -> indexes(params[:do])
      {:indexes, _, options}  -> indexes(options)
      {:index, _, [params]}   -> indexes(params[:do])
      {:index, _, options}    -> indexes(options)
    end
  end

  @doc false
  def indexes(options) do
    case options do
      [name, options] ->
        if options[:do] != nil do
          block = options
          options = [type: "object"]
          Dict.put([], to_atom(name), options ++ [properties: extract(block[:do])])
        else
          Dict.put([], to_atom(name), options)
        end
      [name, options, block] ->
        Dict.put([], to_atom(name), options ++ [properties: extract(block[:do])])
    end
  end

  @doc false
  def create_resource(definition) do
    create_resource(definition, config())
  end

  @doc false
  def create_resource(definition, opts) do
    cond do
      definition[:settings] ->
        url  = "#{definition[:index]}"
        json = to_resource_json(definition)

        post(url, json, opts)
      definition[:type] ->
        create_resource_settings(definition, opts)

        url  = "#{definition[:index]}/#{definition[:type]}/_mapping"
        json = to_resource_json(definition)

        put(url, json, opts)
      true ->
        url  = "#{definition[:index]}/_mapping"
        json = to_resource_json(definition, definition[:index])

        put(url, json, opts)
    end
  end

  @doc false
  def create_resource_settings(definition, opts) do
    unless exist?(definition[:index], opts), do: put(definition[:index], opts)
  end

  @doc false
  def to_resource_json(definition) do
    to_resource_json(definition, definition[:type])
  end

  @doc false
  def to_resource_json(definition, type) do
    resource =
      # definition w/ mappings and settings
      if definition[:settings] != nil do
        mappings_dict = Dict.put([], to_atom(type), definition[:mapping])
        resource = Dict.put([], to_atom("mappings"), mappings_dict)
        resource = Dict.put(resource, to_atom("settings"), definition[:settings])
      # definition just only w/ mapping
      else
        Dict.put([], to_atom(type), definition[:mapping])
      end

    Tirexs.HTTP.encode(resource)
  end
end
