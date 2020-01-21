class User < ApplicationRecord
    has_many :likes, dependent: :destroy
    has_many :ideas, dependent: :nullify
    has_many :liked_ideas, through: :likes, source: :idea
    has_many :reviews, dependent: :destroy

    validates :email, presence: true, uniqueness: true,
    format: /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    has_secure_password
    
    def full_name
        "#{first_name} #{last_name}"
    end
end
