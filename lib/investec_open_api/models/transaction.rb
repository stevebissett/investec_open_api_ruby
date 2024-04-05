require "money"

module InvestecOpenApi::Models
  TransactionStruct = Struct.new(
    :account_id,
    :posted_order,
    :type,
    :transaction_type,
    :status,
    :card_number,
    :amount,
    :description,
    :running_balance,
    :date,
    :posting_date,
    :value_date,
    :action_date,
    keyword_init: true
  )

  class Transaction < TransactionStruct
    def id
      [amount.to_i, description, date.to_s].map(&:to_s).join('-')
    end

    def self.from_api(params)
      params = params.transform_keys(&:underscore).symbolize_keys

      if params[:amount]
        adjusted_amount = params[:amount] * 100
        adjusted_amount = -adjusted_amount if params[:type] == 'DEBIT'

        Money.rounding_mode = BigDecimal::ROUND_HALF_UP
        Money.locale_backend = :i18n
        params[:amount] = Money.from_cents(adjusted_amount, "ZAR")
      end

      if params[:running_balance]
        adjusted_amount = params[:running_balance] * 100

        Money.rounding_mode = BigDecimal::ROUND_HALF_UP
        Money.locale_backend = :i18n
        params[:running_balance] = Money.from_cents(adjusted_amount, "ZAR")
      end

      params[:date] = Date.parse(params[:transaction_date]) if params[:transaction_date]

      new(params)
    end
  end
end