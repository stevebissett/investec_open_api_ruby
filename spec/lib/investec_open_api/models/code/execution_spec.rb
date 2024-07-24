require "spec_helper"
require "investec_open_api/models/code/execution"

RSpec.describe InvestecOpenApi::Models::Code::Execution do
  describe "#from_api" do

    let(:precise_time_a) {  Time.iso8601("2024-04-14T13:18:38.201Z") }
    let(:precise_time_b) {  Time.iso8601("2024-04-14T13:18:38.501Z") }
    let(:precise_time_c) {  Time.iso8601("2024-04-14T13:18:38.801Z") }

    context "with valid attributes" do
      it "returns a new instance of InvestecOpenApi::Models::Code::Execution with attributes" do
        model_instance = InvestecOpenApi::Models::Code::Execution.from_api(
        {
            "executionId": "AABBCCDD-1234-1234-1234-12345ABCDEF",
            "rootCodeFunctionId": "AABBCCDD-1234-1234-1234-54321ABCDEF",
            "sandbox": false,
            "type": "before_transaction",
            "authorizationApproved": nil,
            "logs": [
                {
                    "createdAt": precise_time_b.iso8601(3),
                    "level": "info",
                    "content": "log content"
                }
            ],
            "smsCount": 0,
            "emailCount": 0,
            "pushNotificationCount": 0,
            "createdAt": precise_time_a.iso8601(3),
            "startedAt": precise_time_a.iso8601(3),
            "completedAt": precise_time_c.iso8601(3),
            "updatedAt": precise_time_a.iso8601(3)
        })

        expect(model_instance).to be_a InvestecOpenApi::Models::Code::Execution
        expect(model_instance.id).to eq "AABBCCDD-1234-1234-1234-12345ABCDEF"
        expect(model_instance.root_code_function_id).to eq "AABBCCDD-1234-1234-1234-54321ABCDEF"
        expect(model_instance.sandbox).to eq false
        expect(model_instance.type).to eq "before_transaction"
        expect(model_instance.authorization_approved).to eq nil
        expect(model_instance.logs.first).to be_a InvestecOpenApi::Models::Code::ExecutionLog
        expect(model_instance.logs.first.created_at).to eq precise_time_b
        expect(model_instance.logs.first.level).to eq 'info'
        expect(model_instance.logs.first.content).to eq 'log content'
        expect(model_instance.sms_count).to eq 0
        expect(model_instance.email_count).to eq 0
        expect(model_instance.push_notification_count).to eq 0
        expect(model_instance.created_at).to eq precise_time_a
        expect(model_instance.started_at).to eq precise_time_a
        expect(model_instance.completed_at).to eq precise_time_c
        expect(model_instance.updated_at).to eq precise_time_a

      end
    end
  end
end
