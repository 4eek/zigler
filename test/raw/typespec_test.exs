defmodule ZiglerTest.Raw.TypespecTest do
  use ExUnit.Case, async: true

  @moduletag :typespec

  require ZiglerTest.Compiler

  setup_all do
    ZiglerTest.Compiler.compile("_typespec.ex")

    Code.Typespec.fetch_specs(ZiglerTest.Raw.Typespec)
  end

  test "raw call with single arity has correct typespecs", specs do
    assert [
             {:type, _, :fun,
              [
                {:type, _, :product, [{:type, _, :term, _}]},
                {:type, _, :term, _}
              ]}
           ] = specs[{:raw, 1}]
  end

  test "raw call with multi arity has correct typespecs", specs do
    assert [
             {:type, _, :fun,
              [
                {:type, _, :product, [{:type, _, :term, _}]},
                {:type, _, :term, _}
              ]}
           ] = specs[{:multi_raw, 1}]

    assert [
             {:type, _, :fun,
              [
                {:type, _, :product,
                 [{:type, _, :term, _}, {:type, _, :term, _}, {:type, _, :term, _}]},
                {:type, _, :term, _}
              ]}
           ] = specs[{:multi_raw, 3}]

    assert [
             {:type, _, :fun,
              [
                {:type, _, :product,
                 [
                   {:type, _, :term, _},
                   {:type, _, :term, _},
                   {:type, _, :term, _},
                   {:type, _, :term, _}
                 ]},
                {:type, _, :term, _}
              ]}
           ] = specs[{:multi_raw, 4}]

    refute Map.has_key?(specs, {:multi_raw, 0})
    refute Map.has_key?(specs, {:multi_raw, 2})
    refute Map.has_key?(specs, {:multi_raw, 5})
  end
end