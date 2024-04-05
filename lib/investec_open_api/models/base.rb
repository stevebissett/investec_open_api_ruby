module InvestecOpenApi::Models
  Base = Struct.new(:id, :number, :name, :reference_name, :product_name, :kyc_compliant, :profile_id, :profile_name, keyword_init: true) do
    def self.from_api(params = {})
      underscored_params = params.transform_keys do |key|
        key.to_s.underscore.to_sym
      end

      new(underscored_params)
    end
  end
end