defmodule Zig.Type.Float do
  use Zig.Type

  defstruct [:bits]

  @type t :: %__MODULE__{bits: 16 | 32 | 64}

  def from_json(%{"bits" => bits}), do: %__MODULE__{bits: bits}

  def to_string(float), do: "f#{float.bits}"

  def marshal_param(_), do: nil
  def marshal_return(_), do: nil
  def param_errors(_), do: nil
end
