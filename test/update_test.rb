require_relative "test_helper"

class UpdateTest < MiniTest::Unit::TestCase

  include TestHelper

  def test_140_limit
    u = Update.new(:text => "This is a long update. This is a long update. This is a long update. This is a long update. This is a long update. This is a long update. jklol")
    refute u.save, "I made an update with over 140 characters"
  end

  def test_at_replies_with_not_existing_user
    u = Update.new(:text => "This is a message mentioning @steveklabnik.")
    assert_match "This is a message mentioning @steveklabnik.", u.to_html
  end

  def test_at_replies_with_existing_user
    Factory(:user, :username => "steveklabnik")
    u = Update.new(:text => "This is a message mentioning @SteveKlabnik.")
    assert_match /<a href='\/users\/steveklabnik'>@SteveKlabnik<\/a>/, u.to_html
  end

  def test_at_replies
    Factory(:user, :username => "steveklabnik")
    Factory(:user, :username => "bar")
    u = Update.new(:text => "@SteveKlabnik @nobody foo@bar.wadus @SteveKlabnik")
    assert_match "<a href='\/users\/steveklabnik'>@SteveKlabnik<\/a> @nobody foo@bar.wadus <a href='\/users\/steveklabnik'>@SteveKlabnik<\/a>", u.to_html
  end

  def test_links
    u = Update.new(:text => "This is a message mentioning http://rstat.us/.")
    assert_match /<a href='http:\/\/rstat.us\/'>http:\/\/rstat.us\/<\/a>/, u.to_html
    u = Update.new(:text => "https://github.com/hotsh/rstat.us/issues#issue/11")
    assert_equal "<a href='https://github.com/hotsh/rstat.us/issues#issue/11'>https://github.com/hotsh/rstat.us/issues#issue/11</a>", u.to_html
  end

  def test_edgecase_links
    edgecase = <<-EDGECASE
      Not perfect, but until there's an API, you can quick add text to your status using
      links like this: http://rstat.us/?status={status}
    EDGECASE
    u = Update.new(:text => edgecase)
    assert_match "<a href='http://rstat.us/?status={status}'>http://rstat.us/?status={status}</a>", u.to_html
  end

  def test_hashtags
    u = Update.new(:text => "This is a message with a #hashtag.")
    assert_match /<a href='\/hashtags\/hashtag'>#hashtag<\/a>/, u.to_html
    u = Update.new(:text => "This is a message with a#hashtag.")
    assert_equal "This is a message with a#hashtag.", u.to_html
  end

end
