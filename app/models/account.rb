class Account < ActiveRecord::Base
  self.primary_key = :userid
  validates :username, :presence => true, :length =>{ :maximum => 16 }
  validates :password,  :length =>{ :maximum => 34 }
  validates :email, :length =>{ :maximum => 64 }
  validates :guest_password, :length =>{ :maximum => 64 }
  validates :show_images, :presence => true
  validates :user_type, :length =>{ :maximum => 128 }

  # validate :grad_year_for_user_type

  has_many :interests_in_others, :class_name => "Autofinger", :foreign_key => "owner"
  has_many :people_that_interest_me, :class_name => "Account", :through => :interests_in_others, :source=>"subject_of_interest"
  has_many :board_votes, :foreign_key=> :userid
  has_many :opt_links, :foreign_key=> :userid
  has_many :avail_links, :through=>:opt_links
  has_one  :permission, :foreign_key=> :userid
  has_many :poll_votes, :foreign_key=> :userid
  has_one  :stylesheet, :foreign_key=> :userid
  has_many :main_boards, :foreign_key=> :userid
  has_many :sub_boards, :foreign_key=> :userid
  has_one  :viewed_secret, :foreign_key=> :userid
  has_one  :plan, :foreign_key => :user_id

  #Every ruby object already has a .dsiplay() method  so we can't call it display
  has_one  :display_item, :foreign_key => :userid, :class_name =>"Display"

  before_validation do
    self.show_images = true
  end

  before_create do
       self.created = Time.now
       self.is_admin = false
       self.edit_cols = 70
       self.edit_rows = 14
     end

  #   after_create do
  #     self.plan.create
  #     # TODO create links for new user
  #   end

  #can't have "changed" attribute because of changed? method
  class << self
    def instance_method_already_implemented?(method_name)
      return true if (method_name == 'changed?'||method_name == 'changed')
      super
    end
  end

  def changed_date= value
    self[:changed] = value
  end

  def changed_date
    self[:changed]
  end

  # def grad_year_for_user_type
  #    (user_type == 'student' && grad_year > 0) || user_type != 'student'
  #  end
  #

  acts_as_authentic do |c|
    c.login_field :username
    c.crypted_password_field :crypted_password
    c.crypto_provider PhpCrypt::CryptoProviders::MD5
    c.transition_from_crypto_providers PhpCrypt::CryptoProviders::DES
    c.validate_email_field false
    c.check_passwords_against_database false
    c.perishable_token_valid_for 1.day.to_i #NOTE, the password reset email says it expires in 24 hours.
  end

  # Trick authlogic into behaving with our column name
  def crypted_password= hash
    write_attribute :password, hash
  end

  def crypted_password
    read_attribute :password
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.password_reset_instructions(self).deliver
  end

  def self.create_from_tentative tentative_account, temp_password
    ta = tentative_account
    a = nil
    account_created = ActiveRecord::Base.transaction do
      a = Account.create( :username => ta.username,
                          :email => ta.email,
                          :user_type => ta.user_type,
                          :password => temp_password,
                          :password_confirmation => temp_password,
                          :created => Time.now)
      Plan.create( :user_id => a.userid,
                   :plan => '',
                   :edit_text => '' )
      ta.delete
    end

    return a if account_created
    return nil
  end

  def self.create_random_token length=8
    characters = ('A'..'Z').to_a + (0..9).to_a
    characters -= ['B'] # B and 8 look very similar
    characters -= ['O'] # O and 0 look very similar
    characters.sort_by{rand}
    (1..length).map{characters.sample}.join
  end
end




# == Schema Information
#
# Table name: accounts
#
#  userid            :integer         not null, primary key
#  username          :string(16)      default(""), not null
#  created           :datetime
#  password          :string(34)
#  email             :string(64)
#  pseudo            :string(64)
#  login             :datetime
#  changed           :datetime
#  poll              :integer(1)
#  group_bit         :string(1)
#  spec_message      :string(255)
#  grad_year         :string(4)
#  edit_cols         :integer(1)
#  edit_rows         :integer(1)
#  webview           :string(1)       default("0")
#  notes_asc         :string(1)
#  user_type         :string(128)
#  show_images       :boolean         default(FALSE), not null
#  guest_password    :string(30)
#  is_admin          :boolean         default(FALSE)
#  persistence_token :string(255)
#  password_salt     :string(255)
#  perishable_token  :string(255)     default(""), not null
#

