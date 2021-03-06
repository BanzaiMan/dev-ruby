# coding: utf-8
require 'test_helper'
require 'blade.rb'

{
  "test/data/index.shtml" =>
    "http://blade.nagaokaut.ac.jp/ruby/ruby-dev/index.shtml",
  "test/data/42801-43000.html" =>
    "http://blade.nagaokaut.ac.jp/ruby/ruby-dev/42801-43000.shtml",
}.merge(
  {}.tap{|h|
    Dir.entries("test/data/").
        select{|path| path =~ /\A\d+\.html/}.
        each{|path|
          h["test/data/#{path}"] = "http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-dev/#{path[/\d+/]}"
    }
  }
).each{|file, url|
  FakeWeb.register_uri(:get, url, :body => File.read(file))
}

Blade.verbose = false

class BladeTest < ActiveSupport::TestCase
  test "Blade.new creates an instance" do
    assert_instance_of Blade, Blade.new(42900)
  end

  test "Blade#get downloads the html" do
    html = Blade.new(42900).get
    assert_equal html.encoding, Encoding.find("utf-8")
    assert_match html, /チケット/
  end

  test "Blade#parse returns a hash" do
    data = Blade.new(42900).parse

    assert_equal data[:number], 42900
    assert_equal data[:subject], "[Ruby 1.9-Bug#4152][Closed] optparseのzsh compsysでrspecの補完が出来ない"
    assert_equal data[:from], "Anonymous <redmine ruby-lang.org>"
    assert_equal data[:time], ActiveSupport::TimeZone["Tokyo"].local(2010, 12, 27, 8, 37, 11)
    assert_equal data[:in_reply_to], nil
    assert_equal data[:body], "チケット #4152 が更新されました。 (by Anonymous)\n\nステータス AssignedからClosedに変更\n進捗 % 0から100に変更\n\nThis issue was solved with changeset r30394.\nKazuhiro, thank you for reporting this issue.\nYour contribution to Ruby is greatly appreciated.\nMay Ruby be with you.\n\n----------------------------------------\nhttp://redmine.ruby-lang.org/issues/show/4152\n\n----------------------------------------\nhttp://redmine.ruby-lang.org\n\n"
  end

  test "Blade#create creates a Post" do
    assert_difference "Post.count", 1 do
      Blade.new(42900).create
    end
  end

  test "Blade#latest_index_url" do
    assert_equal Blade.latest_index_url, "http://blade.nagaokaut.ac.jp/ruby/ruby-dev/42801-43000.shtml#latest"
  end

  test "Blade#latest_number returns the latest mail number" do
    assert_equal 42969, Blade.latest_number
  end

  test "Blade should add in_reply_to according to RedMine ticket number" do
    Blade.new(42897).create
    assert_equal 42897, Blade.new(42899).parse[:in_reply_to]
    Blade.new(42895).create
    assert_equal 42895, Blade.new(42900).parse[:in_reply_to]
  end

  test "Blade should use blade's [parent] instead of In-reply-to" do
    assert_equal 42928, Blade.new(42929).parse[:in_reply_to]
  end

  test "Blade should parse ruby-dev:42915, 43039, etc" do
    assert_nothing_raised do
      Blade.new(42915).create
      Blade.new(43039).create # contains broken EUC-JP
      Blade.new(43065).create # contains broken EUC-JP
    end
    post = Blade.new(41447).post
    p post
    assert post.valid?
  end

end
