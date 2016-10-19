class Autofinger < ActiveRecord::Base
  self.table_name = :autofinger
  validates_presence_of :owner, :interest, :priority
  validates :priority, inclusion: { in: [0, 1, 2, 3] }

  belongs_to :interested_party, foreign_key: :owner, class_name: 'Account'
  belongs_to :subject_of_interest, foreign_key: :interest, class_name: 'Account'

  scope :updated, -> { where(updated: 1) }

  def self.mark_plan_as_read(owner, interest)
    autofinger = Autofinger.where(owner: owner, interest: interest).first
    unless autofinger.blank?
      autofinger.updated = '0'
      autofinger.readtime = Time.now
      autofinger.save
    end
  end

  def self.mark_level_as_read(owner, level)
    Autofinger.where(owner: owner, priority: level).update_all(updated: '0', readtime: Time.now)
  end

end
