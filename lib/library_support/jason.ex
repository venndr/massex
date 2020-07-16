if Code.ensure_loaded?(Jason) do
  defimpl Jason.Encoder, for: Massex do
    def encode(mass, options) do
      Jason.Encode.map(
        %{amount: mass.amount, unit: mass.unit},
        options
      )
    end
  end
end
