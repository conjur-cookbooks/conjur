# Step definition for the log shipping feature.
class Spinach::Features::LogShipping < Spinach::FeatureSteps
  step 'a configured machine' do
    @machine = TestMachine.new
    @machine.configure
    @machine.launch
  end

  step 'a user logs in' do
    pending 'step not implemented'
  end

  step 'an audit record is created' do
    pending 'step not implemented'
  end
end
