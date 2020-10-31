require 'spec_helper'
describe 'fail2ban' do
  let(:title) { 'fail2ban' }
  let(:facts) { {
    # We still need the two following facts since the "init" provider to
    # service is still relying on them. For some reason tests use that provider
    # when running on travic.ci.
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',

    :os => {
      :family => 'Debian',
      :release => {
        :major => '10',
      },
    }
  } }

  it { should contain_class('fail2ban::install') }
  it { should contain_class('fail2ban::config') }
  it { should contain_class('fail2ban::service') }

end
