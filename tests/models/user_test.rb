require File.expand_path '../../test_helper.rb', __FILE__

class UserTest < MiniTest::Unit::TestCase

  MiniTest::Unit::TestCase    
  def test_name_presence
    @user = User.create(name: 'Facundo', lastname: 'Fernandez', dni: 41593885, email: 'ff@gmail.com', password: '123')
    assert_equal @user.valid?, true
  end  

  def test_name_presence
    @user = User.new(name: '', lastname: 'Fernandez', dni: 41593885, email: 'ff@gmail.com', password: '123')
    assert_equal @user.valid?, false
  end

  def test_name_presence
    @user = User.new(lastname: 'Fernandez', dni: 41593885, email: 'ff@gmail.com', password: '123')
    assert_equal @user.valid?, false
  end

  def test_lastname_presence
    @user = User.new(name: 'Facundo', lastname: '', dni: 41593885, email: 'ff@gmail.com', password: '123')
    assert_equal @user.valid?, false
  end

  def test_lastname_presence
    @user = User.new(name: 'Facundo', dni: 41593885, email: 'ff@gmail.com', password: '123')
    assert_equal @user.valid?, false
  end

  def test_dni_presence
    @user = User.new(name: 'Facundo', lastname: 'Fernandez', dni: '', email: 'ff@gmail.com', password: '123')
    assert_equal @user.valid?, false
  end

  def test_dni_presence
    @user = User.new(name: 'Facundo', lastname: 'Fernandez', email: 'ff@gmail.com', password: '123')
    assert_equal @user.valid?, false
  end

  def test_email_presence
    @user = User.new(name: 'Facundo', lastname: 'Fernandez', dni: 41593885, email: '', password: '123')
    assert_equal @user.valid?, false
  end

  def test_email_presence
    @user = User.new(name: 'Facundo', lastname: 'Fernandez', dni: 41593885, password: '123')
    assert_equal @user.valid?, false
  end
  
  def test_dni_type
    @user = User.new(name: 'Facundo', lastname: 'Fernandez', dni: "abc", email: 'ff@gmail.com', password: '123')
    assert_equal (@user.dni.is_a? Numeric), false
  end  

  def test_email_format
    @user = User.new(name: 'Facundo', lastname: 'Fernandez', dni: 41593885, email: 'ffgmail.com', password: '123')
    assert_equal @user.valid?, false
  end  
end 