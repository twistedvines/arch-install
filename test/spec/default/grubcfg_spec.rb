# frozen_string_literal: true
require 'spec_helper'

describe 'grub config' do
  describe file '/boot/grub/grub.cfg' do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_mode 600 }
  end
end
