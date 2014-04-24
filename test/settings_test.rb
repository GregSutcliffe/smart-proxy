require 'test_helper'

class SettingsTest < Test::Unit::TestCase
  def test_user_values_override_default_ones
    tested = Settings.load({:key => 'value'}, {:key => 'default_value'})
    assert_equal 'value', tested.key
  end
end
