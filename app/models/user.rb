class User < ApplicationRecord
  attr_accessor :remember_token,:activation_token

  has_many :microposts

  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},format: {with: VALID_EMAIL_REGEX},uniqueness: {case_sensetive: false}
  has_secure_password
  validates :password, presence: true, length: {maximum: 8}

  # def initialize(attributes = {})
  #   @name = attributes[:name]
  #   @email = attributes[:email]
  # end

  def formatter_email
    "#{@name} <#{@email}>"
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest,User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest,nil)
  end

  def activate
    # update_attribute(:activated, true)
    # update_attribute(:activated_at, Time.zone.now)
    # 下面这种方式只需要开启一个事务
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,User.digest(reset_token))
    update_attribute(:reset_sent_at,Time.now.zone)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  # 如果指定的令牌和摘要匹配，返回 true
  # def authenticated?(remember_token)
  #   return false unless self.remember_digest
  #   BCrypt::Password.new(self.remember_digest).is_password?(remember_token)
  # end

  #这个方法是上面注释方法的通用版本，ruby用send方法代替java的反射，send方法名给对象即可调用
  def authenticated?(attribute,token)
    digest = self.send("#{attribute}_digest")
    return false  unless digest
    BCrypt::Password.new(digest).is_password?(token)
  end

  def password_reset_expired?
    reset_sent_at <2.hours.ago
  end


  # 返回指定字符串的哈希摘要
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
             BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  private
   def downcase_email
     self.email = self.email.downcase
   end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(self.activation_token)
  end

end
