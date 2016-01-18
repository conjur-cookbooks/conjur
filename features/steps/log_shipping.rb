require 'rspec/expectations'

# Step definition for the log shipping feature.
class Spinach::Features::LogShipping < Spinach::FeatureSteps
  step 'a configured machine' do
    keep_trying 1 do
      @machine ||= TestMachine.new.tap(&:configure)
      @conjur ||= MockConjur.new
      @machine.launch @conjur.id
    end
  end

  step 'a user logs in' do
    sleep 1 # give a moment to settle
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
  def keep_trying max_tries = 32
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
