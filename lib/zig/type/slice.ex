defmodule Zig.Type.Slice do
  alias Zig.Parameter
  alias Zig.Return
  alias Zig.Type
  use Type

  defstruct [:child, :repr, has_sentinel?: false]

  import Type, only: :macros

  @type t :: %__MODULE__{
          child: Type.t(),
          repr: String.t(),
          has_sentinel?: boolean
        }

  def from_json(
        %{"child" => child, "has_sentinel" => has_sentinel?, "repr" => repr},
        module
      ) do
    %__MODULE__{
      child: Type.from_json(child, module),
      has_sentinel?: has_sentinel?,
      repr: repr
    }
  end

  # TYPE SPEC STUFF

  def render_elixir_spec(type, %Return{as: as}) do
    render_elixir_spec(type, as)
  end

  def render_elixir_spec(type, %Parameter{} = params) do
    if typespec = Type.binary_typespec(type) do
      quote context: Elixir do
        [unquote(Type.render_elixir_spec(type.child, params))] | unquote(typespec)
      end
    else
      quote context: Elixir do
        [unquote(Type.render_elixir_spec(type.child, params))]
      end
    end
  end

  def render_elixir_spec(%{child: child}, {:list, child_spec}) do
    [Type.render_elixir_spec(child, child_spec)]
  end

  def render_elixir_spec(%{child: child}, :list) do
    [Type.render_elixir_spec(child, :default)]
  end

  def render_elixir_spec(spec, :binary) do
    Type.binary_typespec(spec)
  end

  def render_elixir_spec(%{child: ~t(u8)}, :default) do
    quote do
      binary()
    end
  end

  def render_elixir_spec(%{child: child}, :default) do
    [Type.render_elixir_spec(child, :default)]
  end

  def render_zig(slice), do: slice.repr

  # ETC

  def get_allowed?(slice), do: Type.get_allowed?(slice.child)
  def make_allowed?(slice), do: Type.make_allowed?(slice.child)
  def can_cleanup?(_), do: true

  def binary_size(slice) do
    case Type.binary_size(slice.child) do
      size when is_integer(size) -> {:var, size}
      {:indirect, size} when is_integer(size) -> {:var, size}
      _ -> nil
    end
  end

  def render_payload_options(_, _, _), do: Type._default_payload_options()
  def marshal_param(_, _, _, _), do: Type._default_marshal()
  def marshal_return(_, _, _), do: Type._default_marshal()

  def of(child, opts \\ []), do: struct(__MODULE__, [child: child] ++ opts)
end
