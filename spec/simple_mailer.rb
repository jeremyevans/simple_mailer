#!/usr/bin/env spec
require File.join(File.dirname(File.dirname(__FILE__)), '/lib/simple_mailer')
Object.send(:remove_const, :Net)

$message = [nil, nil, nil]
module Net
  class SMTP
    class Mock
      def initialize(host)
        @host = host
      end
      def send_message(msg, from, to)
        $message = [msg, from, to, @host]
      end
    end
    def self.start(host, *args)
      yield(Mock.new(host))
    end
  end
end

shared_examples_for "simple_mailer" do
  before do
    $message = [nil, nil, nil]
  end

  it "should sent email" do
    @mailer.send_email('from1@from.com', 'to1@to.com', 'Test Subject 1', 'Test Body 1')
    $message.should == [<<END_MESSAGE, 'from1@from.com', 'to1@to.com', 'localhost']
From: from1@from.com
To: to1@to.com
Subject: Test Subject 1

Test Body 1
END_MESSAGE
  end

  it "should allow the setting of headers" do
    @mailer.send_email('from2@from.com', 'to2@to.com', 'Test Subject 2', 'Test Body 2', 'HeaderKey2'=>'HeaderValue2')
    $message.should == [<<END_MESSAGE, 'from2@from.com', 'to2@to.com', 'localhost']
From: from2@from.com
To: to2@to.com
Subject: Test Subject 2
HeaderKey2: HeaderValue2

Test Body 2
END_MESSAGE
  end

  it "should recognize the special :cc header" do
    @mailer.send_email('from3@from.com', 'to3@to.com', 'Test Subject 3', 'Test Body 3', :cc=>'cc3@to.com')
    $message.should == [<<END_MESSAGE, 'from3@from.com', ['to3@to.com', 'cc3@to.com'], 'localhost']
From: from3@from.com
To: to3@to.com
Subject: Test Subject 3
CC: cc3@to.com

Test Body 3
END_MESSAGE
  end

  it "should recognize the special :bcc header" do
    @mailer.send_email('from3@from.com', 'to3@to.com', 'Test Subject 3', 'Test Body 3', :bcc=>'cc3@to.com')
    $message.should == [<<END_MESSAGE, 'from3@from.com', ['to3@to.com', 'cc3@to.com'], 'localhost']
From: from3@from.com
To: to3@to.com
Subject: Test Subject 3

Test Body 3
END_MESSAGE
  end

  it "should recognize the special :smtp_from and :smtp_to headers" do
    @mailer.send_email('from3@from.com', 'to3@to.com', 'Test Subject 3', 'Test Body 3', 'HeaderKey3'=>'HeaderValue3', :smtp_from=>'from@to.com', :smtp_to=>'to@from.com')
    $message.should == [<<END_MESSAGE, 'from@to.com', 'to@from.com', 'localhost']
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
    h.should == {:smtp_to=>'to@to.com'}
  end

  it "should allow the setting of smtp server" do
    @mailer.smtp_server = 'blah.com'
    @mailer.send_email('from1@from.com', 'to1@to.com', 'Test Subject 1', 'Test Body 1')
    $message.should == [<<END_MESSAGE, 'from1@from.com', 'to1@to.com', 'blah.com']
From: from1@from.com
To: to1@to.com
Subject: Test Subject 1

Test Body 1
END_MESSAGE
  end

  it "should not send emails in test mode" do
    SimpleMailer.test_mode!
    @mailer.send_email('from3@from.com', 'to3@to.com', 'Test Subject 3', 'Test Body 3', 'HeaderKey3'=>'HeaderValue3', :smtp_from=>'from@to.com', :smtp_to=>'to@from.com')
    $message.should == [nil, nil, nil]
  end

  it "should record emails sent to emails_sent in test mode" do
    SimpleMailer.test_mode!
    @mailer.send_email('from3@from.com', 'to3@to.com', 'Test Subject 3', 'Test Body 3', 'HeaderKey3'=>'HeaderValue3', :smtp_from=>'from@to.com', :smtp_to=>'to@from.com')
    @mailer.emails_sent.should == [[<<END_MESSAGE, 'from@to.com', 'to@from.com']]
From: from3@from.com
To: to3@to.com
Subject: Test Subject 3
HeaderKey3: HeaderValue3

Test Body 3
END_MESSAGE
    SimpleMailer.instance_variable_set(:@test_mode, false)
  end
end

describe "SimpleMailer module itself" do
  before{@mailer = SimpleMailer}
  it_should_behave_like "simple_mailer"
end

describe "Class including SimpleMailer" do
  before{@mailer = Class.new{include SimpleMailer}.new}
  it_should_behave_like "simple_mailer"
end
