class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  has_one_time_password length: 6
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :jwt_authenticatable, :validatable,
         jwt_revocation_strategy: self
  has_many :tweets
  has_many :follows
  has_many :followers, through: :follows
  has_many :inverse_followers, class_name: "Follow", :foreign_key => :follower_id
  has_many :following, through: :inverse_followers, source: :user 
end
