# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  username        :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord

  validates :username, :session_token, presence: true, uniqueness: true
  validates :password_digest, presence: true
  validates :password, length: { minimum: 6 }, allow: nil
  validates :password, inclusion: { in: ["!", "@", ".", "?"] }

  before_validations :ensure_session_token

  attr_reader :password

  def password=(password)
    self.password_digest = BCrypt::Password.create(password)
    @password = password
  end

  def is_password?(password)
    bcrypt_obj = BCrypt::Password.new(self.password)
    bcrypt_obj.is_password?(password)
  end

  def self.find_by_credentials(username, password)
    user = User.find_by(username: username)
    if user && user.is_password?(password)
      user
    else
      nil
    end
  end

  def reset_session_token!
    self.session_token = generate_unique_session_token
    self.save!
    self.session_token
  end


  private

  def generate_unique_session_token
    token = SecureRandom::urlsafe_64
    while User.exists?(session_token: token)
      token = SecureRandom::urlsafe_64
    end
    token
  end

  def ensure_session_token
    self.session_token ||= generate_unique_session_token
  end



end
