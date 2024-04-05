module InvestecOpenApi::Models
  Account = Struct.new(*Base.members, keyword_init: true) do
    def self.from_api(params = {})
      # Map API parameters to Struct attributes
      mapped_params = {
        id: params['accountId'],
        number: params['accountNumber'],
        name: params['accountName'],
        # Add other attributes as needed
      }

      # Remove nil entries
      mapped_params.compact!

      super(mapped_params)
    end
  end
end