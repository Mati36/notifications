#:title, :type, :format, :visibility, :path, :created_at
require File.expand_path '../test_helper.rb', __dir__

class UserTest < MiniTest::Unit::TestCase
  MiniTest::Unit::TestCase
  def test_title_presence
    @doc = Document.create(title: 'NuevoDoc', type: 'Act', format: '.pdf', visibility: true, path: '/files/1.jpeg', created_at: '2020-05-23 03:29:15')
    assert_equal @user.valid?, true
  end

  def test_title_presence
    @doc = Document.new(title: '', type: 'Act', format: '.pdf', visibility: true, path: '/files/1.jpeg', created_at: '2020-05-23 03:29:15')
    assert_equal @user.valid?, false
  end

  def test_title_presence
    @doc = Document.new(type: 'Act', format: '.pdf', visibility: true, path: '/files/1.jpeg', created_at: '2020-05-23 03:29:15')
    assert_equal @user.valid?, false
  end

  def test_type_presence
    @doc = Document.new(title: 'NuevoDoc', type: '', format: '.pdf', visibility: true, path: '/files/1.jpeg', created_at: '2020-05-23 03:29:15')
    assert_equal @user.valid?, false
  end

  def test_type_presence
    @doc = Document.new(title: 'NuevoDoc', type: 'act', format: '', visibility: true, path: '/files/1.jpeg', created_at: '2020-05-23 03:29:15')
    assert_equal @user.valid?, false
  end

  def test_format_presence
    @doc = Document.new(title: 'NuevoDoc', type: 'act', format: '', visibility: true, path: '/files/1.jpeg', created_at: '2020-05-23 03:29:15')
    assert_equal @user.valid?, false
  end

  def test_format_presence
    @doc = Document.new(title: 'NuevoDoc', type: 'act', visibility: true, path: '/files/1.jpeg', created_at: '2020-05-23 03:29:15')
    assert_equal @user.valid?, false
  end

  def test_visibility_presence
    @doc = Document.new(title: 'NuevoDoc', type: 'act', format: '.pdf', visibility: '', path: '/files/1.jpeg', created_at: '2020-05-23 03:29:15')
    assert_equal @user.valid?, false
  end

  def test_visibility_presence
    @doc = Document.new(title: 'NuevoDoc', type: 'act', format: '.pdf', path: '/files/1.jpeg', created_at: '2020-05-23 03:29:15')
    assert_equal @user.valid?, false
  end

  def test_path_presence
    @doc = Document.new(title: 'NuevoDoc', type: 'act', format: '.pdf', visibility: true, path: '', created_at: '2020-05-23 03:29:15')
    assert_equal @user.valid?, false
  end

  def test_path_presence
    @doc = Document.new(title: 'NuevoDoc', type: 'act', format: '.pdf', visibility: true, created_at: '2020-05-23 03:29:15')
    assert_equal @user.valid?, false
  end

  def test_date_presence
    @doc = Document.new(title: 'NuevoDoc', type: 'act', format: '.pdf', visibility: true, path: '/files/1.jpeg', created_at: '')
    assert_equal @user.valid?, false
  end

  def test_date_presence
    @doc = Document.new(title: 'NuevoDoc', type: 'act', format: '.pdf', visibility: true, path: '/files/1.jpeg')
    assert_equal @user.valid?, false
  end
end
