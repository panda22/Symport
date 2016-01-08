class MailSender
  class << self
    def send(mail)
      t = Thread.new do
        mail.deliver
      end
      at_exit{ t.join }
    end
  end
end