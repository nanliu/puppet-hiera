require 'spec_helper'
describe 'hiera', :type => :class do

  describe 'testing' do
    opensource = [ '2.7.10', '2.6.12']
    pe         = [ '2.7.6 (Puppet Enterprise 2.0.0)', '2.6.4 (Puppet Enterprise 1.0.0)' ]

    opensource.each do |version|
      describe "for puppet version #{version}" do
        let(:facts) { { :puppetversion => version } }

        let(:params) { { :confdir        => '/etc/puppet',
                         :modulepath     => '/etc/puppet/modules',
                         :install_method => 'pmt'
                     } }

        it { should include_class('hiera') }

        it 'should use gem provider for package' do
          should contain_package('hiera').with_provider('gem')
          should contain_package('hiera-puppet').with_provider('gem')
        end


        it do # 'should deploy hiera.yaml with correct permission' do
          should contain_file('/etc/puppet/hiera.yaml').with({
            'owner' => 'puppet',
            'group' => 'puppet'
          })
        end

        it { should contain_package('puppet-module') }
        it { should_not contain_package('git') }

        it 'should install hiera-puppet module' do
          should contain_exec('hiera-puppet').with({
            'command' => 'puppet-module install hiera-puppet'
          })
        end

      end
    end

    pe.each do |version|
      describe "for puppet version #{version}" do
        let(:facts) { { :puppetversion => version } }

        let(:params) { { :confdir => '/etc/puppetlabs/puppet',
                         :modulepath => '/etc/puppetlabs/puppet/modules' } }

        it { should include_class('hiera') }

        it "should use pe_gem provider for package" do
          should contain_package('hiera').with_provider('pe_gem')
          should contain_package('hiera-puppet').with_provider('pe_gem')
        end

        it 'should deploy hiera.yaml with correct permission' do
          should contain_file('/etc/puppetlabs/puppet/hiera.yaml').with({
            'owner' => 'puppet',
            'group' => 'pe-puppet'
          })
        end

        it { should_not contain_package('puppet-module') }
        it { should contain_package('git') }

        it 'should install hiera-puppet module' do
          should contain_exec('hiera-puppet').with({
            'command' => 'git clone git://github.com/puppetlabs/hiera-puppet'
          })
        end
      end
    end

  end
end
