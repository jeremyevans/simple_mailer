require 'net/smtp'

# SimpleMailer is a very small class that uses net/smtp to sent email messages
# to a given smtp server (localhost by default).  Like the name implies, it
# is very simple, you provide a from address, to address, subject, body and
# an optional hash of headers.
#
# The main advantage of this over just using Net::SMTP directly is that
# it handles headers and it has a test mode that just records the number of
# emails sent instead of actually sending the messages.
module SimpleMailer
  @test_mode = false
  @emails_sent = []

  extend self

  DEFAULT_SMTP_HOST = 'localhost'.freeze

  # The array of emails sent
  def self.emails_sent
    @emails_sent
  end

  # Turn on the test mode.  There is no method given to turn it off.
  # While in test mode, messages will not be sent, but the messages
  # that would have been sent are available via emails_sent.
  # This method also resets the emails_sent variable to the empty array.
  def self.test_mode!
    @emails_sent.clear
    @test_mode = true
  end
  
  # Whether we are in simple mailer's test mode
  def self.test_mode?
    @test_mode
  end

  # The smtp server to sent email to
  attr_accessor :smtp_server
  
  # The emails sent in test mode.  Is an array of arrays.  Each
  # element array is a array of three elements, the message, from address,
  # and to address.
  def emails_sent
    SimpleMailer.emails_sent
  end

  # Formats email message using from address, to address, subject, message,
  # and header hash.  Arguments:
  # * from - From address for the message
  # * to - To address for the message (string or array of strings)
  # * subject - Subject of the message
  # * message - Body of the message
  # * headers - Headers for the message. Also, handles the following keys
  #   specially:
  #   * :smtp_from - the SMTP MAIL FROM address to use.  Uses the value of
  #     of the from argument by default.
  #   * :smtp_to - the SMTP RCPT TO address to use.  Uses the value of the
  #     to argument by default.
  #
  # The caller is responsible for ensuring that the from, to, subject, and
  # headers do not have an carriage returns or line endings.  Otherwise,
  # it's possible to inject arbitrary headers or body content.
  def send_email(from, to, subject, message, headers={})
    smtp_from = headers.delete(:smtp_from) || from
    smtp_to = headers.delete(:smtp_to) || to
    to = to.join(", ") if to.is_a?(Array)
    _send_email(<<END_OF_MESSAGE, smtp_from, smtp_to)
From: #{from}
To: #{to}
Subject: #{subject}
#{headers.sort.map{|k,v| "#{k}: #{v}"}.join("\n")}#{"\n" unless headers.empty?}
#{message}
END_OF_MESSAGE
  end
  
  private

  # If in test mode, call test_mode_send_email with the arguments.
  # Otherwise, use net/smtp to send the message to the smtp server.
  def _send_email(msg, from, to)
    if SimpleMailer.test_mode?
      test_mode_send_email(msg, from, to)
    else
      Net::SMTP.start(smtp_server || DEFAULT_SMTP_HOST){|s| s.send_message(msg, from, to)}
    end
  end

  # Handle the message in test mode. By default just adds it to the emails_sent
  # array.  
  def test_mode_send_email(msg, from, to)
    emails_sent << [msg, from, to]
  end
end
