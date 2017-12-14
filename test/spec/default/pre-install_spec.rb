# frozen_string_literal: true
require 'spec_helper'

describe 'partitions' do
  let(:fdisk_list) { command('sudo fdisk -l').stdout.split("\n") }

  describe '/dev/sda1' do
    let(:dev_sda_1_row) do
      fdisk_list.select { |line| /sda1/.match(line) }&.first
    end

    it 'must be present' do
      expect(dev_sda_1_row)
        .to_not be nil
    end

    it 'must have the bootable flag' do
      expect(dev_sda_1_row)
        .to match(Regexp.new('/dev/sda1.*\*'))
    end

    it 'must be small' do
      size = dev_sda_1_row.split(/\s+/)[5].tr('M', '').to_i
      expect(size)
        .to be < 350
    end
  end
end
