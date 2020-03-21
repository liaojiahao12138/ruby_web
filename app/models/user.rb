class User < ApplicationRecord
  attr_accessor :name, :email

  has_many :microposts

  before_save{email.downcase! }
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},format: {with: VALID_EMAIL_REGEX},uniqueness: {case_sensetive: false}
  has_secure_password
  validates :password, presence: true, length: {maximum: 8}

  def initialize(attributes = {})
    @name = attributes[:name]
    @email = attributes[:email]
  end

  def formatter_email
    "#{@name} <#{@email}>"
  end
end
