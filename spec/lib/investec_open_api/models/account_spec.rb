require "spec_helper"
require "investec_open_api/models/account"

RSpec.describe InvestecOpenApi::Models::Account do
  describe "#from_api" do
    context "with valid attributes" do
      it "returns a new instance of InvestecOpenApi::Models::Account with attributes" do
        model_instance = InvestecOpenApi::Models::Account.from_api({
          "accountId" => "12345",
          "accountNumber" => "67890",
          "accountName" => "Test User",
          "referenceName" => "Savings Account",
          "productName" => "Private Bank Account",
          "kycCompliant" => true,
          "profileId" => "12345",
          "profileName" => "Test User"
        })

        expect(model_instance.id).to eq "12345"
        expect(model_instance.number).to eq "67890"
        expect(model_instance.name).to eq "Test User"
        expect(model_instance.reference_name).to eq "Savings Account"
        expect(model_instance.product_name).to eq "Private Bank Account"
        expect(model_instance.kyc_compliant).to eq true
        expect(model_instance.profile_id).to eq "12345"
        expect(model_instance.profile_name).to eq "Test User"
      end
    end

    context "with valid and invalid attributes" do
      it "ignores invalid attributes and returns a new instance with only valid attributes" do
        model_instance = InvestecOpenApi::Models::Account.from_api({
          "accountId" => "12345",
          "bankAccountNumber" => "67890"  # Assuming 'bankAccountNumber' is not a valid attribute
        })

        expect(model_instance.id).to eq "12345"
        expect(model_instance.number).to be_nil  # 'number' is not set in the provided params
        expect(model_instance.name).to be_nil  # 'name' is not set in the provided params

        # Since we are using Struct, trying to access an undefined attribute will raise a NoMethodError
        expect { model_instance.bank_account_number }.to raise_error(NoMethodError)
      end
    end
  end
end
