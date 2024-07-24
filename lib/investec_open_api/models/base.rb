module InvestecOpenApi::Models
    using InvestecOpenApi::StringUtilities
    module Base
      def from_api(params)
        new(params)
      end
  
      def key_mapping(key)
        key_map[key] || key.underscore.to_sym
      end
    end
  end