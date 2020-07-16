if Code.ensure_loaded?(Absinthe) do
  defmodule Massex.Absinthe.Type do
    @moduledoc """
    Ready-baked utility types to integrate Massex with your Absinthe schema
    """

    use Absinthe.Schema.Notation

    @desc """
    The units of mass are represented here, and the amount of a `Mass` should be
    intepreted within this context.
    """
    enum :mass_unit_enum do
      value(:gram, description: "A gram")
      value(:ounce, description: "An ounce")
    end

    @desc """
    A `Mass` represents an amount of mass, such as some grams, or ounces.
    """
    object :mass do
      field(:amount, non_null(:number))
      field(:unit, non_null(:mass_unit_enum))
    end

    @desc """
    A `MassInput` represnts an amount of mass which can be submitted to the server
    as an argument or as part of a mutation
    """
    input_object :mass_input do
      field(:amount, non_null(:number))
      field(:unit, non_null(:mass_unit_enum))
    end
  end
end
