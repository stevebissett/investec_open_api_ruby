module InvestecOpenApi::Models
  AccountStruct = Struct.new(
    :id,
    :number,
    :name,
    :reference_name,
    :product_name,
    :kyc_compliant,
    :profile_id,
    :profile_name,
    keyword_init: true,
  )

  class Account < AccountStruct
    # Define a mapping from API response keys to our struct attributes
    KEY_MAPPING = {
      "accountId" => :id,
      "accountNumber" => :number,
      "accountName" => :name,
    # Continue mapping other specific keys as needed
    }

    def self.from_api(params = {})
      # Initialize mapped_params with default nil values for all struct members
      mapped_params = Account.members.each_with_object({}) { |member, memo| memo[member] = nil }

      params.each do |key, value|
        if KEY_MAPPING[key]
          mapped_params[KEY_MAPPING[key]] = value
        elsif mapped_params.has_key?(underscore(key).to_sym)
          mapped_params[underscore(key).to_sym] = value
        end
      end

      new(mapped_params)
    end

    def self.underscore(camel_cased_word)
      camel_cased_word.gsub(/::/, "/")
                      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                      .tr("-", "_")
                      .downcase
    end
  end
end
