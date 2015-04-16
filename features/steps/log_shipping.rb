require 'rspec/expectations'

# Step definition for the log shipping feature.
class Spinach::Features::LogShipping < Spinach::FeatureSteps
  step 'a configured machine' do
    @machine = TestMachine.new
    @machine.configure
    @conjur = MockConjur.new
    @machine.launch @conjur.id
    sleep 3 # to settle
  end

  step 'a user logs in' do
    @machine.ssh
    sleep 1
  end

  step 'an audit record is created' do
    expect(@conjur.audits).to include include 'action' => 'login'
  end
end
