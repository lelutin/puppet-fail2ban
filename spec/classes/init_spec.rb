require 'spec_helper'
describe 'fail2ban' do
  let(:title) { 'fail2ban' }
  let(:facts) { {
    :osfamily => 'Debian',
  } }

  it { should contain_class('fail2ban::install') }
  it { should contain_class('fail2ban::config') }
  it { should contain_class('fail2ban::service') }

end
