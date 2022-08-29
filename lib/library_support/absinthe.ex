if Code.ensure_loaded?(Absinthe) do
  defmodule Massex.Absinthe.Type do
    @moduledoc """
    Ready-baked utility types to integrate Massex with your Absinthe schema

    ## Usage

        defmodule MySchema do
          # setup
          import_types Massex.Absinthe.Type
        end

        object :lorry do
          field :mass, :mass
        end

        payload field :set_lorry_mass do
          input do
            field :id, non_null(:id)
            field :mass, non_null(:mass_input)
          end
        end

        query {
          lorry {
            mass {
              amount
              unit
            }
          }
        }
    """

    use Absinthe.Schema.Notation

    @desc """
    The units of mass are represented here, and the amount of a `Mass` should be
    intepreted within this context.
    """
    enum :mass_unit_enum do
      value(:gram, description: "A gram")
      value(:ounce, description: "An ounce")
      value(:pound, description: "A pound")
    end

    @desc """
    A `Mass` represents an amount of mass, such as some grams, or ounces.
    """
    object :mass do
      field(:amount, non_null(:string))
      field(:unit, non_null(:mass_unit_enum))
    end

    @desc """
    A `MassInput` represnts an amount of mass which can be submitted to the server
    as an argument or as part of a mutation
    """
    input_object :mass_input do
      field(:amount, non_null(:string))
      field(:unit, non_null(:mass_unit_enum))
    end
  end
end
