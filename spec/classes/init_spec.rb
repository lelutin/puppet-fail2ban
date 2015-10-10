require 'spec_helper'
describe 'fail2ban' do

  context 'with defaults for all parameters' do
    it { should contain_class('fail2ban') }
  end
end
