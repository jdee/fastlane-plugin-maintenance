describe Fastlane::Actions::MaintenanceAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The maintenance plugin is working!")

      Fastlane::Actions::MaintenanceAction.run(nil)
    end
  end
end
