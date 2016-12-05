require File.join(File.dirname(File.dirname(__FILE__)), '/lib/simple_mailer')
Object.send(:remove_const, :Net)

gem 'minitest'
require 'minitest/autorun'

$message = [nil, nil, nil]
module Net
  class SMTP
    attr_reader :address, :port, :domain, :user_name, :password, :authentication,
      :starttls_auto, :tls

    def initialize(address, port = nil)
      @address, @port = address, port
    end

    def enable_starttls_auto
      @starttls_auto = true
    end

    def enable_tls
      @tls = true
    end

    def start(domain = nil, user_name = nil, password = nil, authentication = nil)
      @domain, @user_name, @password, @authentication = domain, user_name, password, authentication
      yield self
    end

    def send_message(msg, from, to)
      $message = [msg, from, to, @address]
      self
    end
  end
end

module SimpleMailerSpecs
  extend Minitest::Spec::DSL

  before do
    $message = [nil, nil, nil]
  end
  after do
    @mailer.smtp_server = nil
    @mailer.instance_variable_set(:@smtp_settings, nil)
    SimpleMailer.instance_variable_set(:@test_mode, false)
  end

  it "should send email" do
    @mailer.send_email('from1@from.com', 'to1@to.com', 'Test Subject 1', 'Test Body 1')
    $message.must_equal [<<END_MESSAGE, 'from1@from.com', 'to1@to.com', 'localhost']
From: from1@from.com
To: to1@to.com
Subject: Test Subject 1

Test Body 1
END_MESSAGE
  end

  it "should allow the setting of headers" do
    @mailer.send_email('from2@from.com', 'to2@to.com', 'Test Subject 2', 'Test Body 2', 'HeaderKey2'=>'HeaderValue2')
    $message.must_equal [<<END_MESSAGE, 'from2@from.com', 'to2@to.com', 'localhost']
From: from2@from.com
To: to2@to.com
Subject: Test Subject 2
HeaderKey2: HeaderValue2

Test Body 2
END_MESSAGE
  end

  it "should recognize the special :cc header" do
    @mailer.send_email('from3@from.com', 'to3@to.com', 'Test Subject 3', 'Test Body 3', :cc=>'cc3@to.com')
    $message.must_equal [<<END_MESSAGE, 'from3@from.com', ['to3@to.com', 'cc3@to.com'], 'localhost']
From: from3@from.com
To: to3@to.com
Subject: Test Subject 3
CC: cc3@to.com

Test Body 3
END_MESSAGE
  end

  it "should recognize the special :bcc header" do
    @mailer.send_email('from3@from.com', 'to3@to.com', 'Test Subject 3', 'Test Body 3', :bcc=>'cc3@to.com')
    $message.must_equal [<<END_MESSAGE, 'from3@from.com', ['to3@to.com', 'cc3@to.com'], 'localhost']
From: from3@from.com
To: to3@to.com
Subject: Test Subject 3

Test Body 3
END_MESSAGE
  end

  it "should recognize the special :smtp_from and :smtp_to headers" do
    @mailer.send_email('from3@from.com', 'to3@to.com', 'Test Subject 3', 'Test Body 3', 'HeaderKey3'=>'HeaderValue3', :smtp_from=>'from@to.com', :smtp_to=>'to@from.com')
    $message.must_equal [<<END_MESSAGE, 'from@to.com', 'to@from.com', 'localhost']
From: from3@from.com
To: to3@to.com
Subject: Test Subject 3
HeaderKey3: HeaderValue3

Test Body 3
END_MESSAGE
  end

  it "should not modify input hash" do
    h = {:smtp_to=>'to@to.com'}
    @mailer.send_email('from3@from.com', 'to3@to.com', 'Test Subject 3', 'Test Body 3', h)
    h.must_equal(:smtp_to=>'to@to.com')
  end

  it "should allow the setting of smtp server" do
    @mailer.smtp_server = 'blah.com'
    @mailer.send_email('from1@from.com', 'to1@to.com', 'Test Subject 1', 'Test Body 1')
    $message.must_equal [<<END_MESSAGE, 'from1@from.com', 'to1@to.com', 'blah.com']
From: from1@from.com
To: to1@to.com
Subject: Test Subject 1

Test Body 1
END_MESSAGE
  end

  it "should not send emails in test mode" do
    SimpleMailer.test_mode!
    @mailer.send_email('from3@from.com', 'to3@to.com', 'Test Subject 3', 'Test Body 3', 'HeaderKey3'=>'HeaderValue3', :smtp_from=>'from@to.com', :smtp_to=>'to@from.com')
    $message.must_equal [nil, nil, nil]
  end

  it "should record emails sent to emails_sent in test mode" do
    SimpleMailer.test_mode!
    @mailer.send_email('from3@from.com', 'to3@to.com', 'Test Subject 3', 'Test Body 3', 'HeaderKey3'=>'HeaderValue3', :smtp_from=>'from@to.com', :smtp_to=>'to@from.com')
    @mailer.emails_sent.must_equal [[<<END_MESSAGE, 'from@to.com', 'to@from.com']]
From: from3@from.com
To: to3@to.com
Subject: Test Subject 3
HeaderKey3: HeaderValue3

Test Body 3
END_MESSAGE
    SimpleMailer.instance_variable_set(:@test_mode, false)
  end

  it "should give proper default smtp settings" do
    @mailer.send(:smtp).address.must_equal 'localhost'
    @mailer.send(:smtp).port.must_equal 25
    @mailer.send(:smtp).starttls_auto.must_equal true

    smtp = @mailer.send_email('from@from.com', 'to@to.com', 'Test Subject', 'Test Body')
    smtp.domain.must_equal 'localhost'
  end

  it "should take smtp_server as the address" do
    @mailer.smtp_server = 'blah.com'
    @mailer.send(:smtp).address.must_equal 'blah.com'
  end

  it "should have configurable smtp settings" do
    @mailer.smtp_settings.update(
      :address              => 'smtp.gmail.com',
      :port                 => 587,
      :user_name            => 'bob',
      :password             => 'secret',
      :domain               => 'mydomain.com',
      :authentication       => :plain,
      :enable_starttls_auto => false,
      :tls                  => true
    )

    @mailer.send(:smtp).address.must_equal 'smtp.gmail.com'
    @mailer.send(:smtp).port.must_equal 587
    @mailer.send(:smtp).starttls_auto.must_be_nil
    @mailer.send(:smtp).tls.must_equal true

    smtp = @mailer.send_email('from@from.com', 'to@to.com', 'Test Subject', 'Test Body')
    smtp.domain.must_equal 'mydomain.com'
    smtp.user_name.must_equal 'bob'
    smtp.password.must_equal 'secret'
    smtp.authentication.must_equal :plain
  end
end

describe "SimpleMailer module itself" do
  before{@mailer = SimpleMailer}
  include SimpleMailerSpecs
end

describe "Class including SimpleMailer" do
  before{@mailer = Class.new{include SimpleMailer}.new}
  include SimpleMailerSpecs
end
