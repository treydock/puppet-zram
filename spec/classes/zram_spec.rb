require 'spec_helper'

describe 'zram' do
  include_context :default_facts

  let :facts do
    default_facts
  end

  it { should create_class('zram') }
  it { should contain_class('zram::params') }

end
