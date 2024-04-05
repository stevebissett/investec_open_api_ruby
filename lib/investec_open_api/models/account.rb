require 'dry-struct'
require 'dry-types'
require "investec_open_api/string_utilities"
require_relative 'base' 

module Types
  include Dry.Types()
  Bool = Types::Strict::Bool.optional.default(nil)
end

module InvestecOpenApi::Models
  class Account < Dry::Struct
    extend Base
    transform_keys do |key|
      key_mapping(key.to_s)
    end

    attribute :id, Types::String
    attribute :number, Types::Coercible::Integer
    attribute :name, Types::String
    attribute :reference_name, Types::String
    attribute :product_name, Types::String
    attribute :kyc_compliant, Types::Bool
    attribute :profile_id, Types::String
    attribute :profile_name, Types::String

    def self.key_map
      {
        'accountId' => :id,
        'accountNumber' => :number,
        'accountName' => :name
      }
    end

  end
end
