require 'test_helper'
require 'tftp/tftp/tftp_plugin'
require "tftp/tftp/tftp"

class TftpTest < Test::Unit::TestCase
  def setup
    @tftp = Proxy::TFTP::Tftp.new
  end

  def test_should_have_a_logger
    assert_respond_to @tftp, :logger
  end

  def test_path_to_tftp_directory_without_tftproot_setting
    assert_equal Pathname.new(__FILE__).join("..", "..", "..", "modules","tftp","tftp","tftpboot").to_s, @tftp.send(:path)
  end

  def test_path_to_tftp_directory_with_tftproot_setting
    Proxy::TftpPlugin.settings.stubs(:tftproot).returns("/some/tftp/root")
    assert_equal Proxy::TftpPlugin.settings.tftproot, @tftp.send(:path)
  end

  def test_path_to_tftp_directory_with_relative_tftproot_setting
    Proxy::TftpPlugin.settings.stubs(:tftproot).returns("./some/root")
    assert_equal Pathname.new(__FILE__).join("..", "..", "..", "modules","tftp","tftp","some","root").to_s, @tftp.send(:path)
  end
end
