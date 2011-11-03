require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  test "should get registration page" do
    get :new
    assert_response :success
    assert_select 'form', /My Grinnell email is/
  end

  test "should create tentative account and send email" do
    ta = TentativeAccount.find_by_username "plans"
    assert_nil ta

    post :create, { :account => { 
        "username" => "plans", 
        "email_domain" => "grinnell.edu",
        "user_type" => "student"}}
    
    # confirm tentative account
    assert_select 'p', /was just sent to plans@grinnell.edu/
    ta = TentativeAccount.find_by_username "plans"
    assert_equal "plans@grinnell.edu", ta.email
    
    # verify confirmation email
    email = ActionMailer::Base.deliveries.first
    assert_equal 'Plan Activation Link', email.subject
    assert_equal 'plans@grinnell.edu', email.to[0]
    assert_match 'will expire in 24 hours', email.body
  end
  
  test "valid tentative account already exists" do
    ta = TentativeAccount.create( :username => 'plans',
                                  :user_type => 'student',
                                  :email => 'plans@plans.plans',
                                  :confirmation_token => 'PLAN9' )
    post :create, { :account => { :username => ta.username }}
    assert_select 'p', /A confirmation email has already been sent to #{ta.email}/
  end
  
  test "account already exists" do
    ta = TentativeAccount.create( :username => 'plans',
                                  :user_type => 'student',
                                  :email => 'plan@plans.plans' )
    account = Account.create_new ta
    assert_not_nil account
    post :create, { :account => { "username" => "plans" }}
    assert_select 'p', /A plan already exists for this Grinnellian/
  end
  
  test "expired tentative is cleared on create" do
    past_time = Time.now - 2.days
    ta = TentativeAccount.create( :username => 'plans',
                                  :user_type => 'student',
                                  :email => 'plans@plans.plans',
                                  :confirmation_token => 'PLAN9',
                                  :created_at => past_time,
                                  :updated_at => past_time )
    assert_not_nil ta
    post :create, { :account => { 
        "username" => "plans", 
        "email_domain" => "plans.plans",
        "user_type" => "student"}}
    
    assert_select 'p', /was just sent to plans@plans.plans/
    ta = TentativeAccount.find_by_username 'plans'
    assert_operator past_time, :<, ta.created_at
  end

  test "confirm account successfully" do
    ta = TentativeAccount.create( :username => 'plans',
                                  :user_type => 'student',
                                  :email => 'plans@plans.plans',
                                  :confirmation_token => 'PLAN9' )

    account = Account.find_by_username ta.username
    assert_nil account

    get :confirm, { :token => 'PLAN9' }
    assert_select 'p', /Thank you for confirming your email/

    # verify account
    account = Account.find_by_username 'plans'
    assert_not_nil account
    assert_equal ta.email, account.email
    
    # verify welcome email
    email = ActionMailer::Base.deliveries.first
    assert_equal 'Plan Created', email.subject
    assert_equal 'plans@plans.plans', email.to[0]
    assert_match 'Your Plan has been created!', email.body
    assert_match 'password', email.body
  end
  
  test "confirm with expired tentative account" do
    ta = TentativeAccount.create( :username => 'plans',
                                  :user_type => 'student',
                                  :email => 'plans@plans.plans',
                                  :confirmation_token => 'PLAN9',
                                  :created_at => Time.now - 2.days,
                                  :updated_at => Time.now - 2.days )
    get :confirm, { :token => 'PLAN9' }
    assert_redirected_to :controller => 'accounts', :action => 'new' 
  end

  test "confirm with wrong token" do
    get :confirm, { :token => 'SHOO' }
    assert_redirected_to :controller => 'accounts', :action => 'new' 
  end
  
  test "resend confirmation email" do
    ta = TentativeAccount.create( :username => 'plans',
                                  :user_type => 'student',
                                  :email => 'plans@plans.plans',
                                  :confirmation_token => 'PLAN9' )
    post :resend_confirmation_email, { :username => 'plans' }
    
    # verify confirmation email
    email = ActionMailer::Base.deliveries.first
    assert_equal 'Plan Activation Link', email.subject
    assert_equal ta.email, email.to[0]
    assert_match 'will expire in 24 hours', email.body
  end
end