class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEVISE_MAILER_SENDER", "noreply@kajimate.com")
  layout "mailer"
end
