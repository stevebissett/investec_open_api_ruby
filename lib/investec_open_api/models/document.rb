require 'dry-struct'
require 'dry-types'
require "investec_open_api/string_utilities"
require_relative 'base' 

module InvestecOpenApi::Models
  class Document < Dry::Struct
    extend Base
    transform_keys do |key|
      key_mapping(key.to_s)
    end

    attribute :type, Types::String
    attribute :date, Types::Params::Date
    attribute :file_content, Types::String.optional.default(nil)

    def id
        data_string = [type, date.to_s].to_s
        Digest::SHA1.hexdigest(data_string)
    end

    def file_name
      # Assumes PDF formatted documents only
      #"#{type.underscore}_#{date.strftime('%Y-%m-%d')}.pdf"
      "#{type}_#{date.strftime('%Y-%m-%d')}.pdf"

    end

    def self.key_map
      {
        'documentType' => :type,
        'documentDate' => :date
      }
    end

    def to_h
      super().transform_values do |value|
        value.is_a?(Date) ? value.strftime('%Y-%m-%d') : value
      end
    end

  end
end
