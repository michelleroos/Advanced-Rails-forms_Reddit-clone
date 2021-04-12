class User < ApplicationRecord

    validates :username, :session_token, presence: true, uniqueness: true
    validates :password_digest, presence: true
    validates :password, length: { minimum: 6, allow_nil: true }
    attr_reader :password
    after_initialize :ensure_session_token

    def self.find_by_credentials(username, password)
        user = User.find_by(username: username)
        if user && user.is_password?(password)
            user
        else
            nil
        end
    end

    def self.generate_session_token
        SecureRandom::urlsafe_base64(16)
    end

    def is_password?(password)
        pass = BCrypt::Password.new(self.password_digest)
        pass.is_password?(password)
    end

    def password=(password)
        @password = password
        self.password_digest = BCrypt::Password.create(password)
    end

    def reset_session_token
        self.session_token = User.generate_session_token
        self.save
        self.session_token
    end

    private

    def ensure_session_token
        self.session_token ||= User.generate_session_token
    end

end