class Notifier < ActionMailer::Base
  
  default :from => "no-reply@grinnellplans.com"
  
  def confirm username, email, token
    @username = username
    @token = token
    mail :to => email, :subject => "Plan Activation Link"
  end
  
end