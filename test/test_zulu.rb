require 'minitest_helper'

class TestZulu < MiniTest::Test
  def setup
    Zulu.options = nil
  end
  
  def test_it_has_version_number
    refute_nil ::Zulu::VERSION
  end
  
  # 
  # Zulu.parse_options
  # 
  
  def test_it_has_default_option_for_port
    assert_equal 9292, Zulu.options[:port]
  end
  
  def test_it_has_default_option_for_host
    assert_equal '0.0.0.0', Zulu.options[:host]
  end
  
  def test_it_has_default_option_for_servers
    assert_equal 0, Zulu.options[:servers]
  end
  
  def test_it_has_default_option_for_workers
    assert_equal 5, Zulu.options[:workers]
  end
  
  def test_it_has_default_option_for_database
    assert_equal 'localhost:6379', Zulu.options[:database]
  end
  
  def test_it_has_default_option_for_keeper
    deny Zulu.options[:keeper]
  end
  
  def test_it_accepts_option_for_port
    Zulu.parse_options(['-p 3000'])
    assert_equal 3000, Zulu.options[:port]
  end
  
  def test_it_accepts_option_for_host
    Zulu.parse_options(['-o 127.0.0.1'])
    assert_equal '127.0.0.1', Zulu.options[:host]
  end
  
  def test_it_accepts_option_for_servers
    Zulu.parse_options(['-s 7'])
    assert_equal 7, Zulu.options[:servers]
  end
  
  def test_it_accepts_option_for_workers
    Zulu.parse_options(['-w 7'])
    assert_equal 7, Zulu.options[:workers]
  end
  
  def test_it_accepts_option_for_database
    Zulu.parse_options(['-d localhost:9000'])
    assert_equal 'localhost:9000', Zulu.options[:database]
  end
  
  def test_it_accepts_option_for_keeper
    Zulu.parse_options(['-k'])
    assert Zulu.options[:keeper]
  end
  
  def test_it_aborts_on_option_with_missing_arg
    assert_raises(SystemExit) do
      out, err = capture_io { Zulu.parse_options(['-p']) }
      assert_match /ERROR:/, err
    end
  end
  
  # 
  # Zulu.run
  # 
  
end
