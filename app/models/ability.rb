# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    
    alias_action :create, :read, :update, :destroy, to: :crud
    
    can :crud, Idea do |idea|
      idea.user == user
    end

    can :crud, Review do |review|
      review.user == user
    end

    can :like, Idea do |idea|
      user.persisted? && idea.user != user
    end
  end
end
