class User < ActiveRecord::Base
  include TokenGeneration

  attr_accessor :password
  attr_accessor :signup

  has_many :story_team_members
  has_many :stories, :through => :story_team_members
  has_many :story_actions
  has_many :stories_worked_on, :through => :story_actions, :source => 'story'
  has_many :iterations_worked_on, :through => :story_actions, :source => 'iteration'

  has_many :organisation_members
  has_many :organisations, :through => :organisation_members

  validates_email_format_of :email_address
  validates_uniqueness_of :email_address
  validates_presence_of :password, :if => :password_required?

  default_scope :order => 'email_address'

  named_scope :valid, 
    :conditions => ['verify_by IS NULL or verify_by > ?', Date.today]

  DAYS_UNTIL_UNVERIFIED = 7

  def before_create
    if signup?
      self.verified = false
      self.verification_token ||= generate_token
      self.verify_by ||= Date.today + DAYS_UNTIL_UNVERIFIED
    else
      self.verified = true
    end
  end

  def before_save
    unless password.nil? || (new_record? && ! signup?)
      self.encrypted_password ||= hash_password(password)
    end
  end

  def self.find_by_email_address_and_password(email_address, password)
    find_by_email_address_and_encrypted_password(email_address,
      hash_password(password))
  end

  def has_verification_prompt?
    !verified? && created_at < 1.day.ago
  end

  def projects
    organisations.find(:all, :include => :projects).collect(&:projects).flatten
  end

  def active_iterations_worked_on(organisation)
    iterations_worked_on.active.select do |iteration|
      iteration.project.organisation == organisation
    end.uniq
  end

  def active_stories_worked_on(organisation)
    active_iterations = active_iterations_worked_on(organisation)
    stories_worked_on.delete_if do |story|
      ! active_iterations.include?(story.iteration)
    end
  end

  def recently_finished_iterations_worked_on(organisation)
    iterations_worked_on.recently_finished.select do |iteration|
      iteration.project.organisation == organisation
    end
  end

  def signup?
    signup
  end

  def verify(options)
    return false unless options[:token] == verification_token
    self.update_attributes!(:verify_by => nil, :verified => true)
    true
  end

  def acknowledged_for?(organisation)
    organisation_members.find(
      :first,
      :conditions => {
        :organisation_id => organisation.id,
        :acknowledgement_token => nil
      }
    )
  end

  def acknowledge(options)
    organisation_member = organisation_members.
      find_by_acknowledgement_token(options[:token])
    return false unless organisation_member

    self.signup = true
    return false unless self.update_attributes(
      :verified => true,
      :password => options[:password]
    )

    return false unless organisation_member.update_attributes(
      :acknowledgement_token => nil
    )

    true
  end

  protected

  def password_required?
    signup? && encrypted_password.blank?
  end

  def self.hash_password(plaintext)
    Digest::SHA1.hexdigest(plaintext)
  end

  def hash_password(plaintext)
    self.class.hash_password(plaintext)
  end
end
