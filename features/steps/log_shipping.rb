require 'rspec/expectations'

# Step definition for the log shipping feature.
class Spinach::Features::LogShipping < Spinach::FeatureSteps
  step 'a configured machine' do
    @machine = TestMachine.new
    @machine.configure
    @conjur = MockConjur.new
    @machine.launch @conjur.id
  end

  step 'a user logs in' do
    keep_trying do
      @machine.ssh
    end
  end

  step 'an audit record is created' do
    keep_trying do
      expect(@conjur.audits).to include include 'action' => 'login'
    end
  end

  # tries the block once a second up to max_tries
  def keep_trying max_tries = 5
    loop do
      begin
        yield
        break
      rescue Exception
        max_tries -= 1
        sleep 1
        raise if max_tries == 0
      end
    end
  end
end
