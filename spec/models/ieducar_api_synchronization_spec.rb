require 'rails_helper'

RSpec.describe IeducarApiSynchronization, :type => :model do
  context "Associations" do
    it { should belong_to :ieducar_api_configuration }
    it { should belong_to :author }
  end

  context "Validations" do
    it { should validate_presence_of :ieducar_api_configuration }
  end

  describe "#mark_as_error!" do
    it "should mark synchronization as error and set the error message" do
      message = double

      expect(subject).to receive(:update_columns).with(
        status: ApiSynchronizationStatus::ERROR,
        error_message: message
      )

      subject.mark_as_error!(message)
    end
  end

  describe "#mark_as_completed!" do
    it "should mark synchronization as completed" do
      message = double

      expect(subject).to receive(:update_column).with(:status, ApiSynchronizationStatus::COMPLETED)

      subject.mark_as_completed!
    end
  end

  describe "#notified!" do
    it "marks synchronization as notified" do
      expect(subject).to receive(:update_column).with(:notified, true)

      subject.notified!
    end
  end
end