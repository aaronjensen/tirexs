defmodule Tirexs.Index.Settings do
  @moduledoc false

  import Tirexs.DSL.Logic
  import Tirexs.Index.Logic


  defmacro settings([do: block]) do
    quote do
      var!(index) = Dict.put(var!(index), :settings, [])
      var!(index) = put_setting(var!(index), :index)
      unquote(block)
    end
  end

  defmacro filters([do: block]) do
    quote do
      var!(index) = if var!(index)[:settings][:analysis] == nil do
        put_setting(var!(index), :analysis)
      else
        var!(index)
      end
      unquote(block)
    end
  end

  defmacro analysis([do: block]) do
    quote do
      var!(index) = if var!(index)[:settings][:analysis] == nil do
        put_setting(var!(index), :analysis)
      else
        var!(index)
      end
      unquote(block)
    end
  end

  defmacro set(settings) do
    quote do
      settings = unquote(settings)
      var!(index) = add_index_setting(var!(index), settings)
    end
  end

  defmacro analyzer(name, value) do
    quote do
      var!(index) = if var!(index)[:settings][:analysis][:analyzer] == nil do
        put_index_setting(var!(index), :analysis, :analyzer)
      else
        var!(index)
      end
      [name, value] = [unquote(name), unquote(value)]
      var!(index) = add_index_setting(var!(index), :analysis, :analyzer, Dict.put([], to_atom(name), value))
    end
  end

  defmacro blocks(value) do
    quote do
      var!(index) = if var!(index)[:settings][:index][:blocks] == nil do
        put_index_setting(var!(index), :index, :blocks)
      else
        var!(index)
      end
      value = unquote(value)
      var!(index) = add_index_setting(var!(index), :index, :blocks, value)
    end
  end

  defmacro cache(value) do
    quote do
      var!(index) = if var!(index)[:settings][:index][:cache] == nil do
        index = put_index_setting(var!(index), :index, :cache)
        add_index_setting(index, :index, :cache, [filter: []])
      else
        var!(index)
      end
      value = unquote(value)
      var!(index) = add_index_setting_nested_type(var!(index), :index, :cache, :filter, value)
    end
  end

  defmacro filter(name, value) do
    quote do
      var!(index) = if var!(index)[:settings][:analysis][:filter] == nil do
        put_index_setting(var!(index), :analysis, :filter)
      else
        var!(index)
      end
      [name, value] = [unquote(name), unquote(value)]
      var!(index) = add_index_setting(var!(index), :analysis, :filter, Dict.put([], to_atom(name), value))
    end
  end

  defmacro tokenizer(name, value) do
    quote do
      var!(index) = if var!(index)[:settings][:analysis][:tokenizer] == nil do
        put_index_setting(var!(index), :analysis, :tokenizer)
      else
        var!(index)
      end
      [name, value] = [unquote(name), unquote(value)]
      var!(index) = add_index_setting(var!(index), :analysis, :tokenizer, Dict.put([], to_atom(name), value))
    end
  end

  defmacro translog(value) do
    quote do
      var!(index) = if var!(index)[:settings][:index][:translog] == nil do
        put_index_setting(var!(index), :index, :translog)
      else
        var!(index)
      end
      value = unquote(value)
      var!(index) = add_index_setting(var!(index), :index, :translog, value)
    end
  end

end