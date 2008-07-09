class TemporaryLink < ActiveRecord::Base
  attr_accessor :ttl
  
  belongs_to :temporarylinkable, :polymorphic => true  
  before_save :create_random_string
  
  def create_random_string
    self.token = self.class.random_string(8)
  end
  
  def expired?
    Time.now > expires_at
  end
  
  def active?
    ! expired?
  end
  
  def ttl;@ttl ||= 1.week;end
  def expires_at;self.updated_at == self.created_at ? (self.created_at + ttl) : (self.updated_at);end
  def expiration_date;self.expires_at;end
  
  class << self
    def random_string(length)
       Digest::SHA1.hexdigest((1..6).collect { (i = rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join).slice(1..length)
    end
  end
end
